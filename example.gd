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
	"authorizationServerURL": "http://127.0.0.1:36210",
	"datastoreServerURL": "http://127.0.0.1:36211",
	"UDPPunchThroughServer": ["127.0.0.1", 36212],
	"enableDeveloperLogs": false
}

# Onready Variables

# _ready()
func _ready() -> void:
	# Initializes the LossAPI
	LossAPI.initialize(_LossConfig) 
	
	# Registers client/user with the authorization server || Variant 1
	yield(LossAPI.registerClient(), "completed") 

	# # Registers client/user with the authorization server || Variant 2
	# yield(LossAPI.AuthorizationModule.register(), "completed") 

	# # Create a new collection
	# yield(LossAPI.DatastoreModule.DatastoreService.createCollection("dev-testing", {"passed-with": "createCollection()"}), "completed")

	# # Write data to collection
	# yield(LossAPI.DatastoreModule.DatastoreService.writeData("dev-testing", {"_loss-id": 1, "hello_world": "goodbye_world", "edited": false}), "completed")

	# # Fetch data
	# print("Data: ", yield(LossAPI.DatastoreModule.DatastoreService.fetchData("dev-testing", {"_loss-id": 1}), "completed"))

	# # Update data
	# yield(LossAPI.DatastoreModule.DatastoreService.updateData("dev-testing", {"_loss-id": 1}, {"edited": true}), "completed")

	# # Refetch data
	# print("Data: ", yield(LossAPI.DatastoreModule.DatastoreService.fetchData("dev-testing", {"_loss-id": 1}), "completed"))

	# # Delete data
	# yield(LossAPI.DatastoreModule.DatastoreService.deleteData("dev-testing", {"_loss-id": 1}), "completed")

	# # Delete collection
	# yield(LossAPI.DatastoreModule.DatastoreService.deleteCollection("dev-testing"), "completed")

	# # Stream data
	# print("Streamed Data -> ", yield(LossAPI.DatastoreModule.Streaming.assetStream("example.txt"), "completed").get_string_from_utf8())

	# # Stream invalid data
	# yield(LossAPI.DatastoreModule.Streaming.assetStream("invalid.txt"), "completed")

	# Create new UDP Punchthrough client
	yield(LossAPI.NetLiveModule.UDPHolePunch.createNewClient(), "completed")

	# Connect to host
	# yield(LossAPI.NetLiveModule.UDPHolePunch.createNewClient(), "completed")

# _other()

# Public Methods

# Private Methods
