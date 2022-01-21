class_name VoronoiRegion
extends Reference

signal chunk_loaded

const Chunk := preload("res://src/procedural/chunk.gd")

var pos_col: int = 0
var pos_row: int = 0
var cell_grid := CellGrid.new() setget set_cell_grid
var chunk_rw := ChunkReadWrite.new() setget set_chunk_rw # Save/Load Directory
var main_seed: int = 0 setget set_main_seed
var min_points_per_chunk: int = 48 setget set_min_points_per_chunk
var max_points_per_chunk: int = 48  setget set_max_points_per_chunk
var _voronoi := VoronoiGenerator.new() setget private_set
var _cell_to_world := Transform2D() setget private_set
var _world_transform := Transform2D() setget private_set # world transform of the position cell.
var _rng := RandomNumberGenerator.new() setget private_set
var _hasher := RandomHasher2D.new() setget private_set
var _chunk_map := VariantMap.new() setget private_set


func generate_voronoi_objects(p_relax_iterations: int=0) -> void:
	# Builds the voronoi objects in the current chunk grid view.
	# Loads a region of chunks from disk if it can find on save directory,
	# else will generate new points and write to a file on disk.
	_cell_to_world = cell_grid.get_cell_world_transform()
	_world_transform = Transform2D.IDENTITY.translated(cell_grid.map_to_world(pos_col, pos_row))
	var cell_dimensions: Vector2 = _cell_to_world.get_scale()
	var voronoi_points := PoolVector2Array()
	var region_col_count: int = _chunk_map.get_width()
	var region_row_count: int = _chunk_map.get_height()
	for i in region_col_count:
		for j in region_row_count:
			var cell_col: int = pos_col + i
			var cell_row: int = pos_row + j

			print("Processing chunk %d_%d." % [cell_col, cell_row])

			var chunk := Chunk.new()
			if !chunk_rw.chunk_exists(cell_col, cell_row):

				print("Generating chunk %d_%d." % [cell_col, cell_row]) # DEBUG

				chunk = _generate_chunk_from(cell_col, cell_row)
				chunk_rw.save_chunk(chunk)
			else:
				# DEBUG START
				if chunk_rw.is_chunk_cached(cell_col, cell_row):
					print("Using cached chunk %d_%d." % [cell_col, cell_row])
				else:
					print("Loaded chunk %d_%d from disk." % [cell_col, cell_row])
				# DEBUG END
				chunk = chunk_rw.load_chunk(cell_col, cell_row)
			var voro_chunk := VoronoiChunk.new(chunk)
			voro_chunk.set_chunk_rw(chunk_rw)
			_chunk_map.set_element(i, j, voro_chunk)
			var region_world_transform := Transform2D.IDENTITY.translated(Vector2(cell_dimensions.x * i, cell_dimensions.y * j)) # Transformation of the cell within this region.
			voronoi_points.append_array(region_world_transform.xform(chunk.points))
	var diagram: Reference = _make_diagram(voronoi_points, p_relax_iterations)
	var site_count: int = diagram.get_site_count()
	for i in site_count:
		var region_cell: Vector2 = cell_grid.global_to_map(diagram.site_get_position(i))
		var voro_chunk: VoronoiChunk = _chunk_map.get_cell(region_cell)
		var region_to_chunk := Transform2D.IDENTITY.translated(
			Vector2(cell_dimensions.x * region_cell.x, cell_dimensions.y * region_cell.y)
		).affine_inverse()
		voro_chunk.polygons.push_back(region_to_chunk.xform(diagram.site_get_cell(i)))
	for i in region_col_count:
		for j in region_row_count:
			emit_signal("chunk_loaded", _chunk_map.get_element(i, j))


func set_column_count(p_col_count: int) -> void:
	if p_col_count < 1:
		push_error("Column count in this region needs to be greater than 0.")
	else:
		_chunk_map.resize(p_col_count, _chunk_map.get_height())


func get_column_count() -> int:
	return _chunk_map.get_width()


