# Tool

# Class
class_name _LAuthorizationClass

# Extends
extends HTTPRequest

# Docstring
# Loopware Online Subsystems @ Godot Plugin || Authorization Class
# Handles all authorization requests to and from the client

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables

# Private Variables

# Onready Variables

# _init()
# func _init() -> void:
# 	pass

# _ready()
# func _ready() -> void:
# 	pass

# _other()

# Public Methods
func register(authorizationServerURL: String, clientID: String) -> GDScriptFunctionState:
	self.request("%s/auth/server/register" % [authorizationServerURL], ["Authorization: Bearer %s" % [clientID], "User-Agent: Godot-LossAPI"], true, HTTPClient.METHOD_POST) 
	return yield(self, "request_completed")

# Private Methods