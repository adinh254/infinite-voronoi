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
#var _applied_effect_transforms: Array = [] setget private_set # Array of size Effect.Types.MAX where each index contains a nested array of transformations local to this chunk.
onready var _poly_owners: Array = get_shape_owners() setget private_set # DynamiccellShape owners.
onready var _main_owner: int = _poly_owners[0] setget private_set # Main root index will be always be 0.


#func _ready() -> void:
#	_applied_effect_transforms.resize(Effect.Types.MAX)
#	for i in Effect.Types.MAX:
#		_applied_effect_transforms[i] = [] # Array of Transform2Ds.


#func store_effect_transform(p_effect_type: int, p_effect_transform: Transform2D) -> void:
#	_applied_effect_transforms[p_effect_type].push_back(p_effect_transform)


func build_poly_node_tree(p_walk: bool=true) -> void:
	for owner_id in _poly_owners:
		shape_owner_get_owner(owner_id).build_boolean_polygons_tree(p_walk)


func shape_owner_set_chunk_model(p_chunk_model: VoronoiChunk, p_owner: int=_main_owner) -> void:
	shape_owner_get_owner(p_owner).set_chunk_model(p_chunk_model)


func shape_owner_add_poly_node(p_poly_node: PolyNode2D, p_owner: int=_main_owner) -> void:
	# Add a polynode2d child to a root boolean poly node.
	shape_owner_get_owner(p_owner).add_poly_node(p_poly_node)


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
