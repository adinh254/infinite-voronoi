class_name CellGrid
extends Node2D
# Grid node for calculating grid coordinates for cells.
# This node will not consider basis transformations for cells and only considers translation or positioning.

const Globals := preload("res://src/globals.gd")

export var cell_size: int = 96 setget set_cell_size, get_cell_size
var _cell_transform := Transform2D(Vector2(cell_size * Globals.UNIT_SCALE, 0.0), Vector2(0.0, cell_size * Globals.UNIT_SCALE), Vector2.ZERO) setget private_set


func map_to_world(p_col: int, p_row: int) -> Vector2:
	return transform.xform(_cell_transform.xform(Vector2(p_col, p_row)))


func global_to_map(p_global_pos: Vector2) -> Vector2:
	# Return in (col, row) format.
	return _cell_transform.affine_inverse().xform(global_transform.xform_inv(p_global_pos)).floor()


func get_region_intersected_with_rect(p_aabb: Rect2) -> Rect2:
	var aabb_pos_cell: Vector2 = global_to_map(p_aabb.position)
	var aabb_end_cell: Vector2 = global_to_map(p_aabb.end)
	var pos_cell_global: Vector2 = map_to_world(int(aabb_pos_cell.x), int(aabb_pos_cell.y))
	var end_cell_global: Vector2 = map_to_world(int(aabb_end_cell.x), int(aabb_end_cell.y))
	return Rect2(pos_cell_global, end_cell_global + _cell_transform.get_scale() - pos_cell_global)


func get_cell_world_rect(p_col: int, p_row: int) -> Rect2:
	return Rect2(map_to_world(p_col, p_row), _cell_transform.get_scale())


func set_cell_size(p_cell_size: int) -> void:
	cell_size = p_cell_size
	_cell_transform = Transform2D(Vector2(cell_size * Globals.UNIT_SCALE, 0.0), Vector2(0.0, cell_size * Globals.UNIT_SCALE), Vector2.ZERO)


func get_cell_size() -> int:
	return cell_size


func get_cell_dimensions() -> Vector2:
	return _cell_transform.get_scale()


func get_cell_transform() -> Transform2D:
	return _cell_transform


func get_cell_world_transform() -> Transform2D:
	return transform * _cell_transform


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
