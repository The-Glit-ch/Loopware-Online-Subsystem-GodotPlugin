# Tool

# Class
class_name _LDatastoreServiceModule

# Extends
extends Node

# Docstring
# Loopware Online Subsystem Godot Plugin @ Datastore Service Module || Allows for reading and writing to the
# Loss datastore service

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
var _datastoreEndpoints: Dictionary = {
	newCollection="/datastore/api/v1/new-collection",
	writeData="/datastore/api/v1/write-data",
	fetchData="/datastore/api/v1/fetch-data",
	updateData="/datastore/api/v1/update-data",
	replaceData="/datastore/api/v1/replace-data",
	deleteData="/datastore/api/v1/delete-data",
	deleteCollection="/datastore/api/v1/delete-collection",
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
# /**
# * Creates a new collection
# * @param { String } collectionName - Name of the collection
# * @param { Dictionary } optionalData - Optional data that should be written to the collection once created
# * @returns { _LMethodResponseData } - Response data
# */
func newCollection(collectionName: String, optionalData: Dictionary = {}) -> _LMethodResponseData:
	# Format payload
	optionalData = optionalData if optionalData.size() != 0 else {}
	var dataPayload: Dictionary = { "collectionName": collectionName, "writeData": optionalData }
	var requestURL: String = "%s%s" % [_lossConfigRef.datastoreServerURL, _datastoreEndpoints.newCollection]

	# Log
	_loggingModuleRef.log(["Attempting to create new collection \"%s\"" % [collectionName]])

	# Send request
	var responseData: _LMethodResponseData = yield(_authModuleRef.makeSecureRequest(requestURL, HTTPClient.METHOD_POST, dataPayload), "completed")

	# Generic Error handling
	if responseData.hasError():
		return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[0], "errorCode": responseData.getErrorDetails()[1]})

	# HTTP/Function Error handling
	var httpResponseData: _LHTTPResponseData = responseData.getReturnData()
	if httpResponseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while creating new collection || Code: %s" % [httpResponseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": httpResponseData.functionStatus})
	
	if httpResponseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while creating new collection || Code: %s | Message: %s" % [httpResponseData.responseStatus, httpResponseData.toJSON().message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [httpResponseData.toJSON()["message"]], "errorCode": "%s" % [httpResponseData.responseStatus]})

	# Log
	_loggingModuleRef.log(["Successfully made collection \"%s\"" % [collectionName]])
	
	return _LMethodResponseData.new({})

# /**
# * Writes data into a collection
# * @param { String } collectionName - Name of the collection
# * @param { Dictionary } writeData - Data to write
# * @returns { _LMethodResponseData } - Response data
# */
func writeData(collectionName: String, writeData: Dictionary) -> _LMethodResponseData:
	# Format payload
	var dataPayload: Dictionary = { "collectionName": collectionName, "writeData": writeData }
	var requestURL: String = "%s%s" % [_lossConfigRef.datastoreServerURL, _datastoreEndpoints.writeData]

	# Log
	_loggingModuleRef.log(["Attempting to write to collection \"%s\"" % [collectionName]])

	# Send request
	var responseData: _LMethodResponseData = yield(_authModuleRef.makeSecureRequest(requestURL, HTTPClient.METHOD_POST, dataPayload), "completed")

	# Generic Error handling
	if responseData.hasError():
		return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[0], "errorCode": responseData.getErrorDetails()[1]})

	# HTTP/Function Error handling
	var httpResponseData: _LHTTPResponseData = responseData.getReturnData()
	if httpResponseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while writing data || Code: %s" % [httpResponseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": httpResponseData.functionStatus})
	
	if httpResponseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while writing data || Code: %s | Message: %s" % [httpResponseData.responseStatus, httpResponseData.toJSON().message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [httpResponseData.toJSON()["message"]], "errorCode": "%s" % [httpResponseData.responseStatus]})
	
	# Log
	_loggingModuleRef.log(["Successfully wrote to collection \"%s\"" % [collectionName]])

	return _LMethodResponseData.new({})

