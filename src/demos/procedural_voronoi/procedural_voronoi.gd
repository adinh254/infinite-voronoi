class_name ProceduralVoronoi
extends Node2D

# TODO CONTINUED Figure out whether to keep track of active chunk in this class or in StaticDestructible.
export var random_walk: bool = false
export var walk_color := Color(0.0, 1.0, 0.0)
export var percolation_threshold: float = 0.5 setget set_percolation_threshold, get_percolation_threshold
export var camera_speed: float = 5.0

var _shapes: Array = []
var _rects: Array = []
var _rng := RandomNumberGenerator.new()
onready var inf_voronoi: InfiniteVoronoi = $InfiniteVoronoi
onready var visibility_bounds: VisibilityBounds = $VisibilityBounds
onready var camera: DynamicCamera = $DynamicCamera
onready var center: Position2D = $Position2D


func _ready():
	camera.follow(center)
	inf_voronoi.update_screen_rect(camera.get_camera_screen_rect())


func _physics_process(_delta: float) -> void:
	var speed_multiplier: float = 1.0
	if Input.is_action_pressed("cam_pan_boost"):
		speed_multiplier *= 2
	if Input.is_action_pressed("ui_up"):
		center.position.y -= camera_speed * speed_multiplier
	if Input.is_action_pressed("ui_down"):
		center.position.y += camera_speed * speed_multiplier
	if Input.is_action_pressed("ui_left"):
		center.position.x -= camera_speed * speed_multiplier
	if Input.is_action_pressed("ui_right"):
		center.position.x += camera_speed * speed_multiplier


func _draw() -> void:
	if random_walk:
		for polygon in _shapes:
			draw_colored_polygon(polygon.points, walk_color)
	else:
		for polygon in _shapes:
			draw_colored_polygon(polygon.points, Color(randf(), randf(), randf()))
	for rect in _rects:
		draw_rect(rect, Color(0.0, 0.0, 1.0), false, 2.0)


func set_percolation_threshold(p_threshold: float) -> void:
	if p_threshold < 0.0 || p_threshold > 1.0:
		push_error("Threshold must be between 0 and 1.")
		print_stack()
	else:
		percolation_threshold = p_threshold


func get_percolation_threshold() -> float:
	return percolation_threshold


func _on_VisibilityBounds_bounds_entered(p_padding: float) -> void:
	inf_voronoi.update_screen_rect(camera.get_camera_screen_rect(), p_padding)


func _on_InfiniteVoronoi_region_built(p_region: VoronoiRegion, p_culling_rect: Rect2) -> void:
	_shapes.clear()
	_rects.clear()
	visibility_bounds.enclose_rect(p_culling_rect)
	var chunk_grid: ChunkGrid = p_region.chunk_grid
	var grid_positions: Array = p_region.get_chunk_grid_positions()
	for grid_pos in grid_positions:
		_rects.push_back(chunk_grid.get_chunk_rect(int(grid_pos.x), int(grid_pos.y)))
	if random_walk:
		for grid_pos in grid_positions:
			var col := int(grid_pos.x)
			var row := int(grid_pos.y)
			var seed_state: Array = p_region.get_seed_state_of_chunk(col, row)
			var site_indices: PoolIntArray = p_region.get_site_indices_of_chunk(col, row)
			var site_count: int = site_indices.size()
			var walked: Array = _rand_walk(site_count, seed_state[0], seed_state[1])
			for i in site_count:
				if walked[i] && p_culling_rect.has_point(p_region.site_get_global_pos(site_indices[i])):
					_shapes.push_back(p_region.site_get_polygon(site_indices[i]))
	else:
		var site_count: int = p_region.get_site_count()
		for i in site_count:
			_shapes.push_back(p_region.site_get_polygon(i))
	update()


func _rand_walk(p_count: int, p_seed: int, p_state: int) -> Array:
	_rng.seed = p_seed
	_rng.state = p_state
	var results: Array = []
	for i in p_count:
		results.push_back(_rng.randf() < percolation_threshold)
	return results
