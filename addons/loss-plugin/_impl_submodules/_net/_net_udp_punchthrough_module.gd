# Tool

# Class
class_name _LNetUDPPunchthroughServiceModule

# Extends
extends Node

# Docstring

# Signals
signal packet_recieved(packet, peer_id)
signal peer_connected(peer_id)
signal peer_disconnected(peer_id)
signal session_destroyed
signal service_offline

# Enums

# Constants

# Exported Variables

# Public Variables

# Private Variables
# References
var _loggingModuleRef: _LLoggingModule
var _authModuleRef: _LAuthorizationClass
var _lossConfigRef: Dictionary
# Self
var _serverHeartbeatTimer: Timer
var _serverPacketStorage: Array
var _client: PacketPeerUDP
var _serverIP: String
var _serverPORT: int
var _serverEncryptionKey: String
var _currentSessionDetails: Dictionary = {
	isRegistered=false,
	inSession=false,
	isSessionHost=false,
	currentSessionCode=""
}
var _responseCodes: Dictionary = {
	CONN_ACKNOWLEDGED="CONN_ACKNOWLEDGED",
	CONN_INVALID_BODY="CONN_INVALID_BODY",
	CONN_NOT_REGISTERED="CONN_NOT_REGISTERED",
	CONN_ALREADY_REGISTERED="CONN_ALREADY_REGISTERED",
	CONN_ALREADY_HOSTING_SESSION="CONN_ALREADY_HOSTING_SESSION",
	CONN_ALREADY_IN_SESSION="CONN_ALREADY_IN_SESSION",
	SESSION_PEER_CONNECTED="SESSION_PEER_CONNECTED",
	SESSION_PEER_DISCONNECTED="SESSION_PEER_DISCONNECTED",
	SESSION_SESSION_DESTROYED="SESSION_SESSION_DESTROYED",
	SESSION_REQUESTED_SESSION_NOT_FOUND="SESSION_REQUESTED_SESSION_NOT_FOUND",
	SESSION_REQUESTED_SESSION_FULL="SESSION_REQUESTED_SESSION_FULL",
	SESSION_SESSION_PASSWORD_INVALID="SESSION_SESSION_PASSWORD_INVALID",
	AUTH_INVALID_ENCRYPT_KEY="AUTH_INVALID_ENCRYPT_KEY",
	AUTH_ACCESS_TOKEN_NOT_PROVIDED="AUTH_ACCESS_TOKEN_NOT_PROVIDED",
	AUTH_CLIENT_TOKEN_NOT_PROVIDED="AUTH_CLIENT_TOKEN_NOT_PROVIDED",
	AUTH_INVALID_TOKENS="AUTH_INVALID_TOKENS",
	SERVER_HEARTBEAT="SERVER_HEARTBEAT",
	SERVER_INTERNAL_ERROR="SERVER_INTERNAL_ERROR",
}

# Onready Variables

# _init()
func _init(loggingModuleReference: _LLoggingModule, lossConfigurationReference: Dictionary, authorizationModuleReference: _LAuthorizationClass) -> void:
	# Save the refrences
	_loggingModuleRef = loggingModuleReference
	_authModuleRef = authorizationModuleReference
	_lossConfigRef = lossConfigurationReference

	# Set data
	_serverIP = _lossConfigRef.UDPPunchthrough.IP
	_serverPORT = _lossConfigRef.UDPPunchthrough.PORT
	_serverEncryptionKey = _lossConfigRef.UDPPunchthrough.ENCKEY

	# Create a new UDP client
	_client = PacketPeerUDP.new()

	# Setup the heartbeat timer
	_serverHeartbeatTimer = Timer.new()
	_serverHeartbeatTimer.wait_time = 10
	_serverHeartbeatTimer.autostart = false
	_serverHeartbeatTimer.name = "LossAPI-UDPHeartbeat"
	_serverHeartbeatTimer.connect("timeout", self, "_service_offline")
	add_child(_serverHeartbeatTimer)