# /**
# * Fetches data from a collection
# * @param { String } collectionName - Name of the collection
# * @param [ Dictionary ] fetchQuery - A filter that matches to a currently existing document
# * @param { Dictionary } fetchProjection - What to return from the document (Does not work as intended)
# * @returns { _LMethodResponseData } - Response data
# */
func fetchData(collectionName: String, fetchQuery: Dictionary, fetchProjection: Dictionary = {}) -> _LMethodResponseData:
	# Format payload
	fetchProjection = fetchProjection if fetchProjection.size() != 0 else {}
	var dataPayload: Dictionary = { "collectionName": collectionName, "fetchQuery": {"query": fetchQuery, "projection": fetchProjection} }
	var requestURL: String = "%s%s" % [_lossConfigRef.datastoreServerURL, _datastoreEndpoints.fetchData]

	# Log
	_loggingModuleRef.log(["Attempting to fetch data from collection \"%s\"" % [collectionName]])

	# Send request
	var responseData: _LMethodResponseData = yield(_authModuleRef.makeSecureRequest(requestURL, HTTPClient.METHOD_GET, dataPayload), "completed")

	# Generic Error handling
	if responseData.hasError():
		return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[0], "errorCode": responseData.getErrorDetails()[1]})

	# HTTP/Function Error handling
	var httpResponseData: _LHTTPResponseData = responseData.getReturnData()
	if httpResponseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while fetching data data || Code: %s" % [httpResponseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": httpResponseData.functionStatus})

	if httpResponseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while fetching data || Code: %s | Message: %s" % [httpResponseData.responseStatus, httpResponseData.toJSON().message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [httpResponseData.toJSON()["message"]], "errorCode": "%s" % [httpResponseData.responseStatus]})

	# Save fetched data
	var fetchedData: Dictionary = httpResponseData.toJSON().data

	# Log
	_loggingModuleRef.log(["Successfully fetched data from collection \"%s\"" % [collectionName]])

	return _LMethodResponseData.new({"returnData": fetchedData})

# /**
# * Updates data in a collection
# * @param { String } collectionName - Name of the collection
# * @param [ Dictionary ] fetchQuery - A filter that matches to a currently existing document
# * @param { Dictionary } writeData - Data to write
# * @returns { _LMethodResponseData } - Response data
# */
func updateData(collectionName: String, fetchQuery: Dictionary, writeData: Dictionary) -> _LMethodResponseData:
	# Format payload
	var dataPayload: Dictionary = { "collectionName": collectionName, "fetchQuery": {"query": fetchQuery},"writeData": writeData }
	var requestURL: String = "%s%s" % [_lossConfigRef.datastoreServerURL, _datastoreEndpoints.updateData]

	# Log
	_loggingModuleRef.log(["Attempting to update data in collection \"%s\"" % [collectionName]])

	# Send request
	var responseData: _LMethodResponseData = yield(_authModuleRef.makeSecureRequest(requestURL, HTTPClient.METHOD_PATCH, dataPayload), "completed")

	# Generic Error handling
	if responseData.hasError():
		return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[0], "errorCode": responseData.getErrorDetails()[1]})

	# HTTP/Function Error handling
	var httpResponseData: _LHTTPResponseData = responseData.getReturnData()
	if httpResponseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while updating data || Code: %s" % [httpResponseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": httpResponseData.functionStatus})

	if httpResponseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while updating data || Code: %s | Message: %s" % [httpResponseData.responseStatus, httpResponseData.toJSON().message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [httpResponseData.toJSON()["message"]], "errorCode": "%s" % [httpResponseData.responseStatus]})
	
	# Log
	_loggingModuleRef.log(["Successfully updated data in collection \"%s\"" % [collectionName]])

	return _LMethodResponseData.new({})
	
# /**
# * Replaces data in a collection
# * @param { String } collectionName - Name of the collection
# * @param [ Dictionary ] fetchQuery - A filter that matches to a currently existing document
# * @param { Dictionary } writeData - Data to write
# * @returns { _LMethodResponseData } - Response data
# */
func replaceData(collectionName: String, fetchQuery: Dictionary, writeData: Dictionary) -> _LMethodResponseData:
	# Format payload
	var dataPayload: Dictionary = { "collectionName": collectionName, "fetchQuery": {"query": fetchQuery}, "writeData": writeData }
	var requestURL: String = "%s%s" % [_lossConfigRef.datastoreServerURL, _datastoreEndpoints.replaceData]

	# Log
	_loggingModuleRef.log(["Attempting to replace data in collection \"%s\"" % [collectionName]])

	# Send request
	var responseData: _LMethodResponseData = yield(_authModuleRef.makeSecureRequest(requestURL, HTTPClient.METHOD_PUT, dataPayload), "completed")

	# Generic Error handling
	if responseData.hasError():
		return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[0], "errorCode": responseData.getErrorDetails()[1]})

	# HTTP/Function Error handling
	var httpResponseData: _LHTTPResponseData = responseData.getReturnData()
	if httpResponseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while replacing data || Code: %s" % [httpResponseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": httpResponseData.functionStatus})
	
	if httpResponseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while replacing data || Code: %s | Message: %s" % [httpResponseData.responseStatus, httpResponseData.toJSON().message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [httpResponseData.toJSON()["message"]], "errorCode": "%s" % [httpResponseData.responseStatus]})

	# Log
	_loggingModuleRef.log(["Successfully replaced data in collection \"%s\"" % [collectionName]])

	return _LMethodResponseData.new({})

