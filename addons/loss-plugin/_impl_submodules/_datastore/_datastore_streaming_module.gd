# Tool

# Class
class_name _LDatastoreStreamingModule

# Extends
extends Node

# Docstring
# Loopware Online Subsystem Godot Plugin @ Datastore Streaming Module || Allows for streaming data/assets from
# Loss

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables

# Private Variables
# References
var _loggingModuleRef: _LLoggingModule
var _authModuleRef: _LAuthorizationClass
var _lossConfigRef: Dictionary

# Onready Variables

func _init(loggingModuleReference: _LLoggingModule, lossConfigurationReference: Dictionary, authorizationModuleReference: _LAuthorizationClass) -> void:
	# Save the refrences
	_loggingModuleRef = loggingModuleReference
	_authModuleRef = authorizationModuleReference
	_lossConfigRef = lossConfigurationReference

# _ready()
# func _ready() -> void:
#     returns

# _other()

# Public Methods
func streamData(filePath: String) -> _LMethodResponseData:
	# Format payload
	var dataPayload: Dictionary = { "fileName": filePath }
	var requestURL: String = "%s%s" % [_lossConfigRef.datastoreServerURL, "/streaming/api/v1/stream"]

	# Log
	_loggingModuleRef.log(["Attempting to stream data"])

	# Send request
	var responseData: _LMethodResponseData = yield(_authModuleRef.makeSecureRequest(requestURL, HTTPClient.METHOD_GET, dataPayload), "completed")

	# Generic Error handling
	if responseData.hasError():
		return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[0], "errorCode": responseData.getErrorDetails()[1]})

	# HTTP/Function Error handling
	var httpResponseData: _LHTTPResponseData = responseData.getReturnData()
	if httpResponseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while streaming data || Code: %s" % [httpResponseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": httpResponseData.functionStatus})

	if httpResponseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while streaming data || Code: %s | Message: %s" % [httpResponseData.responseStatus, httpResponseData.toJSON().message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [httpResponseData.toJSON()["message"]], "errorCode": "%s" % [httpResponseData.responseStatus]})
	
	# Save data
	var streamData: PoolByteArray = httpResponseData.responseData

	# Log
	_loggingModuleRef.log(["Successfully streamed data"])

	return _LMethodResponseData.new({"returnData": streamData})

# Private Methods
