# Tool

# Class
class_name _LNetUDPPunchthroughServiceModule

# Extends
extends Node

# Docstring
# Loopware Online Subsystem Godot Plugin @ UDP Punchthrough Service Module || Provides an easy to use
# Punchthrough client for making P2P multiplayer sessions | More info -> https://en.wikipedia.org/wiki/UDP_hole_punching
# NOTE: Currently Access-Client token pairs are transported via clear text. This really isint good

# Signals
signal packet_recieved(packetData)
signal peer_connected
signal peer_disconnected
signal session_destroyed

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
var _serverPacketStorage: Array = []
var _client: PacketPeerUDP
var _serverIP: String
var _serverPort: int
var _sessionDetails: Dictionary = {isRegistered=false, isHosting=false, inSession=false, sessionCode=""}
var _responseCodes: Dictionary = {
	CONN_ACKNOWLEDGED="CONN_ACKNOWLEDGED",
	CONN_INVALID_BODY="CONN_INVALID_BODY",
	CONN_ALREADY_REGISTERED="CONN_ALREADY_REGISTERED",
	CONN_NOT_REGISTERED="CONN_NOT_REGISTERED",
	CONN_ALREADY_HOSTING="CONN_ALREADY_HOSTING",
	CONN_ALREADY_IN_SESSION="CONN_ALREADY_IN_SESSION",
	CONN_SESSION_IS_FULL="CONN_SESSION_IS_FULL",
	CONN_SESSION_NOT_FOUND="CONN_SESSION_NOT_FOUND",
	SESSION_PEER_CONNECTED="SESSION_PEER_CONNECTED",
	SESSION_PEER_DISCONNECTED="SESSION_PEER_DISCONNECTED",
	SESSION_DESTROYED="SESSION_DESTROYED",
	AUTH_INVALID_TOKENS="AUTH_INVALID_TOKENS",
	AUTH_ACCESS_TOKEN_NOT_PROVIDED="AUTH_ACCESS_TOKEN_NOT_PROVIDED",
	AUTH_CLIENT_TOKEN_NOT_PROVIDED="AUTH_CLIENT_TOKEN_NOT_PROVIDED",
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
	_serverIP = _lossConfigRef.netUDPPunchthroughServer.IP
	_serverPort = _lossConfigRef.netUDPPunchthroughServer.PORT

	# Create a new UDP client
	_client = PacketPeerUDP.new()

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

	# Check if we are registered
	if _sessionDetails.isRegistered:
		_loggingModuleRef.wrn(["Already registered with UDP Punchthrough service"])
		return _LMethodResponseData.new({"errorMessage": "Already registered", "errorCode": _responseCodes.CONN_ALREADY_REGISTERED})
	
	# Format payload
	# # Attempt to encode authorization header
	# var formatedHeader: PoolByteArray = ("%s:%s" % [_authModuleRef._tokens["accessToken"], _lossConfigRef.clientID]).to_utf8()
	# var responseData: _LMethodResponseData = _authModuleRef._encryptWithJWT(formatedHeader)

	# # Format payload
	# if responseData.hasError():
	# 	_loggingModuleRef.err(["Error while encrypting data | Code: %s | Message: %s" % [responseData.getErrorDetails()[1], responseData.getErrorDetails()[0]]])
	# 	return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[1], "errorCode":responseData.getErrorDetails()[0]})
	var payload: Dictionary = {
		"requestedRoute": "registerClient",
		"authorizationBearer": "%s:%s" % [_authModuleRef._tokens["accessToken"], _lossConfigRef.clientID],
	}
	
	# Log
	_loggingModuleRef.log(["Attempting to connect to server"])

	# Connect to server
	var serverConnectionError: int = _client.connect_to_host(_serverIP, _serverPort)
	if serverConnectionError != OK:
		_loggingModuleRef.err(["Error while connecting to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while connecting to server", "errorCode": serverConnectionError})
	
	# Log
	_loggingModuleRef.log(["Successfully connected to server | Attempting to send register client request"])

	# Send request
	var sendError: int = _client.put_packet(to_json(payload).to_utf8())
	if sendError != OK:
		_loggingModuleRef.err(["Error while sending packets to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while sending packets to server", "errorCode": sendError})
	
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
	match responseData.responseCode:
		_responseCodes.CONN_ALREADY_REGISTERED:
			_loggingModuleRef.wrn(["Already registered with UDP Punchthrough service"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.CONN_ALREADY_REGISTERED})

		_responseCodes.AUTH_INVALID_TOKENS:
			_loggingModuleRef.err(["Invalid Access-Client token pair"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.AUTH_INVALID_TOKENS})

		_responseCodes.AUTH_ACCESS_TOKEN_NOT_PROVIDED:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.AUTH_INVALID_TOKENS})
		
		_responseCodes.AUTH_CLIENT_TOKEN_NOT_PROVIDED:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.AUTH_CLIENT_TOKEN_NOT_PROVIDED})
		
		_responseCodes.SERVER_INTERNAL_ERROR:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.SERVER_INTERNAL_ERROR})
	
	# Log
	_loggingModuleRef.log(["Successfully registed new UDP client"])

	# Toggle isRegistered
	_sessionDetails.isRegistered = true

	return _LMethodResponseData.new({})

