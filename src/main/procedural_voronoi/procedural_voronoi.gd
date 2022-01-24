class_name ProceduralVoronoi
extends Node2D

const DynamicChunkBodyScene: PackedScene = preload("res://src/procedural/dynamic_chunk/dynamic_chunk_body.tscn") 

export var random_walk: bool = true
export var camera_speed: float = 5.0

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


func _on_VisibilityBounds_bounds_entered(p_padding: float) -> void:
	inf_voronoi.update_screen_rect(camera.get_camera_screen_rect(), p_padding)
	var global_bounding_rect: Rect2 = inf_voronoi.get_global_grid_rect()
	visibility_bounds.update_global_bounding_rect(global_bounding_rect)


func _on_InfiniteVoronoi_render_chunk(p_global_pos: Vector2, p_voro_chunk: VoronoiChunk) -> void:
	var chunk_body: DynamicChunkBody = DynamicChunkBodyScene.instance()
	add_child(chunk_body)
	# warning-ignore:return_value_discarded
	visibility_bounds.connect("bounding_rect_updated", chunk_body, "_on_VisibilityBounds_bounding_rect_updated")
	chunk_body.position = to_local(p_global_pos)
	chunk_body.shape_owner_set_chunk_model(p_voro_chunk)
	chunk_body.build_poly_node_tree(random_walk)


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
