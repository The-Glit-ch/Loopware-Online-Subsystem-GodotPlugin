# Tool

# Class
class_name _LUDPHolePunch

# Extends
extends Node

# Docstring
# Loopware Online Subsystem @ Godot Plugin || Net/Live: UDPHolePunch Module
# Contains methods and logic for UDP Hole Punching

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables

# Private Variables
# Ref
var _AuthorizationModule: _LAuthorizationClass
var _Logging: _LoggingModule
var _lossConfig: Dictionary
# Self
var _UDPClientPeer: PacketPeerUDP
var _UDPServerAddress: Dictionary
var _UDPTimeout: Timer

# Onready Variables

# _init()
func _init(authorizationRefrence: _LAuthorizationClass, loggingModule: _LoggingModule, lossConfig: Dictionary) -> void:
	# Save reference
	_AuthorizationModule = authorizationRefrence
	_Logging = loggingModule
	_lossConfig = lossConfig
	
	# Config
	_UDPServerAddress = {"IP": _lossConfig.UDPPunchThroughServer[0], "PORT": _lossConfig.UDPPunchThroughServer[1]}

	# UDP Timeout
	_UDPTimeout = Timer.new()
	_UDPTimeout.wait_time = 10.0
	_UDPTimeout.autostart = false
	_UDPTimeout.one_shot = true
	_UDPTimeout.name = "LossAPU-UDPTimeout"
	add_child(_UDPTimeout)

# _ready()
# func _ready() -> void:
#     returns

# _other()

# Public Methods
func createNewClient() -> void:
	# Check if already connected to server
	if _is_udp_connected(_UDPClientPeer):
		_Logging.log(["Already connected to UDP server"])
		return yield(get_tree(), "idle_frame")

	# Logs
	_Logging.log(["Creating new UDP Punchthrough Client"])
	_Logging.devLog(["Server IP: %s || Server Port: %s" % [_UDPServerAddress.IP, _UDPServerAddress.PORT]])

	# Create a new UDP client and connect to remote
	_UDPClientPeer = PacketPeerUDP.new()
	var remoteConnectionError: int = _UDPClientPeer.connect_to_host(_UDPServerAddress.IP, _UDPServerAddress.PORT)

	# Error handling
	if remoteConnectionError:
		_Logging.log(["Error while attempting to connect to UDP Punchthrough Server"])
		_Logging.devLog(["Gonna be honest, got no clue how this can fail"])
		return

	# Logs
	_Logging.log(["Sending connection confirmation message"])

	# Send confirmation message to server
	var data: Dictionary = {"connectionType": "Registration"}
	var confirmationSendError: int = _send_packet(_UDPClientPeer, data)

	# Error handling
	if confirmationSendError:
		_Logging.log(["Error while sending connection confirmation message"])
		return

	# Logs
	_Logging.log(["Message sent || Awaiting confirmation"])

	# Wait/Poll for confirmation response
	_UDPTimeout.start()
	var retries: int = 0
	while _UDPClientPeer.get_available_packet_count() == 0:
		if _UDPTimeout.time_left == 0:
			_Logging.log(["UDP Confirmation Timeout. Is the server online?"])
			_UDPClientPeer.close()
			return
		else:
			yield(get_tree().create_timer(1), "timeout")
			retries += 1
			_send_packet(_UDPClientPeer, {"connectionType": "Registration"})
			_Logging.log(["...(%s)" % [retries]])

	# Check for confirmation repsonse
	var incomingPacket: Dictionary = _decode_packet(_UDPClientPeer.get_packet())
	if incomingPacket.empty():
		_Logging.log(["UDP connection failed. Is the server offline?"])
		return yield(get_tree(), "idle_frame") # Avoid yield/async errors

	if incomingPacket["message"] == "Connected":
		_Logging.log(["UDP connection confirmed"])
		return

func createNewSession() -> void:
	pass

func connectToSession() -> void:
	pass

# Private Methods
func _is_udp_connected(udpSocket: PacketPeerUDP) -> bool:
	if !is_instance_valid(udpSocket):
		return false
	
	if !udpSocket.is_connected_to_host():
		return false
	
	return true

func _send_packet(udpSocket: PacketPeerUDP, data: Dictionary) -> int:
	return udpSocket.put_packet(to_json(data).to_utf8())

func _decode_packet(rawPacket: PoolByteArray) -> Dictionary:
	if rawPacket.empty(): return {}
	return parse_json(rawPacket.get_string_from_utf8())