func createSession(maxConnections: int = 10, sessionName: String = "") -> _LMethodResponseData:
	# Fix for weird yield issues
	yield(get_tree(), "idle_frame")

	# Check if we are NOT registered
	if !_sessionDetails.isRegistered:
		_loggingModuleRef.wrn(["You must register before using this service"])
		return _LMethodResponseData.new({"errorMessage": "You must register before using this service", "errorCode": _responseCodes.CONN_NOT_REGISTERED})
	
	# Check if we are currently hosting
	if _sessionDetails.isHosting:
		_loggingModuleRef.wrn(["You must destroy your current session before making one"])
		return _LMethodResponseData.new({"errorMessage": "You must destroy your current session before making one", "errorCode": _responseCodes.CONN_ALREADY_HOSTING})
	
	# Check if we are in a session
	if _sessionDetails.inSession:
		_loggingModuleRef.wrn(["You must destroy your current session before making one"])
		return _LMethodResponseData.new({"errorMessage": "You must destroy your current session before making one", "errorCode": _responseCodes.CONN_ALREADY_IN_SESSION})

	# Format payload
	var payload: Dictionary = {
		"requestedRoute": "createSession",
		"authorizationBearer": "%s:%s" % [_authModuleRef._tokens["accessToken"], _lossConfigRef.clientID],
		"sessionInfo": {
			"maxConnections": maxConnections,
			"sessionName": sessionName,
		},
	}

	# Log
	_loggingModuleRef.log(["Attempting to create a new session"])

	# Send request
	var sendError: int = _client.put_packet(to_json(payload).to_utf8())
	if sendError != OK:
		_loggingModuleRef.err(["Error while sending packets to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while sending packets to server", "errorCode": sendError})
	
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
	
	# Retrieve response
	var responseData: Dictionary = _retrieve_packet()

	# Error handling
	match responseData.responseCode:
		_responseCodes.CONN_NOT_REGISTERED:
			_loggingModuleRef.wrn(["You must register before using this service"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.CONN_NOT_REGISTERED})
		
		_responseCodes.CONN_ALREADY_HOSTING:
			_loggingModuleRef.wrn(["You must destroy your current session before making one"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.CONN_ALREADY_HOSTING})
		
		_responseCodes.CONN_ALREADY_IN_SESSION:
			_loggingModuleRef.wrn(["You must leave your current session before making one"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.CONN_ALREADY_IN_SESSION})
		
		_responseCodes.AUTH_ACCESS_TOKEN_NOT_PROVIDED:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.AUTH_INVALID_TOKENS})
		
		_responseCodes.AUTH_CLIENT_TOKEN_NOT_PROVIDED:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.AUTH_CLIENT_TOKEN_NOT_PROVIDED})
		
		_responseCodes.SERVER_INTERNAL_ERROR:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.SERVER_INTERNAL_ERROR})

	# Log
	_loggingModuleRef.log(["Successfully created new session"])

	# Toggle inSession and supply the session code
	_sessionDetails.inSession = true
	_sessionDetails.sessionCode = responseData.responseData.sessionCode

	return _LMethodResponseData.new({"returnData": {"sessionCode": _sessionDetails.sessionCode}})

