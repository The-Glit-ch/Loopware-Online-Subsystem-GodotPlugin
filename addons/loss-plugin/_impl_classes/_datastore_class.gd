# Tool

# Class
class_name _LDatastoreClass

# Extends
extends Node

# Docstring
# Loopware Online Subsystem @ Godot Plugin || Datastore Module
# Module class that contains modules specific to the datastore
# service

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

# <-- /datastore Endpoint --> #

# /*
# * Creates a new collection, data can also be optionally passed in to populate the new collection
# * @param { String } collectionName - New name for the collection
# * @param { Dictionary } collectionData ( Optional ) - Data to populate
# * @returns { void }
# */
func createCollection(collectionName: String, collectionData: Dictionary = {}) -> void:
	# Format data
	var payload: Dictionary = {"cName": collectionName, "cData": collectionData} if collectionData.size() != 0 else {"cName": collectionName}

	# Logs
	_Logging.log(["Attempting to create new collection \"%s\"" % [payload.cName]])

	# Send request
	var responseData: _LResponseDataType = yield(_AuthorizationModule.secureRequest(HTTPClient.METHOD_POST, _lossConfig.datastoreServerURL + "/datastore/new-collection", payload), "completed")

	# Error handling
	if responseData.functionStatus != OK:
		_Logging.err(["Function error while creating new collection || Code: %s" % [responseData.functionStatus]])
		return

	if responseData.responseStatus != 200:
		_Logging.err(["HTTP(S) error while creating new collection || Code: %s | Message: %s" % [responseData.responseStatus, responseData.responseData.message]])
		return

	# Logs
	_Logging.log(["Successfuly created new collection \"%s\"" % [payload.cName]])
	return

# /**
# * Writes data to a specific collection
# * @param { String } collectionName - Collection to write too
# * @param { Dictionary } data - Data that should be written
# * @returns { void }
# */
func writeData(collectionName: String, data: Dictionary) -> void:
	# Format data
	var payload: Dictionary = {"cName": collectionName, "cData": data}

	# Logs
	_Logging.log(["Attempting to write data in collection \"%s\"" % [payload.cName]])

	# Send request
	var responseData: _LResponseDataType = yield(_AuthorizationModule.secureRequest(HTTPClient.METHOD_POST, _lossConfig.datastoreServerURL + "/datastore/write-data", payload), "completed")

	# Error handling
	if responseData.functionStatus != OK:
		_Logging.err(["Function error while writing data in collection \"%s\" || Code: %s" % [payload.cName, responseData.functionStatus]])
		return

	if responseData.responseStatus != 200:
		_Logging.err(["HTTP error while writing data in collection \"%s\" || Code: %s | Message: %s" % [payload.cName, responseData.responseStatus, responseData.responseData.message]])
		return

	# Logs
	_Logging.log(["Successfuly wrote data to \"%s\"" % [payload.cName]])
	return

func writeDataBulk() -> void:
	_Logging.log(["writeDataBulk() is TBI, please fallback to writeData()"])

# /**
# * Fetches data in a collection via the specified fetch query
# * @param { String } collectionName - Collection to fetch from
# * @param { Dictionary } fetchQuery - Fetch query
# * @returns { Dictionary } - Return data from the fetch
# */
func fetchData(collectionName: String, fetchQuery: Dictionary) -> Dictionary:
	# Format data
	var payload: Dictionary = {"cName": collectionName, "cFetchOptions": {"fetchQuery": fetchQuery}}

	# Logs
	_Logging.log(["Attempting to fetch data in collection \"%s\"" % [payload.cName]])

	# Send request
	var responseData: _LResponseDataType = yield(_AuthorizationModule.secureRequest(HTTPClient.METHOD_GET, _lossConfig.datastoreServerURL + "/datastore/fetch-data", payload), "completed")

	# Error handling
	if responseData.functionStatus != OK:
		_Logging.err(["Function error while fetching data from collection \"%s\" || Code: %s" % [payload.cName, responseData.functionStatus]])
		return

	if responseData.responseStatus != 200:
		_Logging.err(["HTTP error while fetching data from collection \"%s\" || Code: %s | Message: %s" % [payload.cName, responseData.responseStatus, responseData.responseData.message]])
		return
	
	# Logs
	_Logging.log(["Successfully fetched data from collection \"%s\"" % [payload.cName]])
	return responseData.responseData.data