# _ready()
# func _ready() -> void:
#     returns

# _other()
func _process(_delta: float) -> void:
	_poll_packets()

# Public Methods
func registerClient() -> _LMethodResponseData:
	# Fix for weird yield issues
	yield(get_tree(), "idle_frame")

	# Check if we are already registered
	if _currentSessionDetails.isRegistered:
		_loggingModuleRef.wrn(["You are already registered"])
		return _LMethodResponseData.new({"errorMessage": "Already registered", "errorCode": _responseCodes.CONN_ALREADY_REGISTERED})
	
	# Format payload
	var authorizationHeader: Dictionary = {
		"accessToken": _authModuleRef._tokens["accessToken"],
		"clientToken": _lossConfigRef.clientToken,
	}
	var authorizationHeaderJWT: String = _authModuleRef._encryptWithJWT(authorizationHeader, _serverEncryptionKey)
	var payload: Dictionary = {
		"authorizationHeader": authorizationHeaderJWT,
		"requestedRoute": "registerClient",
	}

	# Log
	_loggingModuleRef.log(["Attempting to connect to server"])

	# Connect to server
	var serverConnectionError: int = _client.connect_to_host(_serverIP, _serverPORT)
	if serverConnectionError != OK:
		_loggingModuleRef.err(["Error while connecting to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while connecting to server", "errorCode": serverConnectionError})

	# Log
	_loggingModuleRef.log(["Successfully connected to server | Attempting to send register client request"])

	# Send request
	var sendError: int = _client.put_packet(to_json(payload).to_utf8())
	if sendError != OK:
		_loggingModuleRef.err(["Error while sending packets to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while sending packet to server", "errorCode": sendError})

	# Log
	_loggingModuleRef.log(["Request sent | Waiting for response"])

	# Wait for response
	var secondsPassed: int = 0
	while _serverPacketStorage.size() == 0:
		if secondsPassed == 20:
			_loggingModuleRef.err(["UDP connection timeout | Is the server offline?"])
			return _LMethodResponseData.new({"errorMessage": "UDP connection timeout"})
		else:
			yield(get_tree().create_timer(1), "timeout")
			_loggingModuleRef.log(["Waiting...(%s seconds passed)" % [secondsPassed]])
			secondsPassed += 1
	
	# Log
	_loggingModuleRef.log(["Response recieved | Decoding"])

	# Retrieve response
	var responseData: Dictionary = _retrieve_packet()	

	# Error handling
	if responseData.responseCode != _responseCodes.CONN_ACKNOWLEDGED:
		_loggingModuleRef.err([responseData.responseData.message])
		return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": responseData.responseCode})

	# Log
	_loggingModuleRef.log(["Successfully registed new UDP client"])

	# Toggle isRegistered and start heartbeat
	_currentSessionDetails.isRegistered = true
	_serverHeartbeatTimer.start()
	
	return _LMethodResponseData.new({})

