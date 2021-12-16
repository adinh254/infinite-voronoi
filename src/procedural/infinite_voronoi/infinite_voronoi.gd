class_name InfiniteVoronoi
extends Node2D
# Formula for calculating number of seeded points:
# seed_count = (N * S^3) / C where
# N = Size of the chunk. (Default: 32 meters or 320 pixels)
# S = unit of scale (Default: 10 pixels per 1 meter)
# C = average size of cavities in the cave. Determines number of points in the square chunk.

signal region_built

const Globals := preload("res://src/globals.gd")

export var master_seed: int = 0 setget set_master_seed, get_master_seed
export var use_random_master_seed: bool = false setget set_use_random_master_seed, get_use_random_master_seed
export var average_cell_area: float = 32.0 * 32.0 # 32x32m or 320x320 Pixels
export var relaxation_count: int = 0 # Number of Lloyd relaxation iterations when generating regions.
export var save_path: String = "res://save"
var _chunk_dir := ChunkDirectory.new()
var _screen_rect := Rect2() setget private_set

onready var chunk_grid := $ChunkGrid
onready var seed_count := int(chunk_grid.chunk_size * Globals.UNIT_SCALE * Globals.UNIT_SCALE * Globals.UNIT_SCALE / average_cell_area)

func _ready() -> void:
	set_physics_process(false)
	if use_random_master_seed:
		randomize()
		master_seed = randi()
	_chunk_dir.open_new(save_path + '/' + str(master_seed))


func _physics_process(_delta) -> void:
	set_physics_process(false)
	var render_rect: Rect2 = chunk_grid.get_region_intersected_with_rect(_screen_rect)
	var region_grid_pos: Vector2 = chunk_grid.global_to_map(render_rect.position) - Vector2.ONE # Subtract one because top-left is inclusive.
	var region_grid_end: Vector2 = chunk_grid.global_to_map(render_rect.end)
	var region_grid_size: Vector2 = region_grid_end - region_grid_pos + Vector2.ONE
	var region: VoronoiRegion = _build_new_region(region_grid_pos, region_grid_size)
	emit_signal('region_built', region, render_rect)


func update_screen_rect(p_screen_rect: Rect2, p_padding: float=0.0) -> void:
	# Sets the grid view rectangle.
	# Padding will modify the view rectangle size and area.
	set_physics_process(true)
	_screen_rect = p_screen_rect.grow(p_padding)


func set_master_seed(p_master_seed: int) -> void:
	master_seed = p_master_seed

func get_master_seed() -> int:
	return master_seed


func set_use_random_master_seed(p_use_random_master_seed: bool) -> void:
	use_random_master_seed = p_use_random_master_seed


func get_use_random_master_seed() -> bool:
	return use_random_master_seed


func _build_new_region(p_grid_pos: Vector2, p_region_size: Vector2) -> VoronoiRegion:
	var region := VoronoiRegion.new()
	region.set_gridview(int(p_grid_pos.x), int(p_grid_pos.y), int(p_region_size.x), int(p_region_size.y))
	region.set_gen_point_range(seed_count, seed_count)
	region.set_chunk_grid(chunk_grid)
	region.set_chunk_dir(_chunk_dir)
	region.set_master_seed(master_seed)
	region.build_objects(relaxation_count)
	return region


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