# /**
# * Updates data in a collection via the specified fetch query
# * @param { String } collectionName - Collection the document is in
# * @param { Dictionary } fetchQuery - The fetch query
# * @param { Dictionary } newData - The new data to update/write
# * @returns { void }
# */
func updateData(collectionName: String, fetchQuery: Dictionary, newData: Dictionary) -> void:
	# Format data
	var payload: Dictionary = {"cName": collectionName, "cData": newData, "cFetchOptions": {"fetchQuery": fetchQuery}}

	# Logs
	_Logging.log(["Attempting to update data in collection \"%s\"" % [payload.cName]])

	# Send request
	var responseData: _LResponseDataType = yield(_AuthorizationModule.secureRequest(HTTPClient.METHOD_PATCH, _lossConfig.datastoreServerURL + "/datastore/update-data", payload), "completed")
	
	# Error handling
	if responseData.functionStatus != OK:
		_Logging.err(["Function error while updating data in collection \"%s\" || Code: %s" % [payload.cName, responseData.functionStatus]])
		return

	if responseData.responseStatus != 200:
		_Logging.err(["HTTP error while updating data in collection \"%s\" || Code: %s | Message: %s" % [payload.cName, responseData.responseStatus, responseData.responseData.message]])
		return
	
	# Logs
	_Logging.log(["Successfully updated data in collection \"%s\"" % [payload.cName]])
	return

func updateDataBulk() -> void:
	_Logging.log(["updateDataBulk() is TBI, please fallback to updateData()"])

# /**
# * Deletes data in a collection via the specified fetch query
# * @param { String } collectionName - Collection the document is in
# * @param { Dictionary } fetchQuery - The fetch query
# * @returns { void }
# */
func deleteData(collectionName: String, fetchQuery: Dictionary) -> void:
	# Format data
	var payload: Dictionary = {"cName": collectionName, "cFetchOptions":{"fetchQuery": fetchQuery}}

	# Logs
	_Logging.log(["Attempting to delete data in collection \"%s\"" % [payload.cName]])

	# Send request
	var responseData: _LResponseDataType = yield(_AuthorizationModule.secureRequest(HTTPClient.METHOD_DELETE, _lossConfig.datastoreServerURL + "/datastore/delete-data", payload), "completed")

	# Error handling
	if responseData.functionStatus != OK:
		_Logging.err(["Function error while deleting data in collection \"%s\" || Code: %s" % [payload.cName, responseData.functionStatus]])
		return

	if responseData.responseStatus != 200:
		_Logging.err(["HTTP error while deleting data in collection \"%s\" || Code: %s | Message: %s" % [payload.cName, responseData.responseStatus, responseData.responseData.message]])
		return

	# Logs
	_Logging.log(["Successfully deleted data in collection \"%s\"" % [payload.cName]])
	return

# /**
# * Deletes/Drops a collection
# * @param { String } collectionName - The collection to drop
# * @returns { void }
# */
func deleteCollection(collectionName: String) -> void:
	# Format data
	var payload: Dictionary = {"cName": collectionName}

	# Logs
	_Logging.log(["Attempting to delete collection \"%s\"" % [payload.cName]])

	# Send request
	var responseData: _LResponseDataType = yield(_AuthorizationModule.secureRequest(HTTPClient.METHOD_DELETE, _lossConfig.datastoreServerURL + "/datastore/delete-collection", payload), "completed")

	# Error handling
	if responseData.functionStatus != OK:
		_Logging.err(["Function error while deleting collection \"%s\" || Code: %s" % [payload.cName, responseData.functionStatus]])
		return

	if responseData.responseStatus != 200:
		_Logging.err(["HTTP error while deleting collection \"%s\" || Code: %s | Message: %s" % [payload.cName, responseData.responseStatus, responseData.responseData.message]])
		return
	
	# Logs
	_Logging.log(["Successfully deleted collection \"%s\"" % [payload.cName]])
	return

# <-- /datastore Endpoint --> #

# <-- /stream Endpoint --> #

# /**
# * Streams data from the Datastore streaming service via the specified filename/filepath
# * @param { String } fileName - The name of the file/filepath in which the data is located
# * @returns { PoolByteArray } - Return data of the stream
# */
func assetStream(fileName: String) -> PoolByteArray:
	# Format data
	var payload: Dictionary = {"fileName": fileName}

	# Logs
	_Logging.log(["Attempting to download assets"])

	# Send request
	var responseData: _LResponseDataType = yield(_AuthorizationModule.secureRequest(HTTPClient.METHOD_GET, _lossConfig.datastoreServerURL + "/stream/download", payload, false), "completed")
	
	# Error handling
	if responseData.functionStatus != OK:
		_Logging.err(["Function error while streaming data \"%s\" || Code: %s" % [payload.fileName, responseData.functionStatus]])
		return

	if responseData.responseStatus != 200:
		_Logging.err(["HTTP error while streaming data \"%s\" || Code: %s | Message: %s" % [payload.fileName, responseData.responseStatus, parse_json(responseData.responseData.get_string_from_utf8()).message]])
		return
	
	# Logs
	_Logging.log(["Successfully streamed data \"%s\"" % [payload.fileName]])
	return responseData.responseData

# Private Methods
