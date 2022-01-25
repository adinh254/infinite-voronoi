class_name DynamicChunkBody
extends StaticBody2D

# Shapes will perform boolean operations to each other when they are under a root node.
# Boolean operations are only done between shapes within the same depth and one above (the parent).
# Will delete itself if the grid this chunk belongs to is not within the view rectangle.
#signal freed

const Globals := preload("res://src/globals.gd")

export var cell_size: float = 96.0 setget set_cell_size, get_cell_size
var _cell_dims := Vector2(cell_size * Globals.UNIT_SCALE, cell_size * Globals.UNIT_SCALE) setget private_set
var _cell_rect := Rect2(Vector2.ZERO, _cell_dims) setget private_set # Local cell rectangle relative to this body.
onready var _poly_owners: Array = get_shape_owners() setget private_set # DynamiccellShape owners.
onready var _main_owner: int = _poly_owners[0] setget private_set # DynamicChunkShape shape owner id.


func build_poly_node_tree(p_walk: bool=true) -> void:
	for owner_id in _poly_owners:
		shape_owner_get_owner(owner_id).build_boolean_polygons_tree(p_walk)


func shape_owner_set_chunk_model(p_chunk_model: VoronoiChunk, p_owner: int=_main_owner) -> void:
	shape_owner_get_owner(p_owner).set_chunk_model(p_chunk_model)


func shape_owner_set_texture(p_texture: Texture, p_owner: int=_main_owner) -> void:
	shape_owner_get_owner(p_owner).set_texture(p_texture)


func clip_colliders(p_clipper: ConvexPolygonShape2D, p_transform: Transform2D, p_owner: int =_main_owner) -> void:
	var clip_node := PolyNode2D.new()
	clip_node.points = p_clipper.points
	clip_node.transform = p_transform
	shape_owner_get_owner(p_owner).add_clip_child(clip_node)


func merge_colliders(p_merger: ConvexPolygonShape2D, p_transform: Transform2D, p_owner: int=_main_owner) -> void:
	var merge_node := PolyNode2D.new()
	merge_node.points = p_merger.points
	merge_node.transform = p_transform
	shape_owner_get_owner(p_owner).add_merge_child(merge_node)


func set_cell_size(p_cell_size: float) -> void:
	cell_size = p_cell_size
	_cell_dims = Vector2(p_cell_size * Globals.UNIT_SCALE, p_cell_size * Globals.UNIT_SCALE)


func _on_VisibilityBounds_bounding_rect_updated(p_global_rect: Rect2) -> void:
	# This will call queue_free and commit the chunk before it's completely freed.
	if !global_transform.xform(_cell_rect).intersects(p_global_rect):
		for owner_id in _poly_owners:
			var chunk_shape: DynamicChunkShape = shape_owner_get_owner(owner_id)
			var commit: GDScriptFunctionState = chunk_shape.commit_outlines()
			if commit is GDScriptFunctionState:
				yield(commit, "completed")
		queue_free()


func get_cell_size() -> float:
	return cell_size


func private_set(_value=null) -> void:
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