func createSession(maxConnections: int = 10, sessionName: String = "", isSessionVisible: bool = true, sessionPassword: String = "") -> _LMethodResponseData:
	# Fix for weird yield issues
	yield(get_tree(), "idle_frame")

	# Check if we are registered
	if !_currentSessionDetails.isRegistered:
		_loggingModuleRef.wrn(["You must register before using this service"])
		return _LMethodResponseData.new({"errorMessage": "Not registered", "errorCode": _responseCodes.CONN_NOT_REGISTERED})

	# Check if we are in a session
	if _currentSessionDetails.inSession:
		if _currentSessionDetails.isSessionHost:
			_loggingModuleRef.wrn(["You are already hosting a session"])
			return _LMethodResponseData.new({"errorMessage": "Already hosting a session", "errorCode": _responseCodes.CONN_ALREADY_HOSTING_SESSION})
		
		_loggingModuleRef.wrn(["You must leave your current session before making one"])
		return _LMethodResponseData.new({"errorMessage": "Currently in session", "errorCode": _responseCodes.CONN_ALREADY_IN_SESSION})
	
	# Format payload
	var authorizationHeader: Dictionary = {
		"accessToken": _authModuleRef._tokens["accessToken"],
		"clientToken": _lossConfigRef.clientToken,
	}
	var authorizationHeaderJWT: String = _authModuleRef._encryptWithJWT(authorizationHeader, _serverEncryptionKey)
	var payload: Dictionary = {
		"authorizationHeader": authorizationHeaderJWT,
		"requestedRoute": "createSession",
		"payload": {
			"sessionName": sessionName,
			"sessionMaxConnections": maxConnections,
			"isSessionVisible": isSessionVisible,
			"sessionPassword": sessionPassword
		},
	}

	# Log
	_loggingModuleRef.log(["Attempting to create a new session"])

	# Send request
	var sendError: int = _client.put_packet(to_json(payload).to_utf8())
	if sendError != OK:
		_loggingModuleRef.err(["Error while sending packets to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while sending packet to server", "errorCode": sendError})

	# Log
	_loggingModuleRef.log(["Request sent | Waiting for response"])

	# Wait for response
	var secondsPassed: int = 0
	while _serverPacketStorage.size() == 0:
		if secondsPassed == 20:
			_loggingModuleRef.err(["UDP connection timeout | Is the server offline?"])
			return _LMethodResponseData.new({"errorMessage": "UDP connection timeout"})
		else:
			yield(get_tree().create_timer(1), "timeout")
			_loggingModuleRef.log(["Waiting...(%s seconds passed)" % [secondsPassed]])
			secondsPassed += 1

	# Log
	_loggingModuleRef.log(["Response recieved | Decoding"])

	# Retrieve response
	var responseData: Dictionary = _retrieve_packet()	

	# Error handling
	if responseData.responseCode != _responseCodes.CONN_ACKNOWLEDGED:
		_loggingModuleRef.err([responseData.responseData.message])
		return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": responseData.responseCode})
	
	# Log
	_loggingModuleRef.log(["Successfully created new session"])

	# Toggle inSession and supply the session code
	_currentSessionDetails.inSession = true
	_currentSessionDetails.currentSessionCode = responseData.responseData.sessionCode

	return _LMethodResponseData.new({"returnData": {"sessionCode": responseData.responseData.sessionCode}})

func findSessions(maxResults: int = 10) -> _LMethodResponseData:
	# Fix for weird yield issues
	yield(get_tree(), "idle_frame")

	# Check if we are registered
	if !_currentSessionDetails.isRegistered:
		_loggingModuleRef.wrn(["You must register before using this service"])
		return _LMethodResponseData.new({"errorMessage": "Not registered", "errorCode": _responseCodes.CONN_NOT_REGISTERED})

	# Format payload
	var authorizationHeader: Dictionary = {
		"accessToken": _authModuleRef._tokens["accessToken"],
		"clientToken": _lossConfigRef.clientToken,
	}
	var authorizationHeaderJWT: String = _authModuleRef._encryptWithJWT(authorizationHeader, _serverEncryptionKey)
	var payload: Dictionary = {
		"authorizationHeader": authorizationHeaderJWT,
		"requestedRoute": "findSessions",
		"payload": {
				"maxResults": maxResults,
		},
	}

	# Log
	_loggingModuleRef.log(["Attempting to find sessions"])

	# Send request
	var sendError: int = _client.put_packet(to_json(payload).to_utf8())
	if sendError != OK:
		_loggingModuleRef.err(["Error while sending packets to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while sending packet to server", "errorCode": sendError})
	
	# Log
	_loggingModuleRef.log(["Request sent | Waiting for response"])

	# Wait for response
	var secondsPassed: int = 0
	while _serverPacketStorage.size() == 0:
		if secondsPassed == 20:
			_loggingModuleRef.err(["UDP connection timeout | Is the server offline?"])
			return _LMethodResponseData.new({"errorMessage": "UDP connection timeout"})
		else:
			yield(get_tree().create_timer(1), "timeout")
			_loggingModuleRef.log(["Waiting...(%s seconds passed)" % [secondsPassed]])
			secondsPassed += 1

	# Log
	_loggingModuleRef.log(["Response recieved | Decoding"])

	# Retrieve response
	var responseData: Dictionary = _retrieve_packet()	

	# Error handling
	if responseData.responseCode != _responseCodes.CONN_ACKNOWLEDGED:
		_loggingModuleRef.err([responseData.responseData.message])
		return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": responseData.responseCode})

	# Log
	_loggingModuleRef.log(["Successfully found new session(s)"])	

	return _LMethodResponseData.new({"returnData": {"foundSessions": responseData.responseData.foundSessions}})

