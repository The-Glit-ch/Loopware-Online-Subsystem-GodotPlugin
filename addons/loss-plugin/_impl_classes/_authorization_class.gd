# Tool

# Class
class_name _LAuthorizationClass

# Extends
extends HTTPRequest

# Docstring
# Loopware Online Subsystems @ Godot Plugin || Authorization Class
# Handles all authorization requests to and from the client

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables

# Private Variables
var _LossConfig: Dictionary
var _Logging: _LoggingModule

# Onready Variables

# _init()
func _init(config: Dictionary) -> void:
	# Store a copy of the configuation file
	_LossConfig = config

	# Initialize the logger
	_Logging = _LoggingModule.new()
	_Logging.enableDevLogging(_LossConfig.enableDeveloperLogs)
 
# func _ready() -> void:
#	return

# _other()

# Public Methods
func register(authorizationServerURL: String, clientID: String) -> void:
	# Make request
	self.request("%s/auth/server/register" % [authorizationServerURL], ["Authorization: Bearer %s" % [clientID], "User-Agent: Godot-LossAPI"], true, HTTPClient.METHOD_POST) 
	
	# Logs
	_Logging.log(["Registering client"])
	_Logging.devLog(["Registering client [\"%s\"] to Authorization Server [\"%s\"]" % [clientID, authorizationServerURL]])
	
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
		_Logging.err(["Error while registering client! || Code: %s" % [formatedData.funcStatus]])
		_Logging.devErr(["Server URL: \"%s\"\nClient ID: \"%s\"" % [_Logging.authorizationServerURL, _Logging.clientID]])
	
	if formatedData.resStatus != 200:
		_Logging.err([])

# Private Methods