func findSessions(maxResults: int = 10) -> _LMethodResponseData:
	# Fix for weird yield issues
	yield(get_tree(), "idle_frame")

	# Check if we are NOT registered
	if !_sessionDetails.isRegistered:
		_loggingModuleRef.wrn(["You must register before using this service"])
		return _LMethodResponseData.new({"errorMessage": "You must register before using this service", "errorCode": _responseCodes.CONN_NOT_REGISTERED})

	# Format payload
	var payload: Dictionary = {
		"requestedRoute": "findSessions",
		"authorizationBearer": "%s:%s" % [_authModuleRef._tokens["accessToken"], _lossConfigRef.clientID],
		"searchSettings": {
			"maxResults": maxResults,
		},
	}

	# Log
	_loggingModuleRef.log(["Attempting to find results"])

	# Send request
	var sendError: int = _client.put_packet(to_json(payload).to_utf8())
	if sendError != OK:
		_loggingModuleRef.err(["Error while sending packets to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while sending packets to server", "errorCode": sendError})
	
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
	
	# Retrieve response
	var responseData: Dictionary = _retrieve_packet()

	# Error handling
	match responseData.responseCode:
		_responseCodes.CONN_NOT_REGISTERED:
			_loggingModuleRef.wrn(["You must register before using this service"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.CONN_NOT_REGISTERED})
		
		_responseCodes.AUTH_ACCESS_TOKEN_NOT_PROVIDED:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.AUTH_INVALID_TOKENS})
		
		_responseCodes.AUTH_CLIENT_TOKEN_NOT_PROVIDED:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.AUTH_CLIENT_TOKEN_NOT_PROVIDED})
		
		_responseCodes.SERVER_INTERNAL_ERROR:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.SERVER_INTERNAL_ERROR})

	# Log
	_loggingModuleRef.log(["Successfully found new session(s)"])

	return _LMethodResponseData.new({"returnData": {"foundSessions": responseData.responseData.foundSessions}})

