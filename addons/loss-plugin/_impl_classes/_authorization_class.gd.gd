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
var _loggingModuleRef: _LLoggingModule
var _lossConfigRef: Dictionary
# Self
var _tokens: Dictionary = {}
var _tokenTimeoutTimer: Timer
var _tokenTimeoutSeconds: int = 3500
var _crypto: Crypto = Crypto.new()

# Onready Variables

# _init()
func _init(loggingModuleReference: _LLoggingModule, lossConfigurationReference: Dictionary) -> void:
	# Save the references
	_loggingModuleRef = loggingModuleReference
	_lossConfigRef = lossConfigurationReference

# _ready()
func _ready() -> void:
	# Automatically refresh tokens
	_tokenTimeoutTimer = Timer.new()
	_tokenTimeoutTimer.wait_time = _tokenTimeoutSeconds
	_tokenTimeoutTimer.one_shot = true
	_tokenTimeoutTimer.autostart = false
	_tokenTimeoutTimer.name = "LossAPI-AuthCoroutine"
	_tokenTimeoutTimer.connect("timeout", self, "refreshToken")

	# Add to scene tree
	add_child(_tokenTimeoutTimer)

# _other()

# Public Methods
# /**
# * Registers the client with the Loss authorization service
# * @returns _LMethodResponseData
# */
func registerClient() -> _LMethodResponseData:
	# Fix wierd async issues
	yield(get_tree(), "idle_frame")

	# Check if we already are registered
	if _tokens.has("accessToken") && _tokens.has("refreshToken"):
		return _LMethodResponseData.new({"errorMessage": "Already registered || Please logout before registering again"})

	# Format the payload
	var authorizationURI: String = "%s/authorization/api/v1/register" % [_lossConfigRef.authorizationServerURL]
	var payloadHeader: PoolStringArray = ["Authorization: Bearer %s" % [_lossConfigRef.clientID]]

	# Log
	_loggingModuleRef.log(["Attempting to register client"])

	# Make a request
	self.request(authorizationURI, payloadHeader, true, HTTPClient.METHOD_POST)

	# Yield and fetch response
	var responseData: _LHTTPResponseData = _LHTTPResponseData.new(yield(self, "request_completed"))

	# Error handling
	if responseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while registering client || Code: %s" % [responseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": responseData.functionStatus})
	
	if responseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while registering client || Code: %s | Message: %s" % [responseData.responseStatus, responseData.toJSON()["message"]]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [responseData.toJSON()["message"]], "errorCode": "%s" % [responseData.responseStatus]})
	
	# Save tokens
	var tokens: Dictionary = responseData.toJSON().data
	_tokens.accessToken = tokens.accessToken
	_tokens.refreshToken = tokens.refreshToken

	# Log
	_loggingModuleRef.log(["Successfully registered client"])

	return _LMethodResponseData.new({})

# /**
# * Refreshes the current access token
# * @returns _LMethodResponseData
# */
func refreshToken() -> _LMethodResponseData:
	# Fix wierd async issues
	yield(get_tree(), "idle_frame")

	# Check if we are registered
	if !_tokens.has("refreshToken"):
		return _LMethodResponseData.new({"errorMessage": "You must register before refreshing tokens"})

	# Format the payload
	var authorizationURI: String = "%s/authorization/api/v1/refresh" % [_lossConfigRef.authorizationServerURL]
	var payloadHeader: PoolStringArray = ["Authorization: Bearer %s:%s" % [_tokens.refreshToken, _lossConfigRef.clientID]]

	# Log
	_loggingModuleRef.log(["Attempting to refresh access token"])

	# Make a request
	self.request(authorizationURI, payloadHeader, true, HTTPClient.METHOD_POST)

	# Yield and fetch the response
	var responseData: _LHTTPResponseData = _LHTTPResponseData.new(yield(self, "request_completed"))

	# Error handling
	if responseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while refreshing access token || Code: %s" % [responseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": responseData.functionStatus})
	
	if responseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while refreshing access token || Code: %s | Message: %s" % [responseData.responseStatus, responseData.toJSON()["message"]]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [responseData.toJSON()["message"]], "errorCode": "%s" % [responseData.responseStatus]})

	# Save token
	var newAccessToken: String = responseData.toJSON().data.accessToken

	# Reset timer
	_tokenTimeoutTimer.start()

	# Log
	_loggingModuleRef.log(["Succesfully refreshed token"])

	return _LMethodResponseData.new({})

