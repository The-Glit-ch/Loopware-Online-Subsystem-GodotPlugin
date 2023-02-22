# Tool

# Class

# Extends
extends Node

# Docstring
# Loopware Online Subsystems Godot Plugin @ Example File || Shows both examples and also
# used for unit testing

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
	"enableDeveloperLogs": false
}

# Onready Variables

# _ready()
func _ready() -> void:
	# Initiliazes the API
	LossAPI.initialize(_lossConfig)

	# Register
	yield(LossAPI.AuthorizationModule.registerClient(), "completed")

# _other()

# Public Methods

# Private Methods