func joinSession(sessionCode: String) -> _LMethodResponseData:
	# Fix for weird yield issues
	yield(get_tree(), "idle_frame")

	# Check if we are NOT registered
	if !_sessionDetails.isRegistered:
		_loggingModuleRef.wrn(["You must register before using this service"])
		return _LMethodResponseData.new({"errorMessage": "You must register before using this service", "errorCode": _responseCodes.CONN_NOT_REGISTERED})
	
	# Check if we are currently hosting
	if _sessionDetails.isHosting:
		_loggingModuleRef.wrn(["You must destroy your current session before joining one"])
		return _LMethodResponseData.new({"errorMessage": "You must destroy your current session before joining one", "errorCode": _responseCodes.CONN_ALREADY_HOSTING})
	
	# Check if we are in a session
	if _sessionDetails.inSession:
		_loggingModuleRef.wrn(["You must destroy your current session before joining one"])
		return _LMethodResponseData.new({"errorMessage": "You must destroy your current session before joining one", "errorCode": _responseCodes.CONN_ALREADY_IN_SESSION})

	# Format payload
	var payload: Dictionary = {
		"requestedRoute": "joinSession",
		"authorizationBearer": "%s:%s" % [_authModuleRef._tokens["accessToken"], _lossConfigRef.clientID],
		"sessionCode": sessionCode,
	}

	# Log
	_loggingModuleRef.log(["Attempting to join session"])

	# Send request
	var sendError: int = _client.put_packet(to_json(payload).to_utf8())
	if sendError != OK:
		_loggingModuleRef.err(["Error while sending packets to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while sending packets to server", "errorCode": sendError})
	
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

	# Retrieve response
	var responseData: Dictionary = _retrieve_packet()

	# Error handling
	match responseData.responseCode:
		_responseCodes.CONN_NOT_REGISTERED:
			_loggingModuleRef.wrn(["You must register before using this service"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.CONN_NOT_REGISTERED})
		
		_responseCodes.CONN_ALREADY_HOSTING:
			_loggingModuleRef.wrn(["You must destroy your current session before joining one"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.CONN_ALREADY_HOSTING})
		
		_responseCodes.CONN_ALREADY_IN_SESSION:
			_loggingModuleRef.wrn(["You must destroy your current session before joining one"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.CONN_ALREADY_IN_SESSION})
		
		_responseCodes.CONN_SESSION_IS_FULL:
			_loggingModuleRef.wrn(["The requested session is currently full"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.CONN_SESSION_IS_FULL})
		
		_responseCodes.CONN_SESSION_NOT_FOUND:
			_loggingModuleRef.wrn(["The requested session was not found"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.CONN_SESSION_NOT_FOUND})

		_responseCodes.AUTH_ACCESS_TOKEN_NOT_PROVIDED:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.AUTH_INVALID_TOKENS})
		
		_responseCodes.AUTH_CLIENT_TOKEN_NOT_PROVIDED:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.AUTH_CLIENT_TOKEN_NOT_PROVIDED})
		
		_responseCodes.SERVER_INTERNAL_ERROR:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.SERVER_INTERNAL_ERROR})

	# Log
	_loggingModuleRef.log(["Successfully joined new session"])

	# Toggle inSession and supply the session code
	_sessionDetails.inSession = true
	_sessionDetails.sessionCode = sessionCode

	return _LMethodResponseData.new({})

func sendPacket(packet: PoolByteArray) -> _LMethodResponseData:
	# Fix for weird yield issues
	yield(get_tree(), "idle_frame")

	# Check if we are NOT registered
	if !_sessionDetails.isRegistered:
		_loggingModuleRef.wrn(["You must register before using this service"])
		return _LMethodResponseData.new({"errorMessage": "You must register before using this service", "errorCode": _responseCodes.CONN_NOT_REGISTERED})
	
	# Check if we are NOT currently hosting
	if !_sessionDetails.inSession:
		_loggingModuleRef.wrn(["You must join or create a session before sending data"])
		return _LMethodResponseData.new({"errorMessage": "You must join or create a session before sending data", "errorCode": _responseCodes.CONN_SESSION_NOT_FOUND})
	
	# Format payload
	var payload: Dictionary = {
		"requestedRoute": "sendPacket",
		"authorizationBearer": "%s:%s" % [_authModuleRef._tokens["accessToken"], _lossConfigRef.clientID],
		"packetData": packet,
	}

	# Log
	_loggingModuleRef.log(["Attempting to send packets"])

	# Send request
	var sendError: int = _client.put_packet(to_json(payload).to_utf8())
	if sendError != OK:
		_loggingModuleRef.err(["Error while sending packets to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while sending packets to server", "errorCode": sendError})
	
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
	
	# Retrieve response
	var responseData: Dictionary = _retrieve_packet()

	# Error handling
	match responseData.responseCode:
		_responseCodes.CONN_NOT_REGISTERED:
			_loggingModuleRef.wrn(["You must register before using this service"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.CONN_NOT_REGISTERED})
		
		_responseCodes.CONN_SESSION_NOT_FOUND:
			_loggingModuleRef.wrn(["You must join or create a session before sending data"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.CONN_SESSION_NOT_FOUND})
		
		_responseCodes.AUTH_ACCESS_TOKEN_NOT_PROVIDED:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.AUTH_INVALID_TOKENS})
		
		_responseCodes.AUTH_CLIENT_TOKEN_NOT_PROVIDED:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.AUTH_CLIENT_TOKEN_NOT_PROVIDED})
		
		_responseCodes.SERVER_INTERNAL_ERROR:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.SERVER_INTERNAL_ERROR})

	# Log
	_loggingModuleRef.log(["Successfully sent packet"])

	return _LMethodResponseData.new({})

