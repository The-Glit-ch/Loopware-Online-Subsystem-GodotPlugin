# Tool

# Class

# Extends
extends Node

# Docstring
# Loopware Online Subsystem @ Godot Plugin || Example file
# Contains various examples on how to use the Loss API

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables

# Private Variables
var _LossConfig: Dictionary  = {
	"clientID": "ixjp/XpgawR+GzQopDDQIFWlnLS8Q/sbiiQju6Xw/vA0B2IwCti/6Fc3uL8qhxIPBg3Ohp0xQcSzbGAAg0BHBg==",
	"authorizationServerURL": "http://127.0.0.1:8081",
	"datastoreServerURL": "http://127.0.0.1:8080",
	"enableDeveloperLogs": false
}

# Onready Variables

# _ready()
func _ready() -> void:
	# Initializes the LossAPI
	LossAPI.initialize(_LossConfig) 
	
	# Registers client/user with the authorization server
	yield(LossAPI.registerClient(), "completed") 

	# Create a new collection
	yield(LossAPI.DatastoreModule.createCollection("dev-testing", {"passed-with": "createCollection()"}), "completed")

	# Write data to collection
	yield(LossAPI.DatastoreModule.writeData("dev-testing", {"_loss-id": 1, "hello_world": "goodbye_world", "edited": false}), "completed")

	# Fetch data
	print("Data: ", yield(LossAPI.DatastoreModule.fetchData("dev-testing", {"_loss-id": 1}), "completed"))

	# Update data
	yield(LossAPI.DatastoreModule.updateData("dev-testing", {"_loss-id": 1}, {"edited": true}), "completed")

	# Refetch data
	print("Data: ", yield(LossAPI.DatastoreModule.fetchData("dev-testing", {"_loss-id": 1}), "completed"))

	# Delete data
	yield(LossAPI.DatastoreModule.deleteData("dev-testing", {"_loss-id": 1}), "completed")

# _other()

# Public Methods

# Private Methods
