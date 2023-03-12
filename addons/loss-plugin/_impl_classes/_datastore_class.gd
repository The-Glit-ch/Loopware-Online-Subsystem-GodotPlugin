# Tool

# Class
class_name _LDatastoreClass

# Extends
extends Node

# Docstring
# Loopware Online Subsystem Godot Plugin @ Datastore Class || Parent class that 
# contain submodules that relate to the Datastore Service

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables
var DatastoreService: _LDatastoreServiceModule
var StreamingService: _LDatastoreStreamingModule
var LeaderboardService: _LDatastoreLeaderboardModule

# Private Variables

# Onready Variables

# _init()
func _init(loggingModuleReference: _LLoggingModule, lossConfigurationReference: Dictionary, authorizationModuleReference: _LAuthorizationClass) -> void:
	# Initiate submodules
	DatastoreService = _LDatastoreServiceModule.new(loggingModuleReference, lossConfigurationReference, authorizationModuleReference)
	StreamingService = _LDatastoreStreamingModule.new(loggingModuleReference, lossConfigurationReference, authorizationModuleReference)
	LeaderboardService = _LDatastoreLeaderboardModule.new(loggingModuleReference, lossConfigurationReference, authorizationModuleReference)

	# Add to scene tree
	add_child(DatastoreService)
	add_child(StreamingService)
	add_child(LeaderboardService)



# _ready()

# _other()

# Public Methods

# Private Methods
