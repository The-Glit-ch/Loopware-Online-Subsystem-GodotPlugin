# Tool

# Class
class_name _LNetLiveClass

# Extends
extends Node

# Docstring
# Loopware Online Subsystem @ Godot Plugin || Net/Live
# Net/Live class that contains modules specific to the Net/Live service

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables
var UDPHolePunch: _LUDPHolePunch

# Private Variables
var _AuthorizationModule: _LAuthorizationClass
var _Logging: _LoggingModule
var _lossConfig: Dictionary


# Onready Variables
func _init(authorizationRefrence: _LAuthorizationClass, loggingModule: _LoggingModule, lossConfig: Dictionary) -> void:
	# Save reference
	_AuthorizationModule = authorizationRefrence
	_Logging = loggingModule
	_lossConfig = lossConfig

	# Subsystems
	UDPHolePunch = _LUDPHolePunch.new(_AuthorizationModule, _Logging, _lossConfig)
	add_child(UDPHolePunch)

# _ready()
# func _ready() -> void:
#     returns

# _other()

# Public Methods

# Private Methods
