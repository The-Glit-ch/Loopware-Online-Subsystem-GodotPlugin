# Tool

# Class
class_name _LUDPHolePunch

# Extends
extends Node

# Docstring
# Loopware Online Subsystem @ Godot Plugin || Net/Live: UDPHolePunch Module
# Contains methods and logic for UDP Hole Punching
# TODO: Implement auto reconnect when we dont recieve a server heartbeat

# Signals
signal serverOffline

# Enums

# Constants

# Exported Variables

# Public Variables

# Private Variables
# References
var _AuthorizationModule: _LAuthorizationClass
var _Logging: _LoggingModule
var _lossConfig: Dictionary

# Self
var _clientCommunicationPacketBacklog: Array
var _serverCommunicationPacketBacklog: Array
var _UDPClientPeer: PacketPeerUDP
var _UDPServerAddress: Dictionary
var _UDPServerHeartbeat: Timer
var _UDPResponseCodes: Dictionary = {
	CONN_ACKNOWLEDGED="CONN_ACKNOWLEDGED",
	CONN_ESTABLISHED="CONN_ESTABLISHED",
	CONN_ALR_ESTABLISHED="CONN_ALR_ESTABLISHED",
	CONN_NOT_REGISTERED="CONN_NOT_REGISTERED",
	CONN_ALR_HOSTING="CONN_ALR_HOSTING",
	CONN_ALR_IN_SESSION="CONN_ALR_IN_SESSION",
	CONN_SESSION_NOT_FOUND="CONN_SESSION_NOT_FOUND",
	AUTH_ACCESS_TOKEN_INVALID="AUTH_ACCESS_TOKEN_INVALID",
	AUTH_CLIENT_TOKEN_INVALID="AUTH_CLIENT_TOKEN_INVALID",
	SERVER_HEARTBEAT="SERVER_HEARTBEAT"
}

# Onready Variables

# _init()
func _init(authorizationReference: _LAuthorizationClass, loggingModule: _LoggingModule, lossConfig: Dictionary) -> void:
	# Save reference
	_AuthorizationModule = authorizationReference
	_Logging = loggingModule
	_lossConfig = lossConfig
	
	# Config
	_UDPServerAddress = {"IP": _lossConfig.UDPPunchThroughServer[0], "PORT": _lossConfig.UDPPunchThroughServer[1]}

	# Server heatbeat
	_UDPServerHeartbeat = Timer.new()
	_UDPServerHeartbeat.wait_time = 5
	_UDPServerHeartbeat.autostart = false
	_UDPServerHeartbeat.one_shot = true
	_UDPServerHeartbeat.name = "LossAPI-ServerHeartbeat"
	_UDPServerHeartbeat.connect("timeout", self, "_serverDisconnected")
	add_child(_UDPServerHeartbeat)
	

# _ready()
# func _ready() -> void:
#     returns

# _other()
func _process(delta: float) -> void:
	_poll_for_packets()

