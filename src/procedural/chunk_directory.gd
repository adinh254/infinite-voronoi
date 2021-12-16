class_name ChunkDirectory
extends Directory


var _save_file := File.new()


func _init() -> void:
	open_new("res://save")


func has_chunk(p_col: int, p_row: int) -> bool:
	return file_exists(str(p_col) + '_' + str(p_row))
 

func save_chunk(p_col: int, p_row: int, p_data: Dictionary) -> void: 
	var file_path: String = get_current_dir() + '/' + str(p_col) + '_' + str(p_row)
	# warning-ignore:return_value_discarded
	_save_file.open(file_path, File.WRITE)
	_save_file.store_var(p_data)
	_save_file.close()


func load_chunk(p_col: int, p_row: int) -> Dictionary:
	var file_name: String = str(p_col) + '_' + str(p_row)
	if !file_exists(file_name):
		return {}
	var file_path: String = get_current_dir() + '/' + file_name
	# warning-ignore:return_value_discarded
	_save_file.open(file_path, File.READ)
	var loaded: Dictionary = _save_file.get_var()
	_save_file.close()
	return loaded


func open_new(p_path: String) -> void:
	if !dir_exists(p_path):
		# warning-ignore:return_value_discarded
		make_dir(p_path)
	# warning-ignore:return_value_discarded
	open(p_path)


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
