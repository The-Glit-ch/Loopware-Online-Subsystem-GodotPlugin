# Tool

# Class & Extends
class_name Loss extends Node

# Docstring
# Loopware Online Subsystems @ Godot Plugin || Main file for the plugin
# This is like the *.h file in a CPP project. Contains the function defenitions
# Any data is then passed into the actual implementations located in "_impl" folder

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables

# Private Variables
var _LossConfig: Dictionary

# Onready Variables
onready var _LoggingSystem: _LoggingModule = _LoggingModule.new()
onready var _AuthorizationClass: _LAuthorizationClass = _LAuthorizationClass.new()


# _init()
func _init(config: Dictionary) -> void:
	_LossConfig = config

# _ready()
func _ready() -> void:
	# Core
	add_child(_AuthorizationClass)

	# Final configuration
	_LoggingSystem.enableDevLogging(_LossConfig.enableDeveloperLogs)


# _other()

# Public Methods
func registerClient() -> void:
	var resultRaw = yield(_AuthorizationClass.register(_LossConfig.authorizationServerURL, _LossConfig.clientID), "completed")
	var result: Dictionary = {
		"result": int(resultRaw[0]),
		"responseCode": int(resultRaw[1])
	}
	var responseCode: int = 
	var responseHeaders: PoolStringArray = PoolStringArray(resultRaw[2])
	var responseBody: Dictionary = parse_json(PoolByteArray(resultRaw[3]).get_string_from_utf8())
	print(result, responseCode, responseHeaders, responseBody)

# Private Methods
