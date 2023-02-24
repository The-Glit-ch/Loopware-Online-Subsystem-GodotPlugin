# Tool

# Class
class_name _LNetUDPPunchthroughServiceModule

# Extends
extends Node

# Docstring
# Loopware Online Subsystem Godot Plugin @ UDP Punchthrough Service Module || Provides an easy to use
# Punchthrough client for making P2P multiplayer sessions | More info -> https://en.wikipedia.org/wiki/UDP_hole_punching

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
var _udpClient: PacketPeerUDP
var _serverIP: String
var _serverPort: int

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


# _ready()
# func _ready() -> void:
#     returns

# _other()

# Public Methods
func createNewClient() -> _LMethodResponseData:
	# Fix wierd async issues
	yield(get_tree(), "idle_frame")

	# Check if we are already registered
	if _isConnected():
		return _LMethodResponseData.new({"errorMessage": "Already connected"})

	return _LMethodResponseData.new({})

# Private Methods
func _isConnected() -> bool:
	return self.is_connected_to_host()
