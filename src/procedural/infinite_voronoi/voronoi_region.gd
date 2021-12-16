class_name VoronoiRegion
extends Reference
# TODO REFACTOR File loading options if player wants to save or only generate.

var pos_col: int = 0
var pos_row: int = 0
var column_count: int = 1 setget set_column_count
var row_count: int = 1 setget set_row_count
var chunk_grid := ChunkGrid.new() setget set_chunk_grid
var chunk_dir := ChunkDirectory.new() setget set_chunk_dir # Save/Load Directory
var master_seed: int = 0 setget set_master_seed
var min_gen_chunk_points: int = 48 setget set_min_gen_chunk_points
var max_gen_chunk_points: int = 48  setget set_max_gen_chunk_points
var _voronoi_diagram := Reference.new() setget private_set
var _chunk_map: Dictionary = {} setget private_set # Key:Value format is { (x, y): Vector2 : { 'seed': int, 'state': int, 'points': PoolVector2Array, 'site_indices': Array }
var _chunks_by_site := PoolVector2Array() setget private_set # Chunk grid positions mapped by generated diagram site index.
var _site_positions := PoolVector2Array() setget private_set # Site positions belonging to the built voronoi diagram.
var _site_count: int = 0 setget private_set # Site indices corresponding to the number of sites of the built voronoi diagram. 
var _rng := RandomNumberGenerator.new() setget private_set
var _hash_context := HashingContext.new() setget private_set
var _stream_buffer := StreamPeerBuffer.new() setget private_set


func build_objects(p_relax_iterations: int=0) -> void:
	# Builds the voronoi objects in the current chunk grid view.
	# Loads a region of chunks from disk if it can find on save directory, 
	# else will generate new points and write to a file on disk.
	var voronoi_points: Array = []
	for i in column_count:
		for j in row_count:
			var map_pos := Vector2(pos_col + i, pos_row + j)
			var col := int(map_pos.x)
			var row := int(map_pos.y)
			# Checks existence in disk.
			var chunk_data: Dictionary = chunk_dir.load_chunk(col, row)
			if chunk_data.empty():
				var chunk_seed: int = rand_seed(_hash_2di(col, row))[1]
				var random_points: Array = _generate_white_noise(col, row, chunk_seed)
				chunk_data.points = PoolVector2Array(random_points)
				chunk_data.seed_state = [chunk_seed, _rng.state] # Chunk seed and current rng state when this chunk was generated.
				chunk_dir.save_chunk(col, row, chunk_data)
				voronoi_points.append_array(random_points)
			else:
				voronoi_points.append_array(chunk_data.points)
			chunk_data.site_indices = [] # Temporary site indices that is the indices for the sites of the generated region/diagram object (will not be saved).
			_chunk_map[map_pos] = chunk_data
	_voronoi_diagram = _make_diagram(voronoi_points, p_relax_iterations)
	_site_count = _voronoi_diagram.get_site_count()
	_chunks_by_site.resize(_site_count)
	_site_positions.resize(_site_count)
	for i in _site_count:
		var site_pos: Vector2 = _voronoi_diagram.site_get_position(i)
		_site_positions[i] = site_pos
		var map_pos: Vector2 = chunk_grid.global_to_map(_voronoi_diagram.site_get_position(i))
		_chunks_by_site[i] = map_pos
		_chunk_map[map_pos].site_indices.push_back(i)


func get_site_count() -> int:
	return _site_count


func get_chunk_grid_positions() -> Array:
	return _chunk_map.keys()


func set_column_count(p_col_count: int) -> void:
	if p_col_count < 1:
		push_error("Column count in this region needs to be greater than 0.")
	else:
		column_count = p_col_count


func set_row_count(p_row_count: int) -> void:
	if p_row_count < 1:
		push_error("Column count in this region needs to be greater than 0.")
	else:
		row_count = p_row_count


func set_gridview(p_col: int, p_row: int, p_col_count: int, p_row_count: int) -> void:
	# Sets up this region's "view rectangle" of the chunks in its grid. 
	if p_col_count < 1 || p_row_count < 1:
		push_error("Column or Row count in this region needs to be greater than 0.")
	else:
		pos_col = p_col
		pos_row = p_row
		column_count = p_col_count
		row_count = p_row_count


func get_global_gridview_rect() -> Rect2:
	# Returns the grid view converted to a global Rect2.
	var dimensions: Vector2 = chunk_grid.get_chunk_dimensions()
	return Rect2(chunk_grid.map_to_global(pos_col, pos_row), Vector2(column_count * dimensions.x, row_count * dimensions.y))


func get_chunk_by_site_idx(p_site_idx: int) -> Vector2:
	return _chunks_by_site[p_site_idx]