func set_row_count(p_row_count: int) -> void:
	if p_row_count < 1:
		push_error("Column count in this region needs to be greater than 0.")
	else:
		_chunk_map.resize(_chunk_map.get_width(), p_row_count)


func get_row_count() -> int:
	return _chunk_map.get_height()


func resize(p_col: int, p_row: int, p_col_count: int, p_row_count: int) -> void:
	# Sets up this region's "view rectangle" of the chunks in its grid.
	if p_col_count < 1 || p_row_count < 1:
		push_error("Column or Row count in this region needs to be greater than 0.")
	else:
		pos_col = p_col
		pos_row = p_row
		_chunk_map.resize(p_col_count, p_row_count)


func get_rect() -> Rect2:
	# Returns the grid view relative to the region.
	return Rect2(Vector2.ZERO, _cell_to_world.xform(_chunk_map.get_size()))


func get_world_rect() -> Rect2:
	# Returns the grid view converted to a world Rect2.
	return Rect2(_world_transform.get_origin(), _cell_to_world.basis_xform(_chunk_map.get_size()))


func get_pos_cell() -> Vector2:
	return Vector2(pos_col, pos_row)


func get_world_pos() -> Vector2:
	return cell_grid.map_to_world(pos_col, pos_row)


func set_cell_grid(p_cell_grid: CellGrid) -> void:
	cell_grid = p_cell_grid


func set_chunk_rw(p_chunk_rw: ChunkReadWrite) -> void:
	chunk_rw = p_chunk_rw


func set_main_seed(p_main_seed: int) -> void:
	main_seed = p_main_seed


func set_points_per_chunk(p_min_points_per_chunk: int, p_max_points_per_chunk: int) -> void:
	if p_max_points_per_chunk < p_min_points_per_chunk:
		push_error("Unable to set the maximum generated chunk points below the minimum.")
	max_points_per_chunk = p_max_points_per_chunk
	min_points_per_chunk = p_min_points_per_chunk


func set_min_points_per_chunk(p_min_points_per_chunk: int) -> void:
	if p_min_points_per_chunk > max_points_per_chunk:
		push_error("Unable to set the minimum generated chunkpoints points above the maximum.")
	else:
		min_points_per_chunk = p_min_points_per_chunk


func set_max_points_per_chunk(p_max_points_per_chunk: int) -> void:
	if p_max_points_per_chunk < min_points_per_chunk:
		push_error("Unable to set the maximum generated chunk points below the minimum.")
	else:
		max_points_per_chunk = p_max_points_per_chunk


func _make_diagram(p_points: PoolVector2Array, p_relax_iterations: int) -> Reference:
	_voronoi.set_points(p_points)
	if p_relax_iterations:
		_voronoi.relax_points(p_relax_iterations)
	return _voronoi.generate_diagram()


func _generate_chunk_from(p_col: int, p_row: int) -> Chunk:
	# Generate chunk resource to for the VoronoiChunk model.
	var new_chunk := Chunk.new()
	_hasher.hash_seed = main_seed
	var hashed_seed: int = rand_seed(_hasher.hash_2di(p_col, p_row))[1]
	var points: PoolVector2Array = _cell_to_world.xform(_generate_white_noise(hashed_seed)) # Scale the normal generated point coordinates to cell size.

	# Set Values to be saved on disks.
	new_chunk.col = p_col
	new_chunk.row = p_row
	new_chunk.hashed_seed = hashed_seed
	new_chunk.initial_state = _rng.state
	new_chunk.points = points
	return new_chunk


func _generate_white_noise(p_seed: int) -> PoolVector2Array:
	# Deterministic random point generation using a temporary seed.
	# Point coordinates are returned normalized.
	_rng.seed = p_seed
	var point_count: int = _rng.randi_range(min_points_per_chunk, max_points_per_chunk)
	var points := PoolVector2Array()
	points.resize(point_count)
	for i in point_count:
		points[i] = Vector2(_rng.randf(), _rng.randf())
	return points


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
