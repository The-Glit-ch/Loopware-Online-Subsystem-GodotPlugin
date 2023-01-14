# Tool

# Class

# Extends
extends Node

# Docstring
# Loopware Online Subsystem @ Godot Plugin || Example file
# Contains variouse examples on how to use the Loss API

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

var newCollectionData: Dictionary = {
	"cName": "Sleep",
	"cData": {
		"hello world": "goodbye word"
	}
}

# Onready Variables

# _init()
# func _init() -> void:
# 	pass

# _ready()
func _ready() -> void:
	LossAPI.initialize(_LossConfig) # Initializes the LossAPI
	
	yield(LossAPI.registerClient(), "completed") # Registers client/user with the authorization server

	yield(LossAPI.DatastoreModule.createCollection(newCollectionData), "completed") # Create a new collection with data


# _other()

# Public Methods

# Private Methods
