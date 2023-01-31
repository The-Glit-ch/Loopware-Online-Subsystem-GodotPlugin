# Tool

# Class
class_name _LDatastoreClass

# Extends
extends Node

# Docstring
# Loopware Online Subsystem @ Godot Plugin || Datastore Class
# Parent class that contain sub modules that relate to the Datastore Service

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables
var DatastoreService: _LDatastoreServiceModule
var Streaming: _LDatastoreStreamingModule

# Private Variables
var _AuthorizationModule: _LAuthorizationClass
var _Logging: _LoggingModule
var _lossConfig: Dictionary

# Onready Variables

# _init()
func _init(authorizationRefrence: _LAuthorizationClass, loggingModule: _LoggingModule, lossConfig: Dictionary) -> void:
	# Save reference
	_AuthorizationModule = authorizationRefrence
	_Logging = loggingModule
	_lossConfig = lossConfig

	# Initiate subsystems
	DatastoreService = _LDatastoreServiceModule.new(_AuthorizationModule, _Logging, _lossConfig)
	Streaming = _LDatastoreStreamingModule.new(_AuthorizationModule, _Logging, _lossConfig)
	add_child(DatastoreService)
	add_child(Streaming)


# _ready()
# func _ready() -> void:
# 	pass

# _other()

# Public Methods

# Private Methods