func joinSession(sessionCode: String, sessionPassword: String = "") -> _LMethodResponseData:
	# Fix for weird yield issues
	yield(get_tree(), "idle_frame")

	# Check if we are registered
	if !_currentSessionDetails.isRegistered:
		_loggingModuleRef.wrn(["You must register before using this service"])
		return _LMethodResponseData.new({"errorMessage": "Not registered", "errorCode": _responseCodes.CONN_NOT_REGISTERED})

	# Check if we are in a session
	if _currentSessionDetails.inSession:
		if _currentSessionDetails.isSessionHost:
			_loggingModuleRef.wrn(["You are currently hosting a session | Destroy your current session before joining another session"])
			return _LMethodResponseData.new({"errorMessage": "Currently hosting a session", "errorCode": _responseCodes.CONN_ALREADY_HOSTING_SESSION})
		
		_loggingModuleRef.wrn(["You must leave your current session joining one"])
		return _LMethodResponseData.new({"errorMessage": "Already in a session", "errorCode": _responseCodes.CONN_ALREADY_IN_SESSION})
	
	# Format payload
	var authorizationHeader: Dictionary = {
		"accessToken": _authModuleRef._tokens["accessToken"],
		"clientToken": _lossConfigRef.clientToken,
	}
	var authorizationHeaderJWT: String = _authModuleRef._encryptWithJWT(authorizationHeader, _serverEncryptionKey)
	var payload: Dictionary = {
		"authorizationHeader": authorizationHeaderJWT,
		"requestedRoute": "joinSession",
		"payload": {
			"sessionCode": sessionCode,
			"sessionPassword": sessionPassword,
		},
	}

	# Log
	_loggingModuleRef.log(["Attempting to join session"])

	# Send request
	var sendError: int = _client.put_packet(to_json(payload).to_utf8())
	if sendError != OK:
		_loggingModuleRef.err(["Error while sending packets to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while sending packet to server", "errorCode": sendError})

	# Log
	_loggingModuleRef.log(["Request sent | Waiting for response"])

	# Wait for response
	var secondsPassed: int = 0
	while _serverPacketStorage.size() == 0:
		if secondsPassed == 20:
			_loggingModuleRef.err(["UDP connection timeout | Is the server offline?"])
			return _LMethodResponseData.new({"errorMessage": "UDP connection timeout"})
		else:
			yield(get_tree().create_timer(1), "timeout")
			_loggingModuleRef.log(["Waiting...(%s seconds passed)" % [secondsPassed]])
			secondsPassed += 1

	# Log
	_loggingModuleRef.log(["Response recieved | Decoding"])

	# Retrieve response
	var responseData: Dictionary = _retrieve_packet()	

	# Error handling
	if responseData.responseCode != _responseCodes.CONN_ACKNOWLEDGED:
		_loggingModuleRef.err([responseData.responseData.message])
		return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": responseData.responseCode})

	# Log
	_loggingModuleRef.log(["Successfully joined session"])

	# Toggle inSession and currentSessionCode
	_currentSessionDetails.inSession = true
	_currentSessionDetails.currentSessionCode = sessionCode

	return _LMethodResponseData.new({})

