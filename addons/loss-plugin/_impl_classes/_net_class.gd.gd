# Tool

# Class
class_name _LNetClass

# Extends
extends Node

# Docstring
# Loopware Online Subsystem Godot Plugin @ Net Class || Parent class that
# contain submodules that relate to the Net Service

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables
var UDPPunchthroughService: _LNetUDPPunchthroughServiceModule

# Private Variables

# Onready Variables

# _init()
func _init(loggingModuleReference: _LLoggingModule, lossConfigurationReference: Dictionary, authorizationModuleReference: _LAuthorizationClass) -> void:
	# Initiate submodules
	UDPPunchthroughService = _LNetUDPPunchthroughServiceModule.new(loggingModuleReference, lossConfigurationReference, authorizationModuleReference)

	# Add to scene tree
	add_child(UDPPunchthroughService)


# _ready()
# func _ready() -> void:
#     returns

# _other()

# Public Methods

# Private Methods
