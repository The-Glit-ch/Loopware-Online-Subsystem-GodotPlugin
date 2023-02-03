# Tool

# Extends
extends Node

# Docstring
# Loopware Online Subsystems @ Godot Plugin || Main file for the plugin
# This is like the *.h file in a CPP project. Contains the function defenitions
# Any data is then passed into the actual implementations located in "_impl" folder

# Signals

# Enums

# Constants
const VERSION_STRING: String = "DEV/PRE-v1.0.0" #Major.Minor.BugFix

# Exported Variables

# Public Variables
var AuthorizationModule: _LAuthorizationClass
var DatastoreModule: _LDatastoreClass
var NetLiveModule: _LNetLiveClass

# Private Variables
var _Logging: _LoggingModule
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
func initialize(lossConfig: Dictionary) -> void:
	# Store configuration file
	_lossConfig = lossConfig

	# Initialize the logger
	_Logging = _LoggingModule.new()
	_Logging.enableDevLogging(_lossConfig.enableDeveloperLogs)

	# Logs
	_Logging.log(["Initializing Godot LossSDK %s" % [VERSION_STRING]])
	_Logging.devLog(
		["\n\n----[Start Current Configuration]----\nClientID: \"%s\"\nAuthorization Server URL: \"%s\"\nDatastore Server URL: \"%s\"\nEnable Developer Logs: \"%s\"\n----[End Current Configuration]----\n" 
		% [_lossConfig.clientID, _lossConfig.authorizationServerURL, _lossConfig.datastoreServerURL, _lossConfig.enableDeveloperLogs]])

	# Initialize sub modules
	AuthorizationModule = _LAuthorizationClass.new(_Logging, _lossConfig)
	DatastoreModule = _LDatastoreClass.new(AuthorizationModule, _Logging, _lossConfig)
	NetLiveModule = _LNetLiveClass.new(AuthorizationModule, _Logging, _lossConfig)

	# Add subsystems to tree
	add_child(AuthorizationModule)
	add_child(DatastoreModule)
	add_child(NetLiveModule)

func registerClient() -> void:
	yield(AuthorizationModule.register(), "completed")

func refreshToken() -> void:
	yield(AuthorizationModule.refreshToken(), "completed")

# Private Methods