# Public Methods
func createNewClient() -> _LMethodResponseData:
	# I am at a *loss* of words ON WHY THIS HAS TO BE HERE
	# PLEASE JUST ADD NORMAL ASYNC/AWAIT
	yield(get_tree(), "idle_frame")

	# Check if already connected to server
	if _is_udp_connection_valid():
		_Logging.wrn(["Already connected to UDP \"TURN\" server"])
		return _LMethodResponseData.new({"errorMessage": "UDP connection already established", "errorCode": _UDPResponseCodes.CONN_ALR_ESTABLISHED})

	# Logs
	_Logging.log(["Creating new UDP punchthrough client"])
	_Logging.devLog(["Server IP: %s || Server Port: %s" % [_UDPServerAddress.IP, _UDPServerAddress.PORT]])

	# Create a new UDP client and connect to remote
	_UDPClientPeer = PacketPeerUDP.new()
	var remoteConnectionError: int = _UDPClientPeer.connect_to_host(_UDPServerAddress.IP, _UDPServerAddress.PORT)

	# Error handling
	if remoteConnectionError:
		_Logging.err(["Error while attempting to connect to UDP \"TURN\" server || Code: %s" % [remoteConnectionError]])
		return _LMethodResponseData.new({"errorMessage": "Error while trying to connect to UDP \"TURN\" server", "errorCode": remoteConnectionError})

	# Send registration request to server
	var registrationData: Dictionary = {"connectionType": "Registration", "authorization": _AuthorizationModule._returnAccessJWT()}
	var registrationSendError: int = _send_packet(registrationData)

	# Error handling
	if registrationSendError:
		_Logging.err(["Error while sending registration message || Code: %s" % [registrationSendError]])
		return _LMethodResponseData.new({"errorMessage": "Error while sending registration data", "errorCode": registrationSendError})

	# Logs
	_Logging.log(["Request sent || Awaiting confirmation"])

	# Wait/Poll for confirmation response
	var secondsPassed: int = 0
	while _serverCommunicationPacketBacklog.size() == 0:
		if secondsPassed == 20:
			_Logging.err(["UDP Connection Timeout || Is the server offline?"])
			return _LMethodResponseData.new({"errorMessage": "UDP registration timeout"})
		else:
			yield(get_tree().create_timer(1), "timeout")
			_Logging.log(["Waiting...(%s seconds passed)" % [secondsPassed]])
			secondsPassed += 1		

	# Retrieve repsonse
	var incomingPacket: Dictionary = _retrieve_packet_type("server")
	
	# Status handling
	if incomingPacket.empty():
		_Logging.err(["UDP connection failed"])
		return _LMethodResponseData.new({"errorMessage": "UDP connection failed"})
	
	if incomingPacket["code"] == _UDPResponseCodes.AUTH_ACCESS_TOKEN_INVALID:
		_Logging.err(["Invalid access token || Please refresh your token"])
		return _LMethodResponseData.new({"errorMessage": _UDPResponseCodes.AUTH_ACCESS_TOKEN_INVALID})
	
	if incomingPacket["code"] == _UDPResponseCodes.AUTH_CLIENT_TOKEN_INVALID:
		_Logging.err(["Invalid client token || How?"])
		return _LMethodResponseData.new({"errorMessage": _UDPResponseCodes.AUTH_ACCESS_TOKEN_INVALID})
	
	if incomingPacket["code"] == _UDPResponseCodes.CONN_ALR_ESTABLISHED:
		_Logging.wrn(["You're already connected to the server || You shouldn't even be able to get this error"])
		return _LMethodResponseData.new({"errorMessage": _UDPResponseCodes.CONN_ALR_ESTABLISHED})
	
	if incomingPacket["code"] == _UDPResponseCodes.CONN_ESTABLISHED:
		_Logging.log(["Connection established"])
		return _LMethodResponseData.new({})
	
	return _LMethodResponseData.new({})

