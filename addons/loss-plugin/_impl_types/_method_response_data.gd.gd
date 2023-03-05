# Tool

# Class
class_name _LMethodResponseData

# Extends
extends Node

# Docstring
# Loopware Online Subsystem Godot Plugin @ Method Respomse Data Type || Generic data
# type that can hold response, error, and function data

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables

# Private Variables
var _returnData
var _errorMessage
var _errorCode

# Onready Variables

# _init()
func _init(responseData: Dictionary) -> void:
	_returnData = responseData["returnData"] if responseData.has("returnData") else null
	_errorMessage = responseData["errorMessage"] if responseData.has("errorMessage") else null
	_errorCode = responseData["errorCode"] if responseData.has("errorCode") else null

# _ready()
# func _ready() -> void:
#     returns

# _other()

# Public Methods
func hasError() -> bool:
	if _errorMessage != null or _errorCode != null:
		return true
	else:
		return false

func getErrorDetails():
	return [_errorMessage, _errorCode]

func getReturnData():
	if _returnData != null:
		return _returnData


# Private Methods
