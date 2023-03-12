# Tool

# Class
class_name _LDatastoreLeaderboardModule

# Extends
extends Node

# Docstring
# Loopware Online Subsystem Godot Plugin @ Leaderboard Service Module || Allows for the creation, reading, updating, and deletion
# of custom leaderboards

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
# Self
var _leaderboardEndpoints: Dictionary = {
	newLeaderboard="/leaderboard/api/v1/new-leaderboard",
	newCategory="/leaderboard/api/v1/new-category",
	addRecord="/leaderboard/api/v1/add-record",
	fetchRecords="/leaderboard/api/v1/fetch-records",
	updateRecord="/leaderboard/api/v1/update-record",
	deleteRecord="/leaderboard/api/v1/delete-record",
	deleteCategory="/leaderboard/api/v1/delete-category",
	deleteLeaderboard="/leaderboard/api/v1/delete-leaderboard",
}

# Onready Variables

# _init()
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
func newLeaderboard(leaderboardName: String) -> _LMethodResponseData:
	# Format payload
	var dataPayload: Dictionary = { "leaderboardName": leaderboardName }
	var requestURL: String = "%s%s" % [_lossConfigRef.datastoreServerURL, _leaderboardEndpoints.newLeaderboard]

	# Log
	_loggingModuleRef.log(["Attempting to create new leaderboard \"%s\"" % [leaderboardName]])

	# Send request
	var responseData: _LMethodResponseData = yield(_authModuleRef.makeSecureRequest(requestURL, HTTPClient.METHOD_POST, dataPayload), "completed")

	# Generic error handling
	if responseData.hasError():
		return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[0], "errorCode": responseData.getErrorDetails()[1]})

	# HTTP/Function error handling
	var httpResponseData: _LHTTPResponseData = responseData.getReturnData()
	if httpResponseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while creating new leaderboard || Code: %s" % [httpResponseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": httpResponseData.functionStatus})
	
	if httpResponseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while creating new leaderboard || Code: %s | Message: %s" % [httpResponseData.responseStatus, httpResponseData.toJSON().message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [httpResponseData.toJSON()["message"]], "errorCode": "%s" % [httpResponseData.responseStatus]})	

	# Log
	_loggingModuleRef.log(["Successfully made leaderboard \"%s\"" % [leaderboardName]])

	return _LMethodResponseData.new({})

func newCategory(leaderboardName: String, leaderboardCategory: String) -> _LMethodResponseData:
	# Format payload
	var dataPayload: Dictionary = { "leaderboardName": leaderboardName, "leaderboardCategory": leaderboardCategory }
	var requestURL: String = "%s%s" % [_lossConfigRef.datastoreServerURL, _leaderboardEndpoints.newCategory]

	# Log
	_loggingModuleRef.log(["Attempting to create new leaderboard category \"%s\"" % [leaderboardCategory]])

	# Send request
	var responseData: _LMethodResponseData = yield(_authModuleRef.makeSecureRequest(requestURL, HTTPClient.METHOD_POST, dataPayload), "completed")
	
	# Generic error handling
	if responseData.hasError():
		return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[0], "errorCode": responseData.getErrorDetails()[1]})

	# HTTP/Function error handling
	var httpResponseData: _LHTTPResponseData = responseData.getReturnData()
	if httpResponseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while creating new category || Code: %s" % [httpResponseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": httpResponseData.functionStatus})
	
	if httpResponseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while creating new category || Code: %s | Message: %s" % [httpResponseData.responseStatus, httpResponseData.toJSON().message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [httpResponseData.toJSON()["message"]], "errorCode": "%s" % [httpResponseData.responseStatus]})

	# Log
	_loggingModuleRef.log(["Successfully made leaderboard category \"%s\"" % [leaderboardCategory]])

	return _LMethodResponseData.new({})

func addRecord(leaderboardName: String, leaderboardCategory: String, leaderboardRecordIndex: String, leaderboardRecordData) -> _LMethodResponseData:
	# Format payload
	var dataPayload: Dictionary = { "leaderboardName": leaderboardName, "leaderboardCategory": leaderboardCategory, "leaderboardRecordIndex": leaderboardRecordIndex, "leaderboardRecordData": leaderboardRecordData }
	var requestURL: String = "%s%s" % [_lossConfigRef.datastoreServerURL, _leaderboardEndpoints.addRecord]	

	# Log
	_loggingModuleRef.log(["Attempting to add new record to leaderboard \"%s@%s\"" % [leaderboardName, leaderboardCategory]])

	# Send request
	var responseData: _LMethodResponseData = yield(_authModuleRef.makeSecureRequest(requestURL, HTTPClient.METHOD_POST, dataPayload), "completed")
	
	# Generic error handling
	if responseData.hasError():
		return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[0], "errorCode": responseData.getErrorDetails()[1]})

	# HTTP/Function error handling
	var httpResponseData: _LHTTPResponseData = responseData.getReturnData()
	if httpResponseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while adding new record || Code: %s" % [httpResponseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": httpResponseData.functionStatus})
	
	if httpResponseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while adding new record || Code: %s | Message: %s" % [httpResponseData.responseStatus, httpResponseData.toJSON().message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [httpResponseData.toJSON()["message"]], "errorCode": "%s" % [httpResponseData.responseStatus]})

	# Log
	_loggingModuleRef.log(["Successfully added new record to leaderboard \"%s@%s\"" % [leaderboardName, leaderboardCategory]])

	return _LMethodResponseData.new({})

func fetchRecords(leaderboardName: String, leaderboardCategory: String) -> _LMethodResponseData:
	# Format payload
	var dataPayload: Dictionary = { "leaderboardName": leaderboardName, "leaderboardCategory": leaderboardCategory, }
	var requestURL: String = "%s%s" % [_lossConfigRef.datastoreServerURL, _leaderboardEndpoints.fetchRecords]

	# Log
	_loggingModuleRef.log(["Attempting to fetch records from leaderboard \"%s@%s\"" % [leaderboardName, leaderboardCategory]])

	# Send request
	var responseData: _LMethodResponseData = yield(_authModuleRef.makeSecureRequest(requestURL, HTTPClient.METHOD_GET, dataPayload), "completed")
	
	# Generic error handling
	if responseData.hasError():
		return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[0], "errorCode": responseData.getErrorDetails()[1]})

	# HTTP/Function error handling
	var httpResponseData: _LHTTPResponseData = responseData.getReturnData()
	if httpResponseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while fetching records || Code: %s" % [httpResponseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": httpResponseData.functionStatus})
	
	if httpResponseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while fetching records || Code: %s | Message: %s" % [httpResponseData.responseStatus, httpResponseData.toJSON().message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [httpResponseData.toJSON()["message"]], "errorCode": "%s" % [httpResponseData.responseStatus]})

	# Get return data
	var fetchedRecords: Dictionary = httpResponseData.toJSON()["data"]

	# Log
	_loggingModuleRef.log(["Successfully fetched records from leaderboard \"%s@%s\"" % [leaderboardName, leaderboardCategory]])
	
	return _LMethodResponseData.new({"returnData": fetchedRecords})

func updateRecord(leaderboardName: String, leaderboardCategory: String, leaderboardRecordIndex: String, leaderboardRecordData) -> _LMethodResponseData:
	# Format payload
	var dataPayload: Dictionary = { "leaderboardName": leaderboardName, "leaderboardCategory": leaderboardCategory, "leaderboardRecordIndex": leaderboardRecordIndex, "leaderboardRecordData": leaderboardRecordData }
	var requestURL: String = "%s%s" % [_lossConfigRef.datastoreServerURL, _leaderboardEndpoints.updateRecord]
	
	# Log
	_loggingModuleRef.log(["Attempting to update record in leaderboard \"%s@%s\"" % [leaderboardName, leaderboardCategory]])

	# Send request
	var responseData: _LMethodResponseData = yield(_authModuleRef.makeSecureRequest(requestURL, HTTPClient.METHOD_PATCH, dataPayload), "completed")
	
	# Generic error handling
	if responseData.hasError():
		return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[0], "errorCode": responseData.getErrorDetails()[1]})

	# HTTP/Function error handling
	var httpResponseData: _LHTTPResponseData = responseData.getReturnData()
	if httpResponseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while updating record || Code: %s" % [httpResponseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": httpResponseData.functionStatus})
	
	if httpResponseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while updating record || Code: %s | Message: %s" % [httpResponseData.responseStatus, httpResponseData.toJSON().message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [httpResponseData.toJSON()["message"]], "errorCode": "%s" % [httpResponseData.responseStatus]})

	# Log
	_loggingModuleRef.log(["Successfully updated record in leaderboard \"%s@%s\"" % [leaderboardName, leaderboardCategory]])

	return _LMethodResponseData.new({})	

func deleteRecord() -> _LMethodResponseData:
	return _LMethodResponseData.new({})

func deleteCatgeory(leaderboardName: String, leaderboardCategory: String) -> _LMethodResponseData:
	# Format payload
	var dataPayload: Dictionary = { "leaderboardName": leaderboardName, "leaderboardCategory": leaderboardCategory, }
	var requestURL: String = "%s%s" % [_lossConfigRef.datastoreServerURL, _leaderboardEndpoints.deleteCategory]

	# Log
	_loggingModuleRef.log(["Attempting to delete category in leaderboard \"%s@%s\"" % [leaderboardName, leaderboardCategory]])

	# Send request
	var responseData: _LMethodResponseData = yield(_authModuleRef.makeSecureRequest(requestURL, HTTPClient.METHOD_DELETE, dataPayload), "completed")
	
	# Generic error handling
	if responseData.hasError():
		return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[0], "errorCode": responseData.getErrorDetails()[1]})

	# HTTP/Function error handling
	var httpResponseData: _LHTTPResponseData = responseData.getReturnData()
	if httpResponseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while deleting category || Code: %s" % [httpResponseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": httpResponseData.functionStatus})
	
	if httpResponseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while deleting category || Code: %s | Message: %s" % [httpResponseData.responseStatus, httpResponseData.toJSON().message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [httpResponseData.toJSON()["message"]], "errorCode": "%s" % [httpResponseData.responseStatus]})

	# Log
	_loggingModuleRef.log(["Successfully deleted category in leaderboard \"%s@%s\"" % [leaderboardName, leaderboardCategory]])

	return _LMethodResponseData.new({})

func deleteLeaderboard(leaderboardName: String) -> _LMethodResponseData:
	# Format payload
	var dataPayload: Dictionary = { "leaderboardName": leaderboardName, }
	var requestURL: String = "%s%s" % [_lossConfigRef.datastoreServerURL, _leaderboardEndpoints.deleteLeaderboard]

	# Log
	_loggingModuleRef.log(["Attempting to delete leaderboard \"%s\"" % [leaderboardName]])

	# Send request
	var responseData: _LMethodResponseData = yield(_authModuleRef.makeSecureRequest(requestURL, HTTPClient.METHOD_DELETE, dataPayload), "completed")
	
	# Generic error handling
	if responseData.hasError():
		return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[0], "errorCode": responseData.getErrorDetails()[1]})

	# HTTP/Function error handling
	var httpResponseData: _LHTTPResponseData = responseData.getReturnData()
	if httpResponseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while deleting leaderboard || Code: %s" % [httpResponseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": httpResponseData.functionStatus})
	
	if httpResponseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while deleting leaderboard || Code: %s | Message: %s" % [httpResponseData.responseStatus, httpResponseData.toJSON().message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [httpResponseData.toJSON()["message"]], "errorCode": "%s" % [httpResponseData.responseStatus]})

	# Log
	_loggingModuleRef.log(["Successfully deleted category in leaderboard \"%s\"" % [leaderboardName]])	

	return _LMethodResponseData.new({})

# Private Methods
