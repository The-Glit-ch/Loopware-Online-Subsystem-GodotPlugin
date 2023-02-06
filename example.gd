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
	
	# For error handling examples
	var methodStatusHandle

	# < --------------------------------------------------------------------------------------- > #

	# Registers client/user with the authorization server || Variant 1
	methodStatusHandle = yield(LossAPI.registerClient(), "completed")

	# Check for errors
	if methodStatusHandle.hasError():
		# Print error data to console
		print("Error Data: ", methodStatusHandle.getErrorDetails())
		return

	# < --------------------------------------------------------------------------------------- > #

	# # Create a new collection
	# var createCollectionData: Dictionary = {"optionalData": "passed along while creating a collection"}
	# methodStatusHandle = yield(LossAPI.DatastoreModule.DatastoreService.createCollection("dev-testing", createCollectionData), "completed")

	# # Check for errors
	# if methodStatusHandle.hasError():
	# 	# Print error data to console
	# 	print("Error Data: ", methodStatusHandle.getErrorDetails())
	# 	return

	# # < --------------------------------------------------------------------------------------- > #

	# # Write data to collection
	# var writeToCollectionData: Dictionary = {"_loss-id": 1, "this_is_a_key": "this_is_a_value", "edited": false}
	# methodStatusHandle = yield(LossAPI.DatastoreModule.DatastoreService.writeData("dev-testing", writeToCollectionData), "completed")

	# # Check for errors
	# if methodStatusHandle.hasError():
	# 	# Print error data to console
	# 	print("Error Data: ", methodStatusHandle.getErrorDetails())
	# 	return
	
	# # < --------------------------------------------------------------------------------------- > #
	
	# # Fetch data
	# var fetchDataQuery: Dictionary = {"_loss-id": 1}
	# methodStatusHandle = yield(LossAPI.DatastoreModule.DatastoreService.fetchData("dev-testing", fetchDataQuery), "completed")

	# # Check for errors
	# if methodStatusHandle.hasError():
	# 	# Print error data to console
	# 	print("Error Data: ", methodStatusHandle.getErrorDetails())
	# 	return

	# # Print return data to console
	# print("Fetched Data: ", methodStatusHandle.getReturnData())

	# # < --------------------------------------------------------------------------------------- > #

	# # Update data
	# var updateDataQuery: Dictionary = {"_loss-id": 1}
	# var updateData: Dictionary = {"edited": true}
	# methodStatusHandle = yield(LossAPI.DatastoreModule.DatastoreService.updateData("dev-testing", updateDataQuery, updateData), "completed")

	# # Check for errors
	# if methodStatusHandle.hasError():
	# 	# Print error data to console
	# 	print("Error Data: ", methodStatusHandle.getErrorDetails())
	# 	return
	
	# # < --------------------------------------------------------------------------------------- > #

	# # Refetch data
	# var refetchDataQuery: Dictionary = {"_loss-id": 1}
	# methodStatusHandle = yield(LossAPI.DatastoreModule.DatastoreService.fetchData("dev-testing", refetchDataQuery), "completed")

	# # Check for errors
	# if methodStatusHandle.hasError():
	# 	# Print error data to console
	# 	print("Error Data: ", methodStatusHandle.getErrorDetails())
	# 	return

	# # Print return data to console
	# print("Re-Fetched Data: ", methodStatusHandle.getReturnData())

	# # < --------------------------------------------------------------------------------------- > #

	# # Delete data
	# var deleteDataQuery: Dictionary = {"_loss-id": 1}
	# methodStatusHandle = yield(LossAPI.DatastoreModule.DatastoreService.deleteData("dev-testing", deleteDataQuery), "completed")

	# # Check for errors
	# if methodStatusHandle.hasError():
	# 	# Print error data to console
	# 	print("Error Data: ", methodStatusHandle.getErrorDetails())
	# 	return

	# # < --------------------------------------------------------------------------------------- > #

	# # Delete collection
	# methodStatusHandle = yield(LossAPI.DatastoreModule.DatastoreService.deleteCollection("dev-testing"), "completed")

	# # Check for errors
	# if methodStatusHandle.hasError():
	# 	# Print error data to console
	# 	print("Error Data: ", methodStatusHandle.getErrorDetails())
	# 	return

	# # < --------------------------------------------------------------------------------------- > #

	# # Stream data
	# methodStatusHandle = yield(LossAPI.DatastoreModule.Streaming.assetStream("example.txt"), "completed")

	# # Check for errors
	# if methodStatusHandle.hasError():
	# 	# Print error data to console
	# 	print("Error Data: ", methodStatusHandle.getErrorDetails())
	# 	return
	
	# # Print streamed data to console
	# print("Streamed Data -> ", methodStatusHandle.getReturnData().get_string_from_utf8())

	# < --------------------------------------------------------------------------------------- > #

	# Create new UDP Punchthrough client
	methodStatusHandle = yield(LossAPI.NetLiveModule.UDPHolePunch.createNewClient(), "completed")

	# Check for errors
	if methodStatusHandle.hasError():
		# Print error data to console
		print("Error Data: ", methodStatusHandle.getErrorDetails())
		return
	
	# < --------------------------------------------------------------------------------------- > #

	# Create a new session
	methodStatusHandle = yield(LossAPI.NetLiveModule.UDPHolePunch.createNewSession(), "completed")

	# Check for errors
	if methodStatusHandle.hasError():
		# Print error data to console
		print("Error Data: ", methodStatusHandle.getErrorDetails())
		return
	
	# Print out new session code
	print("Join code ->", methodStatusHandle.getReturnData()["joinCode"])

	# # < --------------------------------------------------------------------------------------- > #

	# methodStatusHandle = yield(LossAPI.NetLiveModule.UDPHolePunch.joinSession("a"), "completed")

	# # Check for errors
	# if methodStatusHandle.hasError():
	# 	# Print error data to console
	# 	print("Error Data: ", methodStatusHandle.getErrorDetails())
	# 	return
	
	# # < --------------------------------------------------------------------------------------- > #

# _other()

# Public Methods

# Private Methods
