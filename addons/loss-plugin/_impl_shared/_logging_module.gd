# Tool

# Class & Extends
class_name _LoggingModule extends File

# Docstring
# Loopware Online Subsystems @ Godot Plugin || Logging Module
# Handles all logging of anything going on in the LossAPI
# Note: "devLogging" should be disabled in your final build as it can leak
# sensitive information

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables

# Private Variables
var _devLoggingEnabled: bool
var _logFileDirectory: String = "user://loss-logs"
var _logFileDate: Dictionary = Time.get_datetime_dict_from_system()
var _logOutputDate: Dictionary = Time.get_date_dict_from_system()
var _logFileName: String = "%s-%s-%s_%s.%s.%s.log" % [_logFileDate.month, _logFileDate.day, _logFileDate.year, _logFileDate.hour, _logFileDate.minute, _logFileDate.second]

# Onready Variables

# _init()
func _init() -> void:
	_createLoggingDirectory()

# _ready()
# func _ready() -> void:
# 	pass

# _other()

# Public Methods
func enableDevLogging(enable: bool) -> void:
	_devLoggingEnabled = enable

func log(message: Array) -> void:
	var combined: String = "[LOG @ %s/%s/%s] " % [_logOutputDate.day, _logOutputDate.month, _logOutputDate.year]
	for part in message:
		combined += "%s " % [String(part)]
	print(combined)
	_writeLogToFile(combined)

func wrn(message: Array) -> void:
	var combined: String = "[WRN @ %s/%s/%s] " % [_logOutputDate.day, _logOutputDate.month, _logOutputDate.year]
	for part in message:
		combined += "%s " % [String(part)]
	print(combined)
	_writeLogToFile(combined)

func err(message: Array) -> void:
	var combined: String = "[ERR @ %s/%s/%s] " % [_logOutputDate.day, _logOutputDate.month, _logOutputDate.year]
	for part in message:
		combined += "%s " % [String(part)]
	print(combined)
	_writeLogToFile(combined)

func devLog(message: Array) -> void:
	if !_devLoggingEnabled:
		return
	
	var combined: String = "[dLOG @ %s/%s/%s] " % [_logOutputDate.day, _logOutputDate.month, _logOutputDate.year]
	for part in message:
		combined += "%s " % [String(part)]
	print(combined)
	_writeLogToFile(combined)

func devWrn(message: Array) -> void:
	if !_devLoggingEnabled:
		return
	
	var combined: String = "[dWRN @ %s/%s/%s] " % [_logOutputDate.day, _logOutputDate.month, _logOutputDate.year]
	for part in message:
		combined += "%s " % [String(part)]
	print(combined)
	_writeLogToFile(combined)

func devErr(message: Array) -> void:
	if !_devLoggingEnabled:
		return
	
	var combined: String = "[dERR @ %s/%s/%s] " % [_logOutputDate.day, _logOutputDate.month, _logOutputDate.year]
	for part in message:
		combined += "%s " % [String(part)]
	print(combined)
	_writeLogToFile(combined)

# Private Methods
func _createLoggingDirectory() -> void:
	Directory.new().make_dir(_logFileDirectory)

func _writeLogToFile(message: String) -> void:
	if !self.file_exists("%s/%s" % [_logFileDirectory, _logFileName]):
		self.open("%s/%s" % [_logFileDirectory, _logFileName], File.WRITE)
		self.close()
	
	if self.open("%s/%s" % [_logFileDirectory, _logFileName], File.READ_WRITE) != OK:
		print("[ERR] ERROR WRITING LOG FILE")
		return
	
	self.seek_end(-1)
	self.store_line(message + "\n")
	self.close()