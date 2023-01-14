# Tool

# Class
class_name _LDatastoreClass

# Extends
extends Node

# Docstring
#
#
#

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
func _init(authorizationRefrence: _LAuthorizationClass, loggingModule: _LoggingModule, lossConfig: Dictionary) -> void:
	# Save reference
	_AuthorizationModule = authorizationRefrence
	_Logging = loggingModule
	_lossConfig = lossConfig

# _ready()
# func _ready() -> void:
# 	pass

# _other()

# Public Methods
func createCollection(params: Dictionary) -> void:
	# Send request
	var responseData: Dictionary = yield(_AuthorizationModule.secureRequest(HTTPClient.METHOD_POST, _lossConfig.datastoreServerURL + "/datastore/new-collection", params), "completed")

	# Error handling
	if responseData.funcStatus != OK:
		_Logging.err(["Function error while creating new collection || Code: %s" % [responseData.funcStatus]])

	if responseData.resStatus != 200:
		_Logging.err(["HTTP error while rcreating new collection || Code: %s | Message: %s" % [responseData.resStatus, responseData.resData.message]])

	# Logs
	_Logging.log(["Successfuly created new collection \"%s\"" % [params.cName]])

	return

func writeData(params: Dictionary) -> void:
	# Send request
	


# Private Methods