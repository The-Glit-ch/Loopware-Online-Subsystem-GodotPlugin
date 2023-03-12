# Tool

# Class

# Extends
extends Node

# Docstring
# Loopware Online Subsystems Godot Plugin @ Example File || Example File
# Currently just used as a testing file to be honest

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables

# Private Variables
var _lossConfig: Dictionary = {
	"clientToken": "/u4qVmfFPneidTXj2n47o+EeWBSAMP3zDA2COIIDtUcYF7iTmkCUFdLvldnokoJdR52W3yqkSGjqXutYZ7xZcA==",
	"authorizationServerURL": "https://127.0.0.1:36210",
	"datastoreServerURL": "https://127.0.0.1:36211",
	"UDPPunchthrough": {
		"IP": "127.0.0.1",
		"PORT": 36212,
		"ENCKEY": "cMlFfQeaK3/RXltoRVsfg+1E56Vxf3SiA9EG+/FqhVK2DoCLYgU4eeORVppeUE+9nzln4wkRzGDnuwtFrrMNWA==",
	},
}

# Onready Variables

func  _ready() -> void:
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

# _other()

# Public Methods

# Private Methods
