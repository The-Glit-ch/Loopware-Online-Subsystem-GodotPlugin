# Tool

# Class & Extends
extends Node

# Docstring
# Loopware Online Subsystems @ Godot Plugin || Main file for the plugin
# This is like the *.h file in a CPP project. Contains the function defenitions
# Any data is then passed into the actual implementations located in "_impl" folder

# Signals

# Enums

# Constants
const VERSION_STRING: String = "1.0.0" #Major.Minor.BugFix

# Exported Variables

# Public Variables

# Private Variables
var _LossConfig: Dictionary
var _Logging: _LoggingModule
var _AuthorizationModule: _LAuthorizationClass


# Onready Variables

# _init()
# func _init() -> void:
# 	return

# _ready()
# func _ready() -> void:
# 	return

# _other()

# Public Methods
func initialize(config: Dictionary) -> void:
	# Store a copy of the configuation file
	_LossConfig = config

	# Initialize the logger
	_Logging = _LoggingModule.new()
	_Logging.enableDevLogging(_LossConfig.enableDeveloperLogs)

	# Logs
	_Logging.log(["Initializing Godot LossSDK v%s" % [VERSION_STRING]])
	_Logging.devLog(
		["Current Configuration\nClientID: \"%s\"\nAuthorization Server URL: \"%s\"\nDatastore Server URL: \"%s\"\nEnable Developer Logs: \"%s\"" 
		% [_LossConfig.clientID, _LossConfig.authorizationServerURL, _LossConfig.datastoreServerURL, _LossConfig.enableDeveloperLogs]])

	# Initialize the subsystems
	_AuthorizationModule = _LAuthorizationClass.new(_LossConfig)

	# Add subsystems to tree
	add_child(_AuthorizationModule)

func registerClient() -> void:
	var resultRaw = yield(_AuthorizationModule.register(_LossConfig.authorizationServerURL, _LossConfig.clientID), "completed")

# Private Methods
