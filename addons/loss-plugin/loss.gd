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
var NetModule: _LNetClass

# Private Variables
var _LoggingModule: _LLoggingModule
var _lossConfiguration: Dictionary

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
	_lossConfiguration = lossConfig

	# Initialize the logger
	_LoggingModule = _LLoggingModule.new()

	# Startup
	_LoggingModule.log(["Initializing Loss Godot Plugin | %s" % [VERSION_STRING]])

	# Initialize subsystems
	AuthorizationModule = _LAuthorizationClass.new(_LoggingModule, _lossConfiguration)
	DatastoreModule = _LDatastoreClass.new(_LoggingModule, _lossConfiguration, AuthorizationModule)
	NetModule = _LNetClass.new(_LoggingModule, _lossConfiguration, AuthorizationModule)

	# Add to scenee tree
	add_child(AuthorizationModule)
	add_child(DatastoreModule)
	add_child(NetModule)

# Private Methods
