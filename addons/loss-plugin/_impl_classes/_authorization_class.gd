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
var _Logging: _LoggingModule
#
var _lossConfig: Dictionary
var _accessTimeout: Timer
#
var _authorizationServerURL: String
var _userAgent: String = "User-Agent: Godot-LossAPI"
#
var _accessJWT: String
var _refreshJWT: String

# Onready Variables

# _init()
func _init(config: Dictionary) -> void:
	# Store a copy of the configuation file
	_lossConfig = config

	# Initialize the logger
	_Logging = _LoggingModule.new()
	_Logging.enableDevLogging(_lossConfig.enableDeveloperLogs)

	# Courutine
	_accessTimeout = Timer.new()
	_accessTimeout.wait_time = 3300 #Token expires every 1hr so refresh it every 55 minutes || 3300
	_accessTimeout.autostart = false
	_accessTimeout.one_shot = true
	_accessTimeout.name = "LossAPI-Coroutine"
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
# * @returns { void }
# */
func register(authorizationServerURL: String, clientID: String) -> void:
	# Make request
	self.request("%s/auth/server/register" % [authorizationServerURL], ["Authorization: Bearer %s" % [clientID], _userAgent], true, HTTPClient.METHOD_POST) 
	
	# Save parameter data
	_authorizationServerURL = authorizationServerURL

	# Logs
	_Logging.log(["Registering client"])
	_Logging.devLog(["Server URL: %s || Client ID: %s" % [authorizationServerURL, clientID]])
	
	# Fetch and parse data
	var responseData: _LResponseDataType = _LResponseDataType.new(yield(self, "request_completed"))

	# Error handling
	if responseData.functionStatus != OK:
		_Logging.err(["Function error while registering client || Code: %s" % [responseData.functionStatus]])
		return
	
	if responseData.responseStatus != 200:
		_Logging.err(["HTTP error while registering client || Code: %s | Message: %s" % [responseData.responseStatus, responseData.responseData.message]])
		return
	
	# Save token
	_accessJWT = responseData.responseData.message.access_token
	_refreshJWT = responseData.responseData.message.refresh_token

	# Start courutine
	_accessTimeout.start()

	# Logs
	_Logging.log(["Client succesfully registered"])
	_Logging.devLog(["\nClientID: %s\nAccessJWT: %s\nRefreshJWT: %s" % [clientID, _accessJWT, _refreshJWT]])
	return

# /**
# * Refreshes the AccessJWT. Should be called via the LossAPI singleton and not through the AuthorizationClass
# * @returns { void }
# */
func refreshToken() -> void:
	# Make request
	self.request("%s/auth/server/refresh" % [_authorizationServerURL], ["Authorization: Bearer %s" % [_refreshJWT], _userAgent], true, HTTPClient.METHOD_POST)

	# Logs
	_Logging.log(["Refreshing token"])
	_Logging.devLog(["Server URL: %s || Refresh JWT: %s" % [_authorizationServerURL, _refreshJWT]])

	# Fetch and parse data
	var responseData: _LResponseDataType = _LResponseDataType.new(yield(self, "request_completed"))

	# Error handling
	if responseData.functionStatus != OK:
		_Logging.err(["Function error while refreshing token || Code: %s" % [responseData.functionStatus]])
		return
	
	if responseData.responseStatus != 200:
		_Logging.err(["HTTP error while refreshing token || Code: %s | Message: %s" % [responseData.responseStatus, responseData.responseData.message]])
		return
	
	# Save new token
	_accessJWT = responseData.responseData.message.access_token

	# Reset courutine
	_accessTimeout.start()

	# Logs
	_Logging.log(["Token refreshed"])
	_Logging.devLog(["\nAccessJWT: %s\nRefreshJWT: %s" % [_accessJWT, _refreshJWT]])
	return


# /**
# * Makes a secure HTTP(S) request by passing in the AccessJWT
# * @param { int } requestMethod - The request method that should be use. Refer to HTTPClient.METHOD_XXXXXX
# * @param { String } requestURL - The url to use for the request
# * @param { Dictionary } requestBody - The data to send to the server
# * @returns { _LResponseDataType } - Returns a ResponseDataType with the response data
# */
func secureRequest(requestMethod: int, requestURL: String, requestBody: Dictionary, formatAsDictionary: bool = true) -> _LResponseDataType:
	# Make request
	self.request(requestURL, ["Authorization: Bearer %s" % [_accessJWT], _userAgent, "Content-Type: application/json"], true, requestMethod, to_json(requestBody))

	# Logs
	_Logging.log(["Making secure request to server"])
	_Logging.devLog(["Request URL: %s\nRequest Method: %s\nRequest Body: %s" % [requestURL, requestMethod, requestBody]])

	# Fetch and parse data
	var responseData: _LResponseDataType = _LResponseDataType.new(yield(self, "request_completed"), formatAsDictionary)

	# Return data
	return responseData


# Private Methods