func get_seed_state_of_chunk(p_col: int, p_row: int) -> Array:
	# Returns an Array copy of this chunk's seed state after point generation.
	# Else, return an empty Array if the column and row doesn't exist in this region's chunk map.
	return _chunk_map.get(Vector2(p_col, p_row), {}).get('seed_state', []).duplicate()


func get_site_points_of_chunk(p_col: int, p_row: int) -> PoolVector2Array:
	# Returns a PoolVector2Array copy of the randomly generated points of this chunk before it was tesselated.
	# Else, return an empty PoolVector2Array if the column and row doesn't exist in this region's chunk map.
	return _chunk_map.get(Vector2(p_col, p_row), {}).get('site_positions', PoolVector2Array())


func get_site_indices_of_chunk(p_col: int, p_row: int) -> PoolIntArray:
	# Returns a casted PoolIntArray of the chunk's site indices of which map to this region's sites,
	# Else, return an empty PoolIntArray if the column and row doesn't exist in this region's chunk map.
	return PoolIntArray(_chunk_map.get(Vector2(p_col, p_row), {}).get('site_indices', []))


func site_get_global_pos(p_site_idx: int) -> Vector2:
	return _voronoi_diagram.site_get_position(p_site_idx)


func site_get_polygon(p_site_idx: int) -> ConvexPolygonShape2D:
	return _voronoi_diagram.site_get_polygon(p_site_idx)


func get_grid_pos() -> Vector2:
	return Vector2(pos_col, pos_row)


func get_global_pos() -> Vector2:
	return chunk_grid.map_to_global(pos_col, pos_row)


func set_chunk_grid(p_chunk_grid: ChunkGrid) -> void:
	chunk_grid = p_chunk_grid


func set_chunk_dir(p_chunk_dir: ChunkDirectory) -> void:
	chunk_dir = p_chunk_dir


func set_master_seed(p_master_seed: int) -> void:
	master_seed = p_master_seed


func set_gen_point_range(p_min_gen_chunk_points: int, p_max_gen_chunk_points: int) -> void:
	if p_max_gen_chunk_points < p_min_gen_chunk_points:
		push_error("Unable to set the maximum generated chunk points below the minimum.")
	max_gen_chunk_points = p_max_gen_chunk_points
	min_gen_chunk_points = p_min_gen_chunk_points


func set_min_gen_chunk_points(p_min_gen_chunk_points: int) -> void:
	if p_min_gen_chunk_points > max_gen_chunk_points:
		push_error("Unable to set the minimum generated chunkpoints points above the maximum.")
	else:
		min_gen_chunk_points = p_min_gen_chunk_points


func set_max_gen_chunk_points(p_max_gen_chunk_points: int) -> void:
	if p_max_gen_chunk_points < min_gen_chunk_points:
		push_error("Unable to set the maximum generated chunk points below the minimum.")
	else:
		max_gen_chunk_points = p_max_gen_chunk_points


func _make_diagram(p_points: Array, p_relax_iterations: int) -> Reference:
	# TODO REFACTOR Figure out a way so the diagram is dependent on an object that can be modified outside of this class.
	# Make sure to reload using load_chunks if any changes to chunk_map are made as the diagram is dependent on the contents of chunk_map.
	var voronoi := VoronoiGenerator.new()
	voronoi.set_boundaries(get_global_gridview_rect())
	voronoi.set_points(p_points)
	if p_relax_iterations:
		voronoi.relax_points(p_relax_iterations)
	return voronoi.generate_diagram()


func _generate_white_noise(p_col: int, p_row: int, p_seed: int) -> Array:
	# Deterministic random point generation using a temporary seed.
	_rng.seed = p_seed
	var num_points: int = _rng.randi_range(min_gen_chunk_points, max_gen_chunk_points)
	var chunk_region: Rect2 = chunk_grid.get_chunk_rect(p_col, p_row)
	var points: Array = []
	for i in num_points:
		var point := Vector2(
			chunk_region.size.x * _rng.randf() + chunk_region.position.x, 
			chunk_region.size.y * _rng.randf() + chunk_region.position.y
		)
		points.push_back(point)
	return points


func _hash_2di(p_col: int, p_row: int) -> int:
	# Hash algorithm using md5. 
	_stream_buffer.clear()
	_stream_buffer.put_64(p_col ^ master_seed)
	_stream_buffer.put_64(p_row ^ master_seed)
	# warning-ignore:return_value_discarded
	_hash_context.start(HashingContext.HASH_MD5)
	# warning-ignore:return_value_discarded
	_hash_context.update(_stream_buffer.data_array)
	return hash(_hash_context.finish().hex_encode())


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
