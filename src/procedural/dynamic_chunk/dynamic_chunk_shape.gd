class_name DynamicChunkShape
extends PolyCollisionShape2D
# This node when added under a Physics2D object will become a shape owner that is responsible with Voronoi and CSG operations.

const Chunk := preload("res://src/procedural/chunk.gd")

enum Shapes {
	STATE_UNCHANGED,
	STATE_UPDATING,
	STATE_UPDATED
}

 # NOTE: The clip node always Needs to be the last child to perform difference operations last.
var chunk_model := VoronoiChunk.new(Chunk.new()) setget set_chunk_model, get_chunk_model
onready var root: PolyNode2D = $Root
onready var texture: Texture = root.texture setget set_texture, get_texture
onready var subjects: PolyNode2D = root.get_node("Subjects") # Subject shapes that need to be the first child for boolean operations.
onready var merge: PolyNode2D = root.get_node("Merge")  # Outline node that is the parent of OP_UNION PolyNode2Ds.
onready var clip: PolyNode2D = root.get_node("Clip") # Outline node that is the parent of a OP_DIFF PolyNode2Ds.
var _state: int = Shapes.STATE_UNCHANGED setget private_set # State to track the shapes_updated signal whenever a node is added.


func set_chunk_model(p_voronoi_chunk: VoronoiChunk) -> void:
	chunk_model = p_voronoi_chunk


func get_chunk_model() -> VoronoiChunk:
	return chunk_model


func set_texture(p_texture: Texture) -> void:
	root.texture = p_texture
	texture = root.texture


func get_texture() -> Texture:
	return texture


func build_boolean_polygons_tree(p_walk: bool=true) -> void:
	# Build the boolean PolyNode2D tree from the currently set chunk model.
	var subject_polygons: Array = chunk_model.get_walked_polygons() if p_walk else chunk_model.get_polygons()
	for polygon in subject_polygons:
		# warning-ignore:return_value_discarded
		subjects.new_child(polygon)
	var merge_outlines: Array = chunk_model.get_merge_outlines()
	if !merge_outlines.empty():
		merge.make_from_outlines(merge_outlines)
	var clip_outlines: Array = chunk_model.get_clip_outlines()
	if !clip_outlines.empty():
		clip.make_from_outlines(clip_outlines)


func add_clipper(p_clipper: ConvexPolygonShape2D, p_transform: Transform2D) -> void:
	var new_node: PolyNode2D = clip.new_child(p_clipper.points)
	new_node.transform = p_transform
	_update_shapes_state()


func add_merger(p_merger: ConvexPolygonShape2D, p_transform: Transform2D) -> void:
	var new_node: PolyNode2D = merge.new_child(p_merger.points)
	new_node.transform = p_transform
	_update_shapes_state()


func commit_outlines() -> void:
	match _state:
		Shapes.STATE_UNCHANGED:
			return
		Shapes.STATE_UPDATING:
			yield(self, "shapes_applied")
			continue
		Shapes.STATE_UPDATING, Shapes.STATE_UPDATED:
			chunk_model.set_clip_outlines(clip.get_outlines())
			chunk_model.set_merge_outlines(merge.get_outlines())
			chunk_model.commit_chunk()


func _update_shapes_state() -> void:
	_state = Shapes.STATE_UPDATING
	yield(self, "shapes_applied")
	_state = Shapes.STATE_UPDATED


#func set_custom_chunk(p_chunk_resource: Chunk) -> void:
#	__backer.resource = p_chunk_resource
#	# Add clip polygons to body.
#	var clip_outlines: Array = p_chunk_resource.get_clip_outlines()
#	clip
#	# TODO Feature: The Returned polynode may be where special
#	#               terrain properties would be implemented.
#	for outline in outlines:
#		var _poly: PolyNode2D = root.new_child(outline)
#		_poly.operation = PolyNode2D.OP_NONE


#func get_custom_chunk() -> Chunk:
#	return __backer.resource as Chunk


#func get_chunk_resource() -> Chunk:
#	return __backer.resource as Chunk


func private_set(_value=null) -> void:
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
