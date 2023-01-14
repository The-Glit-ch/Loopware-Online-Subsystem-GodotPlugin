# Confuscion 2.0
# --A funny person


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
var DatastoreModule: _LDatastoreClass

# Private Variables
var _Logging: _LoggingModule
var _AuthorizationModule: _LAuthorizationClass
var _lossConfig: Dictionary


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
	_lossConfig = config

	# Initialize the logger
	_Logging = _LoggingModule.new()
	_Logging.enableDevLogging(_lossConfig.enableDeveloperLogs)

	# Logs
	_Logging.log(["Initializing Godot LossSDK v%s" % [VERSION_STRING]])
	_Logging.devLog(
		["\n\n----[Start Current Configuration]----\nClientID: \"%s\"\nAuthorization Server URL: \"%s\"\nDatastore Server URL: \"%s\"\nEnable Developer Logs: \"%s\"\n----[End Current Configuration]----\n" 
		% [_lossConfig.clientID, _lossConfig.authorizationServerURL, _lossConfig.datastoreServerURL, _lossConfig.enableDeveloperLogs]])

	# Initialize the subsystems
	_AuthorizationModule = _LAuthorizationClass.new(_lossConfig)
	DatastoreModule = _LDatastoreClass.new(_AuthorizationModule, _Logging, _lossConfig)

	# Add subsystems to tree
	add_child(_AuthorizationModule)
	add_child(DatastoreModule)

func registerClient() -> void:
	yield(_AuthorizationModule.register(_lossConfig.authorizationServerURL, _lossConfig.clientID), "completed")

func refreshToken() -> void:
	yield(_AuthorizationModule.refreshToken(), "completed")

# Private Methods