func createNewSession() -> _LMethodResponseData:
	# Async/yield
	yield(get_tree(), "idle_frame")

	# Check if we are connected to the server
	if !_is_udp_connection_valid():
		_Logging.wrn(["Not connected to UDP \"TURN\" Server"])
		return _LMethodResponseData.new({"errorMessage": "Not connected to server"})
	
	# Logs
	_Logging.log(["Creating new UDP session"])
	_Logging.devLog(["Server IP: %s || Server Port: %s" % [_UDPServerAddress.IP, _UDPServerAddress.PORT]])

	# Send createSession request
	var createSessionData: Dictionary = {"connectionType": "CreateSession", "authorization": _AuthorizationModule._returnAccessJWT()}
	var createSessionError: int = _send_packet(createSessionData)

	# Error handling
	if createSessionError:
		_Logging.err(["Error while sending create session request || Code: %s" % createSessionError])
		return _LMethodResponseData.new({"errorMessage": "Error while creating session", "errorCode": createSessionError})
	
	# Logs
	_Logging.log(["Request sent || Awaiting confirmation"])

	# Wait/Poll for confirmation response
	var secondsPassed: int = 0
	while _serverCommunicationPacketBacklog.size() == 0:
		if secondsPassed == 20:
			_Logging.err(["UDP Connection Timeout || Is the server offline?"])
			return _LMethodResponseData.new({"errorMessage": "UDP connection timeout"})
		else:
			yield(get_tree().create_timer(1), "timeout")
			_Logging.log(["Waiting...(%s seconds passed)" % [secondsPassed]])
			secondsPassed += 1	
	
	# Retrieve repsonse
	var incomingPacket: Dictionary = _retrieve_packet_type("server")

	# Status handling
	if incomingPacket.empty():
		_Logging.err(["UDP connection failed"])
		return _LMethodResponseData.new({"errorMessage": "UDP connection failed"})

	if incomingPacket["code"] == _UDPResponseCodes.AUTH_ACCESS_TOKEN_INVALID:
		_Logging.err(["Invalid access token || Please refresh your token"])
		return _LMethodResponseData.new({"errorMessage": _UDPResponseCodes.AUTH_ACCESS_TOKEN_INVALID})

	if incomingPacket["code"] == _UDPResponseCodes.AUTH_CLIENT_TOKEN_INVALID:
		_Logging.err(["Invalid client token || How?"])
		return _LMethodResponseData.new({"errorMessage": _UDPResponseCodes.AUTH_ACCESS_TOKEN_INVALID})

	if incomingPacket["code"] == _UDPResponseCodes.CONN_NOT_REGISTERED:
		_Logging.wrn(["Not registered with UDP server"])
		return _LMethodResponseData.new({"errorMessage": _UDPResponseCodes.CONN_NOT_REGISTERED})

	if incomingPacket["code"] == _UDPResponseCodes.CONN_ALR_HOSTING:
		_Logging.wrn(["Already hosting a session. Destroy your current session to make new ones"])
		return _LMethodResponseData.new({"errorMessage": _UDPResponseCodes.CONN_ALR_HOSTING})
	
	if incomingPacket["code"] == _UDPResponseCodes.CONN_SESSION_NOT_FOUND:
		_Logging.wrn(["Session not found/invalid"])
		return _LMethodResponseData.new({"errorMessage": _UDPResponseCodes.CONN_SESSION_NOT_FOUND})
	
	if incomingPacket["code"] == _UDPResponseCodes.CONN_ACKNOWLEDGED:
		_Logging.log(["Successfully created a new session"])
		return _LMethodResponseData.new({"returnData": {"joinCode": incomingPacket["data"]}})
	
	return _LMethodResponseData.new({})

func joinSession(joinCode: String) -> _LMethodResponseData:
	# Async/yield
	yield(get_tree(), "idle_frame")

	# Check if we are connected to the server
	if !_is_udp_connection_valid():
		_Logging.wrn(["Not connected to UDP \"TURN\" Server"])
		return _LMethodResponseData.new({"errorMessage": "Not connected to server"})
	
	# Logs
	_Logging.log(["Attempting to join session"])
	_Logging.devLog(["Server IP: %s || Server Port: %s" % [_UDPServerAddress.IP, _UDPServerAddress.PORT]])

	# Send joinSession request
	var joinSessionData: Dictionary = {"connectionType": "JoinSession", "authorization": _AuthorizationModule._returnAccessJWT(), "joinCode": joinCode}
	var joinSessionError: int = _send_packet(joinSessionData)

	# Error handling
	if joinSessionError:
		_Logging.err(["Error while sending create session request || Code: %s" % joinSessionError])
		return _LMethodResponseData.new({"errorMessage": "Error while creating session", "errorCode": joinSessionError})

	# Logs
	_Logging.log(["Request sent || Awaiting confirmation"])

	# Wait/Poll for confirmation response
	var secondsPassed: int = 0
	while _serverCommunicationPacketBacklog.size() == 0:
		if secondsPassed == 20:
			_Logging.err(["UDP Connection Timeout || Is the server offline?"])
			return _LMethodResponseData.new({"errorMessage": "UDP connection timeout"})
		else:
			yield(get_tree().create_timer(1), "timeout")
			_Logging.log(["Waiting...(%s seconds passed)" % [secondsPassed]])
			secondsPassed += 1
	
	# Retrieve repsonse
	var incomingPacket: Dictionary = _retrieve_packet_type("server")

	# Status handling
	if incomingPacket.empty():
		_Logging.err(["UDP connection failed"])
		return _LMethodResponseData.new({"errorMessage": "UDP connection failed"})

	if incomingPacket["code"] == _UDPResponseCodes.AUTH_ACCESS_TOKEN_INVALID:
		_Logging.err(["Invalid access token || Please refresh your token"])
		return _LMethodResponseData.new({"errorMessage": _UDPResponseCodes.AUTH_ACCESS_TOKEN_INVALID})

	if incomingPacket["code"] == _UDPResponseCodes.AUTH_CLIENT_TOKEN_INVALID:
		_Logging.err(["Invalid client token || How?"])
		return _LMethodResponseData.new({"errorMessage": _UDPResponseCodes.AUTH_ACCESS_TOKEN_INVALID})
	
	if incomingPacket["code"] == _UDPResponseCodes.CONN_NOT_REGISTERED:
		_Logging.wrn(["Not registered with UDP server"])
		return _LMethodResponseData.new({"errorMessage": _UDPResponseCodes.CONN_NOT_REGISTERED})

	if incomingPacket["code"] == _UDPResponseCodes.CONN_ALR_HOSTING:
		_Logging.wrn(["Already hosting a session. Destroy your current session to join a session"])
		return _LMethodResponseData.new({"errorMessage": _UDPResponseCodes.CONN_ALR_HOSTING})
	
	if incomingPacket["code"] == _UDPResponseCodes.CONN_ALR_IN_SESSION:
		_Logging.wrn(["Already in a session. Destroy your current session to join a session"])
		return _LMethodResponseData.new({"errorMessage": _UDPResponseCodes.CONN_ALR_IN_SESSION})

	if incomingPacket["code"] == _UDPResponseCodes.CONN_ACKNOWLEDGED:
		_Logging.log(["Successfully joined session"])
		return _LMethodResponseData.new({})
	
	return _LMethodResponseData.new({})