func sendPacket(packet: Dictionary, remoteID: String = "0") -> _LMethodResponseData:
	# Fix for weird yield issues
	yield(get_tree(), "idle_frame")

	# Check if we are registered
	if !_currentSessionDetails.isRegistered:
		_loggingModuleRef.wrn(["You must register before using this service"])
		return _LMethodResponseData.new({"errorMessage": "Not registered", "errorCode": _responseCodes.CONN_NOT_REGISTERED})
	
	# Check if we are in a session
	if !_currentSessionDetails.inSession:
		_loggingModuleRef.wrn(["You must be in a session before sending packets"])
		return _LMethodResponseData.new({"errorMessage": "Not in session", "errorCode": _responseCodes.SESSION_REQUESTED_SESSION_NOT_FOUND})
	
	# Format payload
	var authorizationHeader: Dictionary = {
		"accessToken": _authModuleRef._tokens["accessToken"],
		"clientToken": _lossConfigRef.clientToken,
	}
	var authorizationHeaderJWT: String = _authModuleRef._encryptWithJWT(authorizationHeader, _serverEncryptionKey)
	var payload: Dictionary = {
		"authorizationHeader": authorizationHeaderJWT,
		"requestedRoute": "sendPacket",
		"payload": {
			"packetData": packet,
			"receivingPeer": remoteID,
		},
	}

	# Log
	_loggingModuleRef.log(["Attempting to send packet"])

	# Send request
	var sendError: int = _client.put_packet(to_json(payload).to_utf8())
	if sendError != OK:
		_loggingModuleRef.err(["Error while sending packets to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while sending packet to server", "errorCode": sendError})

	# Log
	_loggingModuleRef.log(["Request sent | Waiting for response"])

	# Wait for response
	var secondsPassed: int = 0
	while _serverPacketStorage.size() == 0:
		if secondsPassed == 20:
			_loggingModuleRef.err(["UDP connection timeout | Is the server offline?"])
			return _LMethodResponseData.new({"errorMessage": "UDP connection timeout"})
		else:
			yield(get_tree().create_timer(1), "timeout")
			_loggingModuleRef.log(["Waiting...(%s seconds passed)" % [secondsPassed]])
			secondsPassed += 1

	# Log
	_loggingModuleRef.log(["Response recieved | Decoding"])

	# Retrieve response
	var responseData: Dictionary = _retrieve_packet()	

	# Error handling
	if responseData.responseCode != _responseCodes.CONN_ACKNOWLEDGED:
		_loggingModuleRef.err([responseData.responseData.message])
		return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": responseData.responseCode})
	
	# Log
	_loggingModuleRef.log(["Successfully sent packet"])

	return _LMethodResponseData.new({})