func destroySession() -> _LMethodResponseData:
	# Fix for weird yield issues
	yield(get_tree(), "idle_frame")

	# Check if we are NOT registered
	if !_sessionDetails.isRegistered:
		_loggingModuleRef.wrn(["You must register before using this service"])
		return _LMethodResponseData.new({"errorMessage": "You must register before using this service", "errorCode": _responseCodes.CONN_NOT_REGISTERED})
	
	# Check if we are NOT currently hosting
	if !_sessionDetails.inSession:
		_loggingModuleRef.wrn(["You must join or create a session before destroying a session"])
		return _LMethodResponseData.new({"errorMessage": "You must join or create a session before destroying a session", "errorCode": _responseCodes.CONN_SESSION_NOT_FOUND})
	
	# Format payload
	var payload: Dictionary = {
		"requestedRoute": "destroySession",
		"authorizationBearer": "%s:%s" % [_authModuleRef._tokens["accessToken"], _lossConfigRef.clientID],
	}

	# Log
	_loggingModuleRef.log(["Attempting to destroy session"])

	# Send request
	var sendError: int = _client.put_packet(to_json(payload).to_utf8())
	if sendError != OK:
		_loggingModuleRef.err(["Error while sending packets to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while sending packets to server", "errorCode": sendError})

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
	
	# Retrieve response
	var responseData: Dictionary = _retrieve_packet()

	# Error handling
	match responseData.responseCode:
		_responseCodes.CONN_NOT_REGISTERED:
			_loggingModuleRef.wrn(["You must register before using this service"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.CONN_NOT_REGISTERED})
		
		_responseCodes.CONN_SESSION_NOT_FOUND:
			_loggingModuleRef.wrn(["You must join or create a session before destroying a session"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.CONN_SESSION_NOT_FOUND})
		
		_responseCodes.AUTH_ACCESS_TOKEN_NOT_PROVIDED:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.AUTH_INVALID_TOKENS})
		
		_responseCodes.AUTH_CLIENT_TOKEN_NOT_PROVIDED:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.AUTH_CLIENT_TOKEN_NOT_PROVIDED})
		
		_responseCodes.SERVER_INTERNAL_ERROR:
			_loggingModuleRef.err(["Access token was not provided"])
			return _LMethodResponseData.new({"errorMessage": responseData.responseData.message, "errorCode": _responseCodes.SERVER_INTERNAL_ERROR})	

	# Log
	_loggingModuleRef.log(["Successfully destroyed session"])

	# Toggle inSession and supply the session code
	_sessionDetails.inSession = false
	_sessionDetails.sessionCode = ""

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

	# Organize data
	# Disregard empty packets (Means the server is offline)
	if decodedPacket.empty():
		return
	
	# Server type packets are for handling any errors/incoming data
	if decodedPacket.responseType == "SERVER":
		_serverPacketStorage.append(decodedPacket)
		return
	
	# Session type packets are for handling any session specific events
	if decodedPacket.responseType == "SESSION":
		match decodedPacket.responseCode:
			_responseCodes.SESSION_PEER_CONNECTED:
				emit_signal("peer_connected")
				return
			
			_responseCodes.SESSION_PEER_DISCONNECTED:
				emit_signal("peer_disconnected")
				return
			
			_responseCodes.SESSION_DESTROYED:
				emit_signal("session_destroyed")
				return
		return
	
	# Client type packets are for handling any client to client communication
	if decodedPacket.responseType == "CLIENT":
		emit_signal("packet_recieved", decodedPacket.responseData)
		return

func _retrieve_packet() -> Dictionary:
	return _serverPacketStorage.pop_front()

	