# /**
# * Logouts the client, invalidating their tokens
# * @returns _LMethodResponseData
# */
func logoutClient() -> _LMethodResponseData:
	# Fix wierd async issues
	yield(get_tree(), "idle_frame")

	# Check if we are registered
	if !_tokens.has("refreshToken"):
		return _LMethodResponseData.new({"errorMessage": "You must register before logging out"})

	# Format the payload
	var authorizationURI: String = "%s/authorization/api/v1/logout" % [_lossConfigRef.authorizationServerURL]
	var payloadHeader: PoolStringArray = ["Authorization: Bearer %s:%s" % [_tokens.refreshToken, _lossConfigRef.clientID]]

	# Log
	_loggingModuleRef.log(["Attempting to logout Loss client"])

	# Make a request
	self.request(authorizationURI, payloadHeader, true, HTTPClient.METHOD_POST)

	# Yield and fetch the response
	var responseData: _LHTTPResponseData = _LHTTPResponseData.new(yield(self, "request_completed"))

	# Error handling
	if responseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while logging out client || Code: %s" % [responseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": responseData.functionStatus})
	
	if responseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while logging out client || Code: %s | Message: %s" % [responseData.responseStatus, responseData.toJSON()["message"]]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [responseData.toJSON()["message"]], "errorCode": "%s" % [responseData.responseStatus]})
	
	# Clear tokens
	_tokens.clear()

	# Log
	_loggingModuleRef.log(["Succesfully logged out"])

	return _LMethodResponseData.new({})

# /**
# * Makes a request to any Loss service with and HTTP(S) endpoint.
# * Passes along the access token in the Authorization header
# * @param { String } requestURL - The URL to use for the request
# * @param { int } requestMethod - The request method that should be use. Refer to "HTTPClient.METHOD_"
# * @param { Dictionary } requestBody - The data sent to the server
# * @returns _LMethodResponseData
# */
func makeSecureRequest(requestURL: String, requestMethod: int, requestBody: Dictionary) -> _LMethodResponseData:
	# Fix wierd async issues
	yield(get_tree(), "idle_frame")

	# Check if we are registered
	if !_tokens.has("refreshToken"):
		return _LMethodResponseData.new({"errorMessage": "You must register before making secured HTTP(S) requests"})
	
	# Format payload
	var payloadHeader: PoolStringArray = ["Authorization: Bearer %s:%s" % [_tokens.accessToken, _lossConfigRef.clientID], "Content-Type: application/json"]

	# Log
	_loggingModuleRef.log(["Attempting to make a secure request to the server"])

	# Make a request
	self.request(requestURL, payloadHeader, true, requestMethod, to_json(requestBody))

	# Yield and fetch the response
	var responseData: _LHTTPResponseData = _LHTTPResponseData.new(yield(self, "request_completed"))

	# Log
	_loggingModuleRef.log(["Successfully retrieved data from secured request"])

	# Return data
	return _LMethodResponseData.new({"returnData": responseData})

# Private Methods
# /**
# * Generates a JWT that can be used to securely transmit sensitive data
# * @param { PoolByteArray } payload - The data to which encrypt
# * @returns _LMethodResponseData
# */
# func _encryptWithJWT(payload: PoolByteArray) -> _LMethodResponseData:
# 	# Check if we are registered
# 	if !_tokens.has("refreshToken"):
# 		return _LMethodResponseData.new({"errorMessage": "You must register before encrypting data"})

# 	var jwt: PoolByteArray = _crypto.hmac_digest(HashingContext.HASH_SHA256, _tokens["accessToken"].to_utf8(), payload)
# 	return _LMethodResponseData.new({"returnData": jwt})