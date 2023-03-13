# Tool

# Class
class_name _LLoggingModule 

# Extends
extends File

# Docstring
# Loopware Online Subsystems @ Godot Plugin || Logging Module
# Handles all logging of anything going on in the LossAPI

# Signals

# Enums

# Constants

# Exported Variables

# Public Variables

# Private Variables
# var _devLoggingEnabled: bool = false
var _logFileDirectory: String = "user://loss-logs"
var _logFileDate: Dictionary = Time.get_datetime_dict_from_system()
var _logFileName: String = "%s-%s-%s_%s.%s.%s.log" % [_logFileDate.month, _logFileDate.day, _logFileDate.year, _logFileDate.hour, _logFileDate.minute, _logFileDate.second]

# Onready Variables

# _init()
func _init() -> void:
	_createLoggingDirectory()

# _ready()

# _other()

# Public Methods
func log(message: Array) -> void:
	var logDate: Dictionary = Time.get_datetime_dict_from_system()
	var fullMessage: String = ""
	for part in message:
		fullMessage += "%s " % [String(part)]
	var formattedMessage: String = "[LOG @ %s/%s/%s-%s:%s:%s] %s" % [logDate.day, logDate.month, logDate.year, logDate.hour, logDate.minute, logDate.second, fullMessage]
	print(formattedMessage)
	_writeLogToFile(formattedMessage)

func wrn(message: Array) -> void:
	var logDate: Dictionary = Time.get_datetime_dict_from_system()
	var fullMessage: String = ""
	for part in message:
		fullMessage += "%s " % [String(part)]
	var formattedMessage: String = "[WRN @ %s/%s/%s-%s:%s:%s] %s" % [logDate.day, logDate.month, logDate.year, logDate.hour, logDate.minute, logDate.second, fullMessage]
	print(formattedMessage)
	_writeLogToFile(formattedMessage)

func err(message: Array) -> void:
	var logDate: Dictionary = Time.get_datetime_dict_from_system()
	var fullMessage: String = ""
	for part in message:
		fullMessage += "%s " % [String(part)]
	var formattedMessage: String = "[ERR @ %s/%s/%s-%s:%s:%s] %s" % [logDate.day, logDate.month, logDate.year, logDate.hour, logDate.minute, logDate.second, fullMessage]
	print(formattedMessage)
	_writeLogToFile(formattedMessage)

# Private Methods
func _createLoggingDirectory() -> void:
	Directory.new().make_dir(_logFileDirectory)

func _writeLogToFile(message: String) -> void:
	# Looks ugly but whatever
	if !self.file_exists("%s/%s" % [_logFileDirectory, _logFileName]):
		self.open("%s/%s" % [_logFileDirectory, _logFileName], File.WRITE)
		self.close()
	
	if self.open("%s/%s" % [_logFileDirectory, _logFileName], File.READ_WRITE) != OK:
		print("[ERR] ERROR WRITING LOG FILE")
		return
	
	self.seek_end(-1)
	self.store_line(message + "\n")
	self.close()