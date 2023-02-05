# Tool

# Class
class_name _LDatastoreStreamingModule

# Extends
extends Node

# Docstring
# Loopware Online Subsystem @ Godot Plugin || Datastore Streaming Module
# Module that provides functions specific to streaming assets/data from the Datastore

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables

# Private Variables
var _AuthorizationModule: _LAuthorizationClass
var _Logging: _LoggingModule
var _lossConfig: Dictionary

# Onready Variables

# _init()
func _init(authorizationReference: _LAuthorizationClass, loggingModule: _LoggingModule, lossConfig: Dictionary) -> void:
	# Save reference
	_AuthorizationModule = authorizationReference
	_Logging = loggingModule
	_lossConfig = lossConfig

# _ready()
# func _ready() -> void:
#     returns

# _other()

# Public Methods
# /**
# * Streams data from the Datastore streaming service via the specified filename/filepath
# * @param { String } fileName - The name of the file/filepath in which the data is located
# * @returns { _LMethodReponseData } - Returns error messages and information
# */
func assetStream(fileName: String) -> _LMethodResponseData:
	# Format data
	var payload: Dictionary = {"fileName": fileName}

	# Logs
	_Logging.log(["Attempting to download assets"])

	# Send request
	var responseData: _LResponseDataType = yield(_AuthorizationModule.secureRequest(HTTPClient.METHOD_GET, _lossConfig.datastoreServerURL + "/stream/download", payload, false), "completed")
	
	# Error handling
	if responseData.functionStatus != OK:
		_Logging.err(["Function error while streaming data \"%s\" || Code: %s" % [payload.fileName, responseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": responseData.functionStatus})

	if responseData.responseStatus != 200:
		_Logging.err(["HTTP error while streaming data \"%s\" || Code: %s | Message: %s" % [payload.fileName, responseData.responseStatus, parse_json(responseData.responseData.get_string_from_utf8()).message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [responseData.responseData.message], "errorCode": responseData.responseStatus})
	
	# Logs
	_Logging.log(["Successfully streamed data \"%s\"" % [payload.fileName]])
	return _LMethodResponseData.new({"returnData": responseData.responseData})

# Private Methods