# /**
# * Deletes data in a collection
# * @param { String } collectionName - Name of the collection
# * @param [ Dictionary ] fetchQuery - A filter that matches to a currently existing document
# * @returns { _LMethodResponseData } - Response data
# */
func deleteData(collectionName: String, fetchQuery: Dictionary) -> _LMethodResponseData:
	# Format payload
	var dataPayload: Dictionary = { "collectionName": collectionName, "fetchQuery": {"query": fetchQuery} }
	var requestURL: String = "%s%s" % [_lossConfigRef.datastoreServerURL, _datastoreEndpoints.deleteData]

	# Log
	_loggingModuleRef.log(["Attempting to delete data in collection \"%s\"" % [collectionName]])

	# Send request
	var responseData: _LMethodResponseData = yield(_authModuleRef.makeSecureRequest(requestURL, HTTPClient.METHOD_DELETE, dataPayload), "completed")

	# Generic Error handling
	if responseData.hasError():
		return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[0], "errorCode": responseData.getErrorDetails()[1]})

	# HTTP/Function Error handling
	var httpResponseData: _LHTTPResponseData = responseData.getReturnData()
	if httpResponseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while deleting data || Code: %s" % [httpResponseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": httpResponseData.functionStatus})

	if httpResponseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while deleting data || Code: %s | Message: %s" % [httpResponseData.responseStatus, httpResponseData.toJSON().message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [httpResponseData.toJSON()["message"]], "errorCode": "%s" % [httpResponseData.responseStatus]})	

	# Log
	_loggingModuleRef.log(["Successfully deleted data in collection \"%s\"" % [collectionName]])

	return _LMethodResponseData.new({})

# /**
# * Deletes a collection
# * @param { String } collectionName - Name of the collection
# * @returns { _LMethodResponseData } - Response data
# */
func deleteCollection(collectionName: String) -> _LMethodResponseData:
	# Format payload
	var dataPayload: Dictionary = { "collectionName": collectionName }
	var requestURL: String = "%s%s" % [_lossConfigRef.datastoreServerURL, _datastoreEndpoints.deleteCollection]

	# Log
	_loggingModuleRef.log(["Attempting to delete collection \"%s\"" % [collectionName]])

	# Send request
	var responseData: _LMethodResponseData = yield(_authModuleRef.makeSecureRequest(requestURL, HTTPClient.METHOD_DELETE, dataPayload), "completed")

	# Generic Error handling
	if responseData.hasError():
		return _LMethodResponseData.new({"errorMessage": responseData.getErrorDetails()[0], "errorCode": responseData.getErrorDetails()[1]})

	# HTTP/Function Error handling
	var httpResponseData: _LHTTPResponseData = responseData.getReturnData()
	if httpResponseData.functionStatus != OK:
		_loggingModuleRef.err(["Function error while deleting collection || Code: %s" % [httpResponseData.functionStatus]])
		return _LMethodResponseData.new({"errorMessage": "Function error", "errorCode": httpResponseData.functionStatus})
	
	if httpResponseData.responseStatus != 200:
		_loggingModuleRef.err(["HTTP(S) error while deleting collection || Code: %s | Message: %s" % [httpResponseData.responseStatus, httpResponseData.toJSON().message]])
		return _LMethodResponseData.new({"errorMessage": "HTTP(S) error || %s" % [httpResponseData.toJSON()["message"]], "errorCode": "%s" % [httpResponseData.responseStatus]})

	# Log
	_loggingModuleRef.log(["Successfully deleted collection \"%s\"" % [collectionName]])

	return _LMethodResponseData.new({})


# Private Methods
