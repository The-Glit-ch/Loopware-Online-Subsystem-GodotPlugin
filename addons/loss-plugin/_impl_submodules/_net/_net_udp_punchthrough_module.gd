# Tool

# Class
class_name _LNetUDPPucnthroughServiceModule

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
var _client: PacketPeerUDP
var _secureClient: PacketPeerDTLS

# Onready Variables

# _init()
func _init(loggingModuleReference: _LLoggingModule, lossConfigurationReference: Dictionary, authorizationModuleReference: _LAuthorizationClass) -> void:
	# Save the refrences
	_loggingModuleRef = loggingModuleReference
	_authModuleRef = authorizationModuleReference
	_lossConfigRef = lossConfigurationReference

# _ready()
# func _ready() -> void:
#     returns

# _other()

# Public Methods

# Private Methods