func destroySession() -> _LMethodResponseData:
	# Fix for weird yield issues
	yield(get_tree(), "idle_frame")

	# Check if we are registered
	if !_currentSessionDetails.isRegistered:
		_loggingModuleRef.wrn(["You must register before using this service"])
		return _LMethodResponseData.new({"errorMessage": "Not registered", "errorCode": _responseCodes.CONN_NOT_REGISTERED})

	# Check if we are in a session
	if !_currentSessionDetails.inSession:
		_loggingModuleRef.wrn(["You must be in a session before destroying one"])
		return _LMethodResponseData.new({"errorMessage": "Not in session", "errorCode": _responseCodes.SESSION_REQUESTED_SESSION_NOT_FOUND})

	# Format payload
	var authorizationHeader: Dictionary = {
		"accessToken": _authModuleRef._tokens["accessToken"],
		"clientToken": _lossConfigRef.clientToken,
	}
	var authorizationHeaderJWT: String = _authModuleRef._encryptWithJWT(authorizationHeader, _serverEncryptionKey)
	var payload: Dictionary = {
		"authorizationHeader": authorizationHeaderJWT,
		"requestedRoute": "destroySession",
	}

	# Log
	_loggingModuleRef.log(["Attempting to destroy session"])


	# Send request
	var sendError: int = _client.put_packet(to_json(payload).to_utf8())
	if sendError != OK:
		_loggingModuleRef.err(["Error while sending packets to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while sending packet to server", "errorCode": sendError})

	# Log
	_loggingModuleRef.log(["Request sent | Waiting for response"])

	# Wait for response
	var secondsPassed: int = 0
	while _serverPacketStorage.size() == 0:
		if secondsPassed == 20:
			_loggingModuleRef.err(["UDP connection timeout | Is the server offline?"])
			return _LMethodResponseData.new({"errorMessage": "UDP connection timeout"})
		else:
			yield(get_tree().create_timer(1), "timeout")
			_loggingModuleRef.log(["Waiting...(%s seconds passed)" % [secondsPassed]])
			secondsPassed += 1

	# Log
	_loggingModuleRef.log(["Response recieved | Decoding"])

	# Retrieve response
	var responseData: Dictionary = _retrieve_packet()	

	# Error handling
	if responseData.responseCode != _responseCodes.CONN_ACKNOWLEDGED:
		_loggingModuleRef.err([responseData.responseData.message])
		return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": responseData.responseCode})

	# Log
	_loggingModuleRef.log(["Successfully destroyed session"])

	# Toggle inSession, isHosting, and currentSessionCode
	_currentSessionDetails.inSession = false
	_currentSessionDetails.isSessionHost = false
	_currentSessionDetails.currentSessionCode = ""

	return _LMethodResponseData.new({})

# Private Methods
func _poll_packets() -> void:
	# Check if client is valid
	if !is_instance_valid(_client):
		return

	# Check if we are connected to a server
	if !_client.is_connected_to_host():
		return

	# Check if we have any available packets
	if _client.get_available_packet_count() == 0:
		return

	# Poll data
	var decodedPacket: Dictionary = parse_json(_client.get_packet().get_string_from_utf8())

	# Sort and organize
	# Disregard empty packets (Means the server is offline)
	if decodedPacket.empty():
		return
	
	# SERVER type packets are for handling any error/return data
	if decodedPacket.responseType == "SERVER":
		_serverPacketStorage.append(decodedPacket)
		return

	# SESSION type packets are for handling any session specific events
	if decodedPacket.responseType == "SESSION":
		match decodedPacket.responseCode:
			_responseCodes.SESSION_PEER_CONNECTED:
				emit_signal("peer_connected", decodedPacket.responseData.peerID)
				return
			
			_responseCodes.SESSION_PEER_DISCONNECTED:
				emit_signal("peer_disconnected", decodedPacket.responseData.peerID)
				return
			
			_responseCodes.SESSION_SESSION_DESTROYED:
				emit_signal("session_destroyed")
				return
		return

	# CLIENT type packets are for handling p2p/client to client communication
	if decodedPacket.responseType == "CLIENT":
		emit_signal("packet_recieved", decodedPacket.responseData.packet, decodedPacket.responseData.peerID)
		return
	
	# HEARTBEAT type packets are for handling the client-server heartbeat
	if decodedPacket.responseType == "HEARTBEAT":
		# Reset timer and send a response
		_serverHeartbeatTimer.start()

		# Format payload
		var authorizationHeader: Dictionary = {
			"accessToken": _authModuleRef._tokens["accessToken"],
			"clientToken": _lossConfigRef.clientToken,
		}
		var authorizationHeaderJWT: String = _authModuleRef._encryptWithJWT(authorizationHeader, _serverEncryptionKey)
		var payload: Dictionary = {
			"authorizationHeader": authorizationHeaderJWT,
			"requestedRoute": "clientHeartbeat",
		}

		_client.put_packet(to_json(payload).to_utf8())

func _retrieve_packet() -> Dictionary:
	return _serverPacketStorage.pop_front()

func _service_offline() -> void:
	# Reset session data
	_currentSessionDetails = {
		isRegistered=false,
		inSession=false,
		isSessionHost=false,
		currentSessionCode=""
	}

	# Emit signal
	emit_signal("service_offline")