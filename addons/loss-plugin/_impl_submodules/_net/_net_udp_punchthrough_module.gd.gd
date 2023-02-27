# Tool

# Class
class_name _LNetUDPPunchthroughServiceModule

# Extends
extends Node

# Docstring
# Loopware Online Subsystem Godot Plugin @ UDP Punchthrough Service Module || Provides an easy to use
# Punchthrough client for making P2P multiplayer sessions | More info -> https://en.wikipedia.org/wiki/UDP_hole_punching
# WARNING: TOKENS ARE NOT ENCRYPTED MEANING ANYONE CAN JUST SNATCH THEM || MASSIVE FUCKING SECRUITY VULNERABILITY
# TODO: ADD TLS/SSL SUPPORT

# Signals

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
var _serverPacketsBacklog: Array
var _clientPacketsBacklog: Array
var _udpClient: PacketPeerUDP
var _serverIP: String
var _serverPort: int
var _responseCodes: Dictionary = {
	CONN_ACKNOWLEDGED="CONN_ACKNOWLEDGED",
	CONN_ALREADY_REGISTERED="CONN_ALREADY_REGISTERED",
	CONN_NOT_REGISTERED="CONN_NOT_REGISTERED",
	CONN_ALREADY_HOSTING="CONN_ALREADY_HOSTING",
	CONN_ALREADY_IN_SESSION="CONN_ALREADY_IN_SESSION",
	CONN_SESSION_NOT_FOUND="CONN_SESSION_NOT_FOUND",
	AUTH_TOKENS_NOT_PROVIDED="AUTH_TOKENS_NOT_PROVIDED",
	AUTH_INVALID_TOKEN="AUTH_INVALID_TOKEN",
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

	# Create UDP Client
	_udpClient = PacketPeerUDP.new()


# _ready()
# func _ready() -> void:
#     returns

# _other()
func _process(_delta: float) -> void:
	_poll_for_packets()

# Public Methods
func registerClient() -> _LMethodResponseData:
	# Fix wierd async issues
	yield(get_tree(), "idle_frame")

	# Check if we are already registered
	if _isConnected():
		_loggingModuleRef.wrn(["Already registered with UDP Punchthrough service"])
		return _LMethodResponseData.new({"errorMessage": "Already connected"})

	# Format payload
	var payload: Dictionary = {
		"route": "registerClient",
		"authorizationBearer": "%s:%s" % [_authModuleRef._tokens["accessToken"], _lossConfigRef.clientID]
	}

	# Log
	_loggingModuleRef.log(["Attempting to connect to server"])

	# Connect to the server
	var connectionError: int = _udpClient.connect_to_host(_serverIP, _serverPort)

	# Error handling
	if connectionError != OK:
		_loggingModuleRef.err(["Error connecting to server"])
		return _LMethodResponseData.new({"errorMessage": "Error connecting to server", "errorCode": connectionError})

	# Log
	_loggingModuleRef.log(["Connected to server | Attempting to send create client request"])

	# Send request
	var sendError: int = _udpClient.put_packet(to_json(payload).to_utf8())

	# Error handling
	if sendError != OK:
		_loggingModuleRef.err(["Error while sending packets to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while sending packets to server", "errorCode": sendError})

	# Log
	_loggingModuleRef.log(["Request sent | Waiting for a response"])

	# Wait for response
	var secondsPassed: int = 0
	while _serverPacketsBacklog.size() == 0:
		if secondsPassed == 20:
			_loggingModuleRef.err(["UDP connection timeout || Is the server offline?"])
			return _LMethodResponseData.new({"errorMessage": "UDP connection timeout"})
		else:
			yield(get_tree().create_timer(1), "timeout")
			_loggingModuleRef.log(["Waiting...(%s seconds passed)" % [secondsPassed]])
			secondsPassed += 1

	# Log
	_loggingModuleRef.log(["Response recieved | Decoding"])

	# Retrieve response
	var responseData: Dictionary = _retrieve_packet("server")

	# Error handling
	if responseData.empty():
		_loggingModuleRef.err(["Server connection failed"])
		return _LMethodResponseData.new({"errorMessagee": "Server connection failed"})

	match responseData.responseCode:
		_responseCodes.AUTH_TOKENS_NOT_PROVIDED:
			_loggingModuleRef.err(["Server Response: ", responseData.responseMessage])
			return _LMethodResponseData.new({"errorMessage": responseData.responseMessage, "errorCode": _responseCodes.AUTH_TOKENS_NOT_PROVIDED})

		_responseCodes.AUTH_INVALID_TOKEN:
			_loggingModuleRef.err(["Server Response: ", responseData.responseMessage])
			return _LMethodResponseData.new({"errorMessage": responseData.responseMessage, "errorCode": _responseCodes.AUTH_INVALID_TOKEN})
		
		_responseCodes.SERVER_INTERNAL_ERROR:
			_loggingModuleRef.err(["Server Response: ", responseData.responseMessage])
			return _LMethodResponseData.new({"errorMessage": responseData.responseMessage, "errorCode": _responseCodes.SERVER_INTERNAL_ERROR})

	# Log
	_loggingModuleRef.log(["Server Response:", responseData.responseMessage])

	return _LMethodResponseData.new({})

func createSession(maxPlayers: int = 10, sessionName: String = "") -> _LMethodResponseData:
	# Fix wierd async issues
	yield(get_tree(), "idle_frame")

	# Check if we are not registered
	if !_isConnected():
		_loggingModuleRef.wrn(["Not registered | Register before using UDP Punchthrough service"])
		return _LMethodResponseData.new({"errorMessage": "Not registered | Register before using UDP Punchthrough service"})
	
	# Format payload
	var payload: Dictionary = {
		"route": "createSession",
		"authorizationBearer": "%s:%s" % [_authModuleRef._tokens["accessToken"], _lossConfigRef.clientID],
		"maxPlayers": abs(maxPlayers),
		"sessionName": sessionName,
	}

	# Log
	_loggingModuleRef.log(["Attempting to create a new session"])

	# Send request
	var sendError: int = _udpClient.put_packet(to_json(payload).to_utf8())

	# Error handling
	if sendError != OK:
		_loggingModuleRef.err(["Error while sending packets to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while sending packets to server", "errorCode": sendError})
	
	# Log
	_loggingModuleRef.log(["Request sent | Waiting for a response"])

	# Wait for response
	var secondsPassed: int = 0
	while _serverPacketsBacklog.size() == 0:
		if secondsPassed == 20:
			_loggingModuleRef.err(["UDP connection timeout || Is the server offline?"])
			return _LMethodResponseData.new({"errorMessage": "UDP connection timeout"})
		else:
			yield(get_tree().create_timer(1), "timeout")
			_loggingModuleRef.log(["Waiting...(%s seconds passed)" % [secondsPassed]])
			secondsPassed += 1

	# Log
	_loggingModuleRef.log(["Response recieved | Decoding"])

	# Retrieve response
	var responseData: Dictionary = _retrieve_packet("server")

	# Error handling
	if responseData.empty():
		_loggingModuleRef.err(["Server connection failed"])
		return _LMethodResponseData.new({"errorMessagee": "Server connection failed"})

	match responseData.responseCode:
		_responseCodes.CONN_ALREADY_HOSTING:
			_loggingModuleRef.err(["Server Response: ", responseData.responseMessage])
			return _LMethodResponseData.new({"errorMessage": responseData.responseMessage, "errorCode": _responseCodes.CONN_ALREADY_HOSTING})

		_responseCodes.CONN_ALREADY_IN_SESSION:
			_loggingModuleRef.err(["Server Response: ", responseData.responseMessage])
			return _LMethodResponseData.new({"errorMessage": responseData.responseMessage, "errorCode": _responseCodes.CONN_ALREADY_IN_SESSION})

		_responseCodes.AUTH_TOKENS_NOT_PROVIDED:
			_loggingModuleRef.err(["Server Response: ", responseData.responseMessage])
			return _LMethodResponseData.new({"errorMessage": responseData.responseMessage, "errorCode": _responseCodes.AUTH_TOKENS_NOT_PROVIDED})

		_responseCodes.AUTH_INVALID_TOKEN:
			_loggingModuleRef.err(["Server Response: ", responseData.responseMessage])
			return _LMethodResponseData.new({"errorMessage": responseData.responseMessage, "errorCode": _responseCodes.AUTH_INVALID_TOKEN})
		
		_responseCodes.SERVER_INTERNAL_ERROR:
			_loggingModuleRef.err(["Server Response: ", responseData.responseMessage])
			return _LMethodResponseData.new({"errorMessage": responseData.responseMessage, "errorCode": _responseCodes.SERVER_INTERNAL_ERROR})

	# Log
	_loggingModuleRef.log(["Server Response:", responseData.responseMessage])

	return _LMethodResponseData.new({})

func findSessions() -> _LMethodResponseData:
	# Fix wierd async issues
	yield(get_tree(), "idle_frame")

	# Check if we are not registered
	if !_isConnected():
		_loggingModuleRef.wrn(["Not registered | Register before using UDP Punchthrough service"])
		return _LMethodResponseData.new({"errorMessage": "Not registered | Register before using UDP Punchthrough service"})

	# Format payload
	var payload: Dictionary = {
		"route": "findSessions",
		"authorizationBearer": "%s:%s" % [_authModuleRef._tokens["accessToken"], _lossConfigRef.clientID],
	}
	
	# Log
	_loggingModuleRef.log(["Attempting to find sessions"])

	# Send request
	var sendError: int = _udpClient.put_packet(to_json(payload).to_utf8())

	# Error handling
	if sendError != OK:
		_loggingModuleRef.err(["Error while sending packets to server"])
		return _LMethodResponseData.new({"errorMessage": "Error while sending packets to server", "errorCode": sendError})

	# Log
	_loggingModuleRef.log(["Request sent | Waiting for a response"])

	# Wait for response
	var secondsPassed: int = 0
	while _serverPacketsBacklog.size() == 0:
		if secondsPassed == 20:
			_loggingModuleRef.err(["UDP connection timeout || Is the server offline?"])
			return _LMethodResponseData.new({"errorMessage": "UDP connection timeout"})
		else:
			yield(get_tree().create_timer(1), "timeout")
			_loggingModuleRef.log(["Waiting...(%s seconds passed)" % [secondsPassed]])
			secondsPassed += 1

	# Log
	_loggingModuleRef.log(["Response recieved | Decoding"])

	# Retrieve response
	var responseData: Dictionary = _retrieve_packet("server")

	# Error handling
	if responseData.empty():
		_loggingModuleRef.err(["Server connection failed"])
		return _LMethodResponseData.new({"errorMessagee": "Server connection failed"})

	match responseData.responseCode:
		_responseCodes.AUTH_TOKENS_NOT_PROVIDED:
			_loggingModuleRef.err(["Server Response: ", responseData.responseMessage])
			return _LMethodResponseData.new({"errorMessage": responseData.responseMessage, "errorCode": _responseCodes.AUTH_TOKENS_NOT_PROVIDED})

		_responseCodes.AUTH_INVALID_TOKEN:
			_loggingModuleRef.err(["Server Response: ", responseData.responseMessage])
			return _LMethodResponseData.new({"errorMessage": responseData.responseMessage, "errorCode": _responseCodes.AUTH_INVALID_TOKEN})
		
		_responseCodes.SERVER_INTERNAL_ERROR:
			_loggingModuleRef.err(["Server Response: ", responseData.responseMessage])
			return _LMethodResponseData.new({"errorMessage": responseData.responseMessage, "errorCode": _responseCodes.SERVER_INTERNAL_ERROR})
	
	# Log
	_loggingModuleRef.log(["Server Response:", responseData.responseMessage.message])

	return _LMethodResponseData.new({"returnData": responseData.responseMessage.foundSessions})


# Private Methods
func _poll_for_packets() -> void:
	# Check if we are connected to the server
	if !_isConnected():
		return

	# Check if we have a packet
	if _udpClient.get_available_packet_count() > 0:
		# Decode the packet
		var decodedPacket: Dictionary = _decodePacket(_udpClient.get_packet())

		# Sort the packets
		if decodedPacket.responseType == "SERVER":
			_serverPacketsBacklog.append(decodedPacket)
			return
		
		if decodedPacket.responseType == "CLIENT":
			_clientPacketsBacklog.append(decodedPacket)
			return

func _decodePacket(packetData: PoolByteArray) -> Dictionary:
	if packetData.empty():
		return {}
	
	return parse_json(packetData.get_string_from_utf8())

func _retrieve_packet(packetType: String) -> Dictionary:
	match packetType:
		"server":
			return _serverPacketsBacklog.pop_front()
		"client":
			return _clientPacketsBacklog.pop_front()
	
	return {}

func _isConnected() -> bool:
	return _udpClient.is_connected_to_host()
