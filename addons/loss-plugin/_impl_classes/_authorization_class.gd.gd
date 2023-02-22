# Tool

# Class
class_name _LAuthorizationClass

# Extends
extends HTTPRequest

# Docstring
# Loopware Online Subsystem Godot Plugin @ Authorization Class || Provides methods for registering and refreshing
# access tokens. Do note tokens do get refreshed automatically and should not be refreshed manually

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables

# Private Variables
# References
var _loggingRef: _LLoggingModule
var _lossConfigRef: Dictionary
# Self
var _tokens: Dictionary = {}
var _tokenTimeoutTimer: Timer

# Onready Variables

# _init()
func _init(loggingModuleReference: _LLoggingModule, lossConfigurationReference: Dictionary) -> void:
	# Save the references
	_loggingRef = loggingModuleReference
	_lossConfigRef = lossConfigurationReference

# _ready()

# _other()

# Public Methods
# /**
# * Registers the client with the Loss authorization service
# * @returns void
# */
func registerClient() -> _LMethodResponseData:
	# Format the payloads
	var authorizationURI: String = "%s/authorization/api/v1/register" % [_lossConfigRef.authorizationServerURL]
	var payloadHeader: Array = ["Authorization: Bearer %s" % [_lossConfigRef.clientID]]

	# Logs
	_loggingRef.log(["Attempting to register client"])
	_loggingRef.devLog(["Server URL: %s || ClientID: %s" % [authorizationURI, _lossConfigRef.clientID]])

	# Make a request
	self.request(authorizationURI, payloadHeader, true, HTTPClient.METHOD_POST)

	# Yield and fetch response
	var responseData: _LHTTPResponseData = _LHTTPResponseData.new(yield(self, "request_completed"))

	# Error handling
	if responseData.functionStatus != OK:
		_loggingRef.err(["Function error while registering client || Code: %s" % [responseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": responseData.functionStatus})
	
	if responseData.responseStatus != 200:
		_loggingRef.err(["HTTP(S) error while registering client || Code: %s | Message: %s" % [responseData.responseStatus, responseData.toJSON()["message"]]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [responseData.toJSON()["message"]], "errorCode": "%s" % [responseData.responseStatus]})
	
	# Save tokens
	var tokens: Dictionary = responseData.toJSON()["data"]
	_tokens.accessToken = tokens.accessToken
	_tokens.refreshToken = tokens.refreshToken

	# Logs
	_loggingRef.log(["Successfully registered client"])

	return _LMethodResponseData.new({})


# Private Methods
