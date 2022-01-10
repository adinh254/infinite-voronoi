class_name ChunkReadWrite
extends Reference

const Chunk := preload("res://src/procedural/chunk.gd")
const Globals := preload("res://src/globals.gd")
enum ReadWriteFormat {
	BINARY, # .res
	TEXT, # .tres
	MAX
}

var rw_format: int = ReadWriteFormat.BINARY setget set_rw_format, get_rw_format
var _directory := Directory.new() setget private_set
var _rw_extension: String = "res" setget private_set, get_rw_extension


func is_chunk_cached(p_col: int, p_row: int) -> bool:
	return ResourceLoader.has_cached("%s/%d_%d.%s" % [_directory.get_current_dir(), p_col, p_row, _rw_extension])


func chunk_exists(p_col: int, p_row: int) -> bool:
	return ResourceLoader.exists("%s/%d_%d.%s" % [_directory.get_current_dir(), p_col, p_row, _rw_extension])


func save_chunk(p_chunk: Chunk) -> void:
	if ResourceSaver.save("%s/%d_%d.%s" % [_directory.get_current_dir(), p_chunk.col, p_chunk.row, _rw_extension], p_chunk as Resource):
		push_error("Unable to save resource of type Chunk.")


func load_chunk(p_col: int, p_row: int) -> Chunk:
	return ResourceLoader.load("%s/%d_%d.%s" % [_directory.get_current_dir(), p_col, p_row, _rw_extension]) as Chunk


func open_new_dir(p_dir_path: String) -> void:
	# Opens a new directory at this location or 
	# creates a new one if directory doesn't exist.
	if !_directory.dir_exists(p_dir_path) && _directory.make_dir_recursive(p_dir_path):
			push_error("Unable to create a new save directory. Directory path is invalid.")
			return
	if _directory.open(p_dir_path):
		push_error("Unable to open a save directory. Directory path is invalid.")


func get_dir_path() -> String:
	return _directory.get_current_dir()


func set_rw_format(p_rw_format: int) -> void:
	match p_rw_format:
		ReadWriteFormat.BINARY:
			_rw_extension = "res"
		ReadWriteFormat.TEXT:
			_rw_extension = "tres"
		_:
			push_error("Unable to set rw_format. Passed in argument is not of enum type ReadWriteFormat.")
			return
	rw_format = p_rw_format


func get_rw_format() -> int:
	return rw_format


func get_rw_extension() -> String:
	return _rw_extension


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
