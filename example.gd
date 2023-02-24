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
	"clientID": "/u4qVmfFPneidTXj2n47o+EeWBSAMP3zDA2COIIDtUcYF7iTmkCUFdLvldnokoJdR52W3yqkSGjqXutYZ7xZcA==",
	"authorizationServerURL": "http://127.0.0.1:36210",
	"datastoreServerURL": "http://127.0.0.1:36211",
	"netUDPPunchthroughServer": {
		"IP": "127.0.0.1",
		"PORT": 36212
	}
}

# Onready Variables

# _ready()
func _ready() -> void:
	# Initiliazes the API
	LossAPI.initialize(_lossConfig)

	# Set up some variables
	var returnData: _LMethodResponseData

	# Authorize with the Loss Authorization server
	returnData = yield(LossAPI.AuthorizationModule.registerClient(), "completed")

	if returnData.hasError():
		print("ERR: ", returnData.getErrorDetails())
		return
	
	# UDP
	returnData = yield(LossAPI.NetModule.UDPPunchthroughService.createNewClient(), "completed")

	if returnData.hasError():
		print("ERR: ", returnData.getErrorDetails())
		return
	
	#print(returnData.getReturnData().get_string_from_utf8())

	
	

# _other()

# Public Methods

# Private Methods
