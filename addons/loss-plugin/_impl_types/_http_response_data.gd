# Tool

# Class
class_name _LHTTPResponseData

# Extends
extends Node

# Docstring
# Loopware Online Subsystems Godot Plugin @ HTTP Response Data Type || Stores recieved data
# from an HTTP(S) request

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables
var functionStatus: int
var responseStatus: int
var responseHeaders: PoolStringArray
var responseData: PoolByteArray

# Private Variables

# Onready Variables

# _init()
func _init(rawData: Array) -> void:
	functionStatus = int(rawData[0])
	responseStatus = int(rawData[1])
	responseHeaders = PoolStringArray(rawData[2])
	responseData = PoolByteArray(rawData[3])

# _other()

# Public Methods
func toJSON() -> Dictionary:
	return parse_json(responseData.get_string_from_utf8())

# Private Methods
