class_name VoronoiChunk
extends Reference
# This class will be "model" for a chunk resource and also store generated Voronoi data like site positions, polygons, and etc.

const Chunk := preload("res://src/procedural/chunk.gd")

var threshold: float = 0.5 setget set_threshold, get_threshold
# warning-ignore:unused_class_variable
var chunk_rw := ChunkReadWrite.new() setget set_chunk_rw, get_chunk_rw
var polygons: Array = [] setget set_polygons, get_polygons
var _chunk := Chunk.new() setget private_set


func _init(p_chunk: Chunk) -> void:
	_chunk = p_chunk


func commit_chunk() -> void:
	# Commits the chunk subresource onto disk.
	chunk_rw.save_chunk(_chunk)


func set_threshold(p_threshold: float) -> void:
	if p_threshold < 0.0 || p_threshold > 1.0:
		push_error("Threshold must be betwen 0 and 1.")
		return
	threshold = p_threshold


func get_threshold() -> float:
	return threshold


func get_chunk_cell() -> Vector2:
	return Vector2(_chunk.col, _chunk.row)


func get_chunk_col() -> int:
	return _chunk.col


func get_chunk_row() -> int:
	return _chunk.row


func get_chunk_seed_state() -> Array:
	return [_chunk.hashed_seed, _chunk.initial_state]


func get_chunk_points() -> PoolVector2Array:
	return _chunk.points


func set_chunk_rw(p_chunk_rw: ChunkReadWrite) -> void:
	chunk_rw = p_chunk_rw


func get_chunk_rw() -> ChunkReadWrite:
	return chunk_rw


func set_clip_outlines(p_clip_outlines: Array) -> void:
	_chunk.set_clip_outlines(p_clip_outlines)


func get_clip_outlines() -> Array:
	return _chunk.get_clip_outlines()


func set_union_outlines(p_union_outlines: Array) -> void:
	_chunk.set_union_outlines(p_union_outlines)


func get_union_outlines() -> Array:
	return _chunk.get_union_outlines()


func set_polygons(p_polygons: Array) -> void:
	for polygon in p_polygons:
		if !(polygon is PoolVector2Array):
			push_error("Unable to set polygons. Polygons must be a PoolVector2Array type!")
			return
	polygons = p_polygons


func get_polygons() -> Array:
	return polygons


func get_walked_polygons() -> Array:
	# Return a polygon list of this chunk after doing a random walk.
	var rng := RandomNumberGenerator.new()
	rng.seed = _chunk.hashed_seed
	rng.state = _chunk.initial_state
	var results: Array = []
	for polygon in polygons:
		if rng.randf() < threshold:
			results.push_back(polygon)
	return results


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
