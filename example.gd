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
<<<<<<< Updated upstream
var _LossConfig: Dictionary  = {
	"clientID": "ixjp/XpgawR+GzQopDDQIFWlnLS8Q/sbiiQju6Xw/vA0B2IwCti/6Fc3uL8qhxIPBg3Ohp0xQcSzbGAAg0BHBg==",
	"authorizationServerURL": "http://127.0.0.1:36210",
	"datastoreServerURL": "http://127.0.0.1:36211",
	"UDPPunchThroughServer": ["127.0.0.1", 36212],
	"enableDeveloperLogs": false
=======
var _lossConfig: Dictionary = {
	"clientToken": "/u4qVmfFPneidTXj2n47o+EeWBSAMP3zDA2COIIDtUcYF7iTmkCUFdLvldnokoJdR52W3yqkSGjqXutYZ7xZcA==",
	"authorizationServerURL": "https://127.0.0.1:36210",
	"datastoreServerURL": "https://127.0.0.1:36211",
	"UDPPunchthrough": {
		"IP": "127.0.0.1",
		"PORT": 36212,
		"ENCKEY": "cMlFfQeaK3/RXltoRVsfg+1E56Vxf3SiA9EG+/FqhVK2DoCLYgU4eeORVppeUE+9nzln4wkRzGDnuwtFrrMNWA==",
	},
>>>>>>> Stashed changes
}

# Onready Variables

# _ready()
func _ready() -> void:
<<<<<<< Updated upstream
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
=======
	# Initlize
	LossAPI.initialize(_lossConfig)

	# Initialize some variables
	var methodResponse: _LMethodResponseData

	# <--- Register --->
	methodResponse = yield(LossAPI.AuthorizationModule.registerClient(), "completed")

	# Error checking
	if methodResponse.hasError():
		print("ERR:", methodResponse.getErrorDetails())
	
	# <--- Register --->

	
	# <--- New Leaderboard -->
	methodResponse = yield(LossAPI.DatastoreModule.LeaderboardService.newLeaderboard("myLeaderboard"), "completed")

	# Error checking
	if methodResponse.hasError():
		print("ERR:", methodResponse.getErrorDetails())
	# <--- New Leaderboard -->

	
	# <--- New Category --->
	methodResponse = yield(LossAPI.DatastoreModule.LeaderboardService.newCategory("myLeaderboard", "myCategory"), "completed")

	# Error checking
	if methodResponse.hasError():
		print("ERR:", methodResponse.getErrorDetails())
	# <--- New Category --->

	
	# <--- Add Record --->
	methodResponse = yield(LossAPI.DatastoreModule.LeaderboardService.addRecord("myLeaderboard", "myCategory", "ACME", {"dickSize": "HUGE"}), "completed")

	# Error checking
	if methodResponse.hasError():
		print("ERR:", methodResponse.getErrorDetails())
	# <--- Add Record --->

	
	# <--- Fetch Records --->
	methodResponse = yield(LossAPI.DatastoreModule.LeaderboardService.fetchRecords("myLeaderboard", "myCategory"), "completed")

	# Error checking
	if methodResponse.hasError():
		print("ERR:", methodResponse.getErrorDetails())
	
	print("Records: ", methodResponse.getReturnData())
	# <--- Fetch Records --->

	
	# <--- Update Records --->
	methodResponse = yield(LossAPI.DatastoreModule.LeaderboardService.updateRecord("myLeaderboard", "myCategory", "ACME", {"dickSize": "SMALL"}), "completed")

	# Error checking
	if methodResponse.hasError():
		print("ERR:", methodResponse.getErrorDetails())
	# <--- Update Records --->

	
	# <--- Fetch Records --->
	methodResponse = yield(LossAPI.DatastoreModule.LeaderboardService.fetchRecords("myLeaderboard", "myCategory"), "completed")

	# Error checking
	if methodResponse.hasError():
		print("ERR:", methodResponse.getErrorDetails())
	
	print("Records: ", methodResponse.getReturnData())
	# <--- Fetch Records --->

	
	# <-- Delete Category --->
	methodResponse = yield(LossAPI.DatastoreModule.LeaderboardService.deleteCatgeory("myLeaderboard", "myCategory"), "completed")

	# Error checking
	if methodResponse.hasError():
		print("ERR:", methodResponse.getErrorDetails())
	# <-- Delete Category --->

	# <-- Delete Leaderboard --->
	methodResponse = yield(LossAPI.DatastoreModule.LeaderboardService.deleteLeaderboard("myLeaderboard"), "completed")

	# Error checking
	if methodResponse.hasError():
		print("ERR:", methodResponse.getErrorDetails())
	# <-- Delete Leaderboard --->
	

>>>>>>> Stashed changes

# _other()

# Public Methods

# Private Methods
