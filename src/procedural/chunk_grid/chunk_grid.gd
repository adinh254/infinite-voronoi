class_name ChunkGrid
extends Node2D
# Grid node for calculating grid coordinates for chunks.
# This node will not consider basis transformations for chunks and only considers translation or positioning.

const Globals := preload("res://src/globals.gd")

export var chunk_size: float = 96.0
onready var _chunk_dimensions := Vector2(chunk_size * Globals.UNIT_SCALE, chunk_size * Globals.UNIT_SCALE) setget private_set, get_chunk_dimensions  # 960x960px assuming default settings are used. 
#export var max_chunks := Vector2(INF, INF)


func map_to_global(p_col: int, p_row: int) -> Vector2:
	return global_position + Vector2(
		p_col * _chunk_dimensions.x,
		p_row * _chunk_dimensions.y
	)


func global_to_map(p_global_pos: Vector2) -> Vector2:
	# Return in (col, row) format.
	var local_pos: Vector2 = to_local(p_global_pos)
	return Vector2(local_pos.x / _chunk_dimensions.x,
				   local_pos.y / _chunk_dimensions.y).floor()


func get_region_intersected_with_rect(p_aabb: Rect2) -> Rect2:
	var aabb_pos_chunk: Vector2 = global_to_map(p_aabb.position)
	var aabb_end_chunk: Vector2 = global_to_map(p_aabb.end)
	var pos_chunk_global: Vector2 = map_to_global(int(aabb_pos_chunk.x), int(aabb_pos_chunk.y))
	var end_chunk_global: Vector2 = map_to_global(int(aabb_end_chunk.x), int(aabb_end_chunk.y))
	return Rect2(pos_chunk_global, end_chunk_global + _chunk_dimensions - pos_chunk_global)


func get_chunk_rect(p_col: int, p_row: int) -> Rect2:
	return Rect2(map_to_global(p_col, p_row), _chunk_dimensions)


func get_chunk_dimensions() -> Vector2:
	return _chunk_dimensions


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
