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
var _lossConfig: Dictionary
var _accessTimeout: Timer
var _authorizationServerURL: String
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
	_accessTimeout.wait_time = 10 #3300.00 #Token expires every 1hr. Refresh the token every 55 minutes || 3600.00
	_accessTimeout.autostart = false
	_accessTimeout.one_shot = true
	_accessTimeout.name = "LossAPI@Coroutine"
	_accessTimeout.connect("timeout", self, "refreshToken")
	add_child(_accessTimeout)
 
# func _ready() -> void:
# 	return

# _other()

# Public Methods
func register(authorizationServerURL: String, clientID: String) -> void:
	# Make request
	self.request("%s/auth/server/register" % [authorizationServerURL], ["Authorization: Bearer %s" % [clientID], "User-Agent: Godot-LossAPI"], true, HTTPClient.METHOD_POST) 
	
	# Save parameter data
	_authorizationServerURL = authorizationServerURL

	# Logs
	_Logging.log(["Registering client"])
	_Logging.devLog(["Server URL: %s || Client ID: %s" % [authorizationServerURL, clientID]])
	
	# Fetch and parse data
	var rawRequest = yield(self, "request_completed")
	var formatedData: Dictionary = {
		"funcStatus": int(rawRequest[0]),
		"resStatus": int(rawRequest[1]),
		"resHeaders": PoolStringArray(rawRequest[2]),
		"resData": parse_json(PoolByteArray(rawRequest[3]).get_string_from_utf8())
	}

	# Error handling
	if formatedData.funcStatus != OK:
		_Logging.err(["Function error while registering client || Code: %s" % [formatedData.funcStatus]])
	
	if formatedData.resStatus != 200:
		_Logging.err(["HTTP error while registering client || Code: %s | Message: %s" % [formatedData.resStatus, formatedData.resData.message]])
	
	# Save token
	_accessJWT = formatedData.resData.message.access_token
	_refreshJWT = formatedData.resData.message.refresh_token

	# Start courutine
	_accessTimeout.start()

	# Logs
	_Logging.log(["Client succesfully registered"])
	_Logging.devLog(["\nClientID: %s\nAccessJWT: %s\nRefreshJWT: %s" % [clientID, _accessJWT, _refreshJWT]])
	return

func refreshToken() -> void:
	# Make request
	self.request("%s/auth/server/refresh" % [_authorizationServerURL], ["Authorization: Bearer %s" % [_refreshJWT], "User-Agent: Godot-LossAPI"], true, HTTPClient.METHOD_POST)

	# Logs
	_Logging.log(["Refreshing token"])
	_Logging.devLog(["Server URL: %s || Refresh JWT: %s" % [_authorizationServerURL, _refreshJWT]])

	# Fetch and parse data
	# Fetch and parse data
	var rawRequest = yield(self, "request_completed")
	var formatedData: Dictionary = {
		"funcStatus": int(rawRequest[0]),
		"resStatus": int(rawRequest[1]),
		"resHeaders": PoolStringArray(rawRequest[2]),
		"resData": parse_json(PoolByteArray(rawRequest[3]).get_string_from_utf8())
	}

	# Error handling
	if formatedData.funcStatus != OK:
		_Logging.err(["Function error while refreshing token || Code: %s" % [formatedData.funcStatus]])
	
	if formatedData.resStatus != 200:
		_Logging.err(["HTTP error while refreshing token || Code: %s | Message: %s" % [formatedData.resStatus, formatedData.resData.message]])
	
	# Save new token
	_accessJWT = formatedData.resData.message.access_token

	# Reset courutine
	_accessTimeout.start()

	# Logs
	_Logging.log(["Token refreshed"])
	_Logging.devLog(["\nAccessJWT: %s\nRefreshJWT: %s" % [_accessJWT, _refreshJWT]])
	return

# Private Methods
