# Tool

# Class
class_name _LAuthorizationClass

# Extends
extends HTTPRequest

# Docstring
# Loopware Online Subsystems @ Godot Plugin || Authorization Class
# Handles all authorization requests coming in and out

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables

# Private Variables
# Ref
var _Logging: _LoggingModule
var _lossConfig: Dictionary
# Self
var _tokens: Dictionary = {}
var _accessTimeout: Timer

# Onready Variables

# _init()
func _init(loggingModule: _LoggingModule, lossConfig: Dictionary) -> void:
	# Store a copy of the configuation file
	_Logging = loggingModule
	_lossConfig = lossConfig

	# Courutine
	_accessTimeout = Timer.new()
	_accessTimeout.wait_time = 3300 #Token expires every 1hr so refresh it every 55 minutes || 3300
	_accessTimeout.autostart = false
	_accessTimeout.one_shot = true
	_accessTimeout.name = "LossAPI-AuthCoroutine"
	_accessTimeout.connect("timeout", self, "refreshToken")
	add_child(_accessTimeout)
 
# func _ready() -> void:
# 	return

# _other()

# Public Methods
# /**
# * Registers client with Authorization Server. Should be called via the LossAPI singleton and not through the AuthorizationClass
# * @param { String } authorizationServerURL - The server URL for the authorization server
# * @param { String } clientID - The client ID to register
# * @returns { _LMethodReponseData } - Returns error messages and information
# */
func register() -> _LMethodResponseData:
	# Make request
	self.request("%s/auth/server/register" % [_lossConfig.authorizationServerURL], ["Authorization: Bearer %s" % [_lossConfig.clientID]], true, HTTPClient.METHOD_POST) 

	# Logs
	_Logging.log(["Registering client"])
	_Logging.devLog(["Server URL: %s || Client ID: %s" % ["%s/auth/server/register" % [_lossConfig.authorizationServerURL], _lossConfig.clientID]])
	
	# Fetch and parse data
	var responseData: _LResponseDataType = _LResponseDataType.new(yield(self, "request_completed"))

	# Error handling
	if responseData.functionStatus != OK:
		_Logging.err(["Function error while registering client || Code: %s" % [responseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": responseData.functionStatus})
	
	if responseData.responseStatus != 200:
		_Logging.err(["HTTP error while registering client || Code: %s | Message: %s" % [responseData.responseStatus, responseData.responseData.message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [responseData.responseData.message], "errorCode": responseData.responseStatus})
	
	# Save token
	_tokens["accessJWT"] = responseData.responseData.message.access_token
	_tokens["refreshJWT"] = responseData.responseData.message.refresh_token

	# Start courutine
	_accessTimeout.start()

	# Logs
	_Logging.log(["Client succesfully registered"])
	_Logging.devLog(["\nClientID: %s\nAccessJWT: %s\nRefreshJWT: %s" % [_lossConfig.clientID, _tokens["accessJWT"], _tokens["refreshJWT"]]])
	return _LMethodResponseData.new({})

# /**
# * Refreshes the AccessJWT. Should be called via the LossAPI singleton and not through the AuthorizationClass
# * @returns { void }
# */
func refreshToken() -> void:
	# Make request
	self.request("%s/auth/server/refresh" % [_lossConfig.authorizationServerURL], ["Authorization: Bearer %s" % [_tokens["refreshJWT"]]], true, HTTPClient.METHOD_POST)

	# Logs
	_Logging.log(["Refreshing token"])
	_Logging.devLog(["Server URL: %s || Refresh JWT: %s" % ["%s/auth/server/refresh" % [_lossConfig.authorizationServerURL], _tokens["refreshJWT"]]])

	# Fetch and parse data
	var responseData: _LResponseDataType = _LResponseDataType.new(yield(self, "request_completed"))

	# Error handling
	if responseData.functionStatus != OK:
		_Logging.err(["Function error while refreshing token || Code: %s" % [responseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": responseData.functionStatus})
	
	if responseData.responseStatus != 200:
		_Logging.err(["HTTP error while refreshing token || Code: %s | Message: %s" % [responseData.responseStatus, responseData.responseData.message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [responseData.responseData.message], "errorCode": responseData.responseStatus})
	
	# Save new token
	_tokens["accessJWT"] = responseData.responseData.message.access_token

	# Reset courutine
	_accessTimeout.start()

	# Logs
	_Logging.log(["Token refreshed"])
	_Logging.devLog(["\nAccessJWT: %s\nRefreshJWT: %s" % [_tokens["accessJWT"], _tokens["refreshJWT"]]])
	return _LMethodResponseData.new({})


# /**
# * Makes a secure HTTP(S) request by passing in the AccessJWT
# * @param { int } requestMethod - The request method that should be use. Refer to HTTPClient.METHOD_XXXXXX
# * @param { String } requestURL - The url to use for the request
# * @param { Dictionary } requestBody - The data to send to the server
# * @param { bool } formatAsDictionary - Should the return data be a Dictionary or PoolByteArray. True by default || Currently only used by the DatastoreModule.assetStream() method
# * @returns { _LResponseDataType } - Returns a ResponseDataType with the response data
# */
func secureRequest(requestMethod: int, requestURL: String, requestBody: Dictionary, formatAsDictionary: bool = true) -> _LResponseDataType:
	# Make request
	self.request(requestURL, ["Authorization: Bearer %s" % [_tokens["accessJWT"]], "Content-Type: application/json"], true, requestMethod, to_json(requestBody))

	# Logs
	_Logging.log(["Making secure request to server"])
	_Logging.devLog(["Request URL: %s\nRequest Method: %s\nRequest Body: %s" % [requestURL, requestMethod, requestBody]])

	# Fetch and parse data
	var responseData: _LResponseDataType = _LResponseDataType.new(yield(self, "request_completed"), formatAsDictionary)

	# Return data
	return responseData


# Private Methods
func _returnAccessJWT() -> String:
	return _tokens["accessJWT"]
