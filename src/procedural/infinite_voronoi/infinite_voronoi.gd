class_name InfiniteVoronoi
extends Node2D
# Formula for calculating number of seeded points:
# seed_count = (N * S^3) / C where
# N = Size of the chunk. (Default: 32 meters or 320 pixels)
# S = unit of scale (Default: 10 pixels per 1 meter)
# C = average size of cavities in the cave. Determines number of points in the square chunk.

signal render_chunk

const Globals := preload("res://src/globals.gd")

export var chunk_data_dir: String = "res://save"
export var use_random_main_seed: bool = false
export var main_seed: int = 0 setget set_main_seed, get_main_seed
export var average_cell_area: float = 32.0 * 32.0 setget set_average_cell_area, get_average_cell_area # 32x32m or 320x320 Pixels
export var relaxation_count: int = 0 setget set_relaxation_count, get_relaxation_count # Number of Lloyd relaxation iterations when generating regions.
export var percolation_threshold: float = 0.5 setget set_percolation_threshold, get_percolation_threshold
export var region_buffer_count: int = 1 setget set_region_buffer_count, get_region_buffer_count # Set the number of regions to use
var _chunk_rw := ChunkReadWrite.new() setget private_set
var _screen_rect := Rect2() setget private_set
var _global_rect := Rect2() setget private_set
var _regions: Array = [] setget private_set # Array for rotating region caches.

onready var cell_grid: CellGrid = $CellGrid setget set_cell_grid, get_cell_grid
onready var seed_count := int(cell_grid.cell_size * Globals.UNIT_SCALE * Globals.UNIT_SCALE * Globals.UNIT_SCALE / average_cell_area) setget set_seed_count, get_seed_count


func _ready() -> void:
	set_physics_process(false)
	if use_random_main_seed:
		randomize()
		main_seed = randi()
		print("Using main seed: %d" % main_seed)
	_chunk_rw.open_new_dir(chunk_data_dir + '/' + str(main_seed))
	for i in region_buffer_count:
		var region := VoronoiRegion.new()
		# warning-ignore:return_value_discarded
		region.connect("chunk_loaded", self, "_on_VoronoiRegion_chunk_loaded")
		region.set_points_per_chunk(seed_count, seed_count)
		region.set_cell_grid(cell_grid)
		region.set_chunk_rw(_chunk_rw)
		region.set_main_seed(main_seed)
		_regions.push_back(region)


func _physics_process(_delta: float) -> void:
	set_physics_process(false)
	var region_grid_pos: Vector2 = cell_grid.global_to_map(_global_rect.position) - Vector2.ONE # Subtract one because top-left is inclusive.
	var region_grid_end: Vector2 = cell_grid.global_to_map(_global_rect.end)
	var region_grid_size: Vector2 = region_grid_end - region_grid_pos + Vector2.ONE
	var region: VoronoiRegion = _rotate_regions()
	region.resize(int(region_grid_pos.x), int(region_grid_pos.y), int(region_grid_size.x), int(region_grid_size.y))
	region.generate_voronoi_objects(relaxation_count)


func update_screen_rect(p_screen_rect: Rect2, p_padding: float=0.0) -> void:
	# Sets the grid view rectangle.
	# Padding will modify the view rectangle size and area.
	set_physics_process(true)
	_screen_rect = p_screen_rect.grow(p_padding)
	_global_rect = cell_grid.get_region_intersected_with_rect(_screen_rect)


func get_global_grid_rect() -> Rect2:
	return _global_rect


func set_main_seed(p_main_seed: int) -> void:
	main_seed = p_main_seed


func get_main_seed() -> int:
	return main_seed


func set_average_cell_area(p_average_cell_area) -> void:
	if p_average_cell_area < 0.0:
		push_error("Unable to set average cell area. Cell area must be greater than 0.0.")
		return
	average_cell_area = p_average_cell_area


func get_average_cell_area() -> float:
	return average_cell_area


func set_relaxation_count(p_relaxation_count: int) -> void:
	if p_relaxation_count < 0:
		push_error("Unable to set Lloyd relaxation count. Number of relaxation must be at least 0.")
		return
	relaxation_count = p_relaxation_count


func get_relaxation_count() -> int:
	return relaxation_count


func set_percolation_threshold(p_percolation_threshold: float) -> void:
	if p_percolation_threshold < 0.0 || p_percolation_threshold > 1.0:
		push_error("Unable to set percolation threshold. The percolation threshold must be a unit value between 0 and 1.")
		return
	percolation_threshold = p_percolation_threshold


func get_percolation_threshold() -> float:
	return percolation_threshold


func set_region_buffer_count(p_region_buffer_count: int) -> void:
	if p_region_buffer_count < 1:
		push_error("Unable to set the number of region buffers. At least one region must be used for caching.")
		return
	region_buffer_count = p_region_buffer_count


func get_region_buffer_count() -> int:
	return region_buffer_count


func set_cell_grid(p_cell_grid: CellGrid) -> void:
	cell_grid = p_cell_grid


func get_cell_grid() -> CellGrid:
	return cell_grid


func set_seed_count(p_seed_count) -> void:
	if p_seed_count <= 0:
		push_error("Seed Count must be greater than zero!")
	else:
		seed_count = p_seed_count


func get_seed_count() -> int:
	return seed_count


func _rotate_regions() -> VoronoiRegion:
	if _regions.size() < 2:
		return _regions[0]
	_regions.push_back(_regions[0])
	return _regions.pop_front()


func _on_VoronoiRegion_chunk_loaded(p_voro_chunk: VoronoiChunk) -> void:
	var global_chunk_pos: Vector2 = to_global(cell_grid.map_to_world(p_voro_chunk.get_chunk_col(), p_voro_chunk.get_chunk_row()))
	if _global_rect.has_point(global_chunk_pos):
		emit_signal("render_chunk", global_chunk_pos, p_voro_chunk)


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
