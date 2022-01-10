class_name InfiniteVoronoi
extends Node2D
# Formula for calculating number of seeded points:
# seed_count = (N * S^3) / C where
# N = Size of the chunk. (Default: 32 meters or 320 pixels)
# S = unit of scale (Default: 10 pixels per 1 meter)
# C = average size of cavities in the cave. Determines number of points in the square chunk.

signal render_chunk

const Globals := preload("res://src/globals.gd")

export var main_seed: int = 0 setget set_main_seed, get_main_seed
export var use_random_main_seed: bool = false setget set_use_random_main_seed, get_use_random_main_seed
export var average_cell_area: float = 32.0 * 32.0 # 32x32m or 320x320 Pixels
export var relaxation_count: int = 0 # Number of Lloyd relaxation iterations when generating regions.
export var chunk_data_dir: String = "res://save"
export var random_walk: bool = false
export var percolation_threshold: float = 0.5
var _region := VoronoiRegion.new() setget private_set
var _chunk_rw := ChunkReadWrite.new() setget private_set
var _screen_rect := Rect2() setget private_set
var _render_rect := Rect2() setget private_set
var _rng := RandomNumberGenerator.new() setget private_set

onready var cell_grid: CellGrid = $CellGrid setget set_cell_grid, get_cell_grid
onready var seed_count := int(cell_grid.cell_size * Globals.UNIT_SCALE * Globals.UNIT_SCALE * Globals.UNIT_SCALE / average_cell_area) setget set_seed_count, get_seed_count


func _ready() -> void:
	set_physics_process(false)
	if use_random_main_seed:
		randomize()
		main_seed = randi()
		print("Using main seed: %d" % main_seed)
	_chunk_rw.open_new_dir(chunk_data_dir + '/' + str(main_seed))
	# warning-ignore:return_value_discarded
	_region.connect("chunk_loaded", self, "_on_VoronoiRegion_chunk_loaded")
	_region.set_points_per_chunk(seed_count, seed_count)
	_region.set_cell_grid(cell_grid)
	_region.set_chunk_rw(_chunk_rw)
	_region.set_main_seed(main_seed)


func _physics_process(_delta: float) -> void:
	set_physics_process(false)
	var region_grid_pos: Vector2 = cell_grid.global_to_map(_render_rect.position) - Vector2.ONE # Subtract one because top-left is inclusive.
	var region_grid_end: Vector2 = cell_grid.global_to_map(_render_rect.end)
	var region_grid_size: Vector2 = region_grid_end - region_grid_pos + Vector2.ONE
	_region.set_gridview(int(region_grid_pos.x), int(region_grid_pos.y), int(region_grid_size.x), int(region_grid_size.y))
	_region.generate_voronoi_objects(relaxation_count)


func update_screen_rect(p_screen_rect: Rect2, p_padding: float=0.0) -> void:
	# Sets the grid view rectangle.
	# Padding will modify the view rectangle size and area.
	set_physics_process(true)
	_screen_rect = p_screen_rect.grow(p_padding)
	_render_rect = cell_grid.get_region_intersected_with_rect(_screen_rect)


func get_render_rect() -> Rect2:
	return _render_rect


func set_main_seed(p_main_seed: int) -> void:
	main_seed = p_main_seed


func get_main_seed() -> int:
	return main_seed


func set_use_random_main_seed(p_use_random_main_seed: bool) -> void:
	use_random_main_seed = p_use_random_main_seed


func get_use_random_main_seed() -> bool:
	return use_random_main_seed


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


func _on_VoronoiRegion_chunk_loaded(p_voro_chunk: VoronoiChunk) -> void:
	var global_chunk_pos: Vector2 = to_global(cell_grid.map_to_world(p_voro_chunk.get_chunk_col(), p_voro_chunk.get_chunk_row()))
	if _render_rect.has_point(global_chunk_pos):
		emit_signal("render_chunk", global_chunk_pos, p_voro_chunk)


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