# Private Methods
func _is_udp_connection_valid() -> bool:
	if !is_instance_valid(_UDPClientPeer) or !_UDPClientPeer.is_connected_to_host(): return false
	return true

func _send_packet(data: Dictionary) -> int:
	return _UDPClientPeer.put_packet(to_json(data).to_utf8())

func _decode_packet(rawPacket: PoolByteArray) -> Dictionary:
	if rawPacket.empty(): return {}
	return parse_json(rawPacket.get_string_from_utf8())

func _retrieve_packet_type(packetType: String) -> Dictionary:
	if packetType == "server":
		var fetchedPacket: Dictionary = _serverCommunicationPacketBacklog[0]
		_serverCommunicationPacketBacklog.remove(0)
		_Logging.devLog(["Fetched server packet and removed it from backlog"])
		return fetchedPacket
	elif packetType == "client":
		var fetchedPacket: Dictionary = _clientCommunicationPacketBacklog[0]
		_serverCommunicationPacketBacklog.remove(0)
		_Logging.devLog(["Fetched client packet and removed it from backlog"])
		return fetchedPacket
	
	return {}

func _poll_for_packets() -> void:
	# Handles polling for packets
	if _is_udp_connection_valid():
		if _UDPClientPeer.get_available_packet_count() > 0:
			# Logs
			_Logging.devLog(["New packet recieved || Now decoding"])

			# Decode packet and categorize it
			var decodedPacket: Dictionary = _decode_packet(_UDPClientPeer.get_packet())
			
			# Server communication gets priority
			if decodedPacket["type"] == "SERVER_COMM":
				_serverCommunicationPacketBacklog.append(decodedPacket)
				_Logging.devLog(["New server packet added"])
				return
			elif decodedPacket["type"] == "CLIENT_COMM":
				_clientCommunicationPacketBacklog.append(decodedPacket)
				_Logging.devLog(["New client packet added"])
				return
			elif decodedPacket["type"] == "SERVER_COMM_HEARTBEAT":
				_send_packet({"connectionType": "ClientHeartbeat", "authorization": _AuthorizationModule._returnAccessJWT()})
				_UDPServerHeartbeat.start()

func _serverDisconnected() -> void:
	_UDPClientPeer.close()
	_Logging.log(["UDP \"TURN\" Server went offline"])
	emit_signal("serverOffline")
