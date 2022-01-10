class_name ProceduralVoronoi
extends Node2D

const DynamicChunkBodyScene: PackedScene = preload("res://src/procedural/dynamic_chunk/dynamic_chunk_body.tscn") 

# TODO CONTINUED Figure out whether to keep track of active chunk in this class or in StaticDestructible.
export var random_walk: bool = false
#export var walk_color := Color(0.0, 1.0, 0.0)
#export var percolation_threshold: float = 0.5 setget set_percolation_threshold, get_percolation_threshold
export var camera_speed: float = 5.0

#var _shapes: Array = []
#var _rects: Array = []
var _rng := RandomNumberGenerator.new() setget private_set
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


#func _draw() -> void:
#	if random_walk:
#		for polygon in _shapes:
#			draw_colored_polygon(polygon.points, walk_color)
#	else:
#		for polygon in _shapes:
#			draw_colored_polygon(polygon.points, Color(randf(), randf(), randf()))
#	for rect in _rects:
#		draw_rect(rect, Color(0.0, 0.0, 1.0), false, 2.0)


func _on_VisibilityBounds_bounds_entered(p_padding: float) -> void:
	inf_voronoi.update_screen_rect(camera.get_camera_screen_rect(), p_padding)
	var dirty_rect: Rect2 = inf_voronoi.get_render_rect()
	visibility_bounds.enclose_rect(dirty_rect)


func _on_InfiniteVoronoi_render_chunk(p_global_pos: Vector2, p_voro_chunk: VoronoiChunk) -> void:
	var chunk_body: DynamicChunkBody = DynamicChunkBodyScene.instance()
	add_child(chunk_body)
	chunk_body.position = to_local(p_global_pos)
	chunk_body.shape_owner_set_chunk_model(p_voro_chunk)
	chunk_body.build_poly_node_tree()


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
