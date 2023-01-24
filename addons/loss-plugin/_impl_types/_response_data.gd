# Tool

# Class

# Extends
class_name _LResponseDataType extends Node

# Docstring
# Loopware Online Subsystems @ Godot Plugin || Response Type
# Generic data type that stores info on a HTTP(S) request 
# response data

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables
var functionStatus: int
var responseStatus: int
var responseHeaders: PoolStringArray
var responseData

# Private Variables

# Onready Variables

# _init()
func _init(rawData: Array, formatAsDictionary: bool = true) -> void:
	functionStatus = int(rawData[0])
	responseStatus = int(rawData[1])
	responseHeaders = PoolStringArray(rawData[2])
	responseData = parse_json(PoolByteArray(rawData[3]).get_string_from_utf8()) if formatAsDictionary else PoolByteArray(rawData[3])

# _ready()
# func _ready() -> void:
# 	pass

# _other()

# Public Methods

# Private Methods
