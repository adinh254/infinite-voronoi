class_name DynamicChunkShape
extends PolyCollisionShape2D
# This node when added under a Physics2D object will become a shape owner that is responsible with Voronoi and CSG operations.

const Chunk := preload("res://src/procedural/chunk.gd")

enum CSGState {
	UNCHANGED,
	IS_CHANGING,
	CHANGED
}


var chunk_model := VoronoiChunk.new(Chunk.new()) setget set_chunk_model, get_chunk_model
onready var root: PolyNode2D = $Root
onready var clip := $Root/Clip # Outline node that is the parent of a OP_DIFF PolyNode2Ds.
onready var merge: PolyNode2D = $Root/Merge  # Outline node that is the parent of OP_UNION PolyNode2Ds.
var _state: int = CSGState.UNCHANGED setget private_set


func _ready() -> void:
	# warning-ignore:return_value_discarded
	self.connect("shapes_applied", self, "_on_Self_shapes_applied")


func set_chunk_model(p_voronoi_chunk: VoronoiChunk) -> void:
	chunk_model = p_voronoi_chunk


func get_chunk_model() -> VoronoiChunk:
	return chunk_model


func build_boolean_polygons_tree(p_walk: bool=true) -> void:
	# Build the boolean PolyNode2D tree from the currently set chunk model.
	var root_polygons: Array = chunk_model.get_walked_polygons() if p_walk else chunk_model.get_polygons()
	for polygon in root_polygons:
		# warning-ignore:return_value_discarded
		root.new_child(polygon)
	var clip_outlines: Array = chunk_model.get_clip_outlines()
	if !clip_outlines.empty():
		clip.make_from_outlines(clip_outlines)
	var merge_outlines: Array = chunk_model.get_merge_outlines()
	if !merge_outlines.empty():
		merge.make_from_outlines(merge_outlines)


func add_clip_child(p_poly_node: PolyNode2D) -> void:
	clip.add_child(p_poly_node)
	_state = CSGState.IS_CHANGING


func add_merge_child(p_poly_node: PolyNode2D) -> void:
	merge.add_child(p_poly_node)
	_state = CSGState.IS_CHANGING


func commit_outlines() -> void:
	match _state:
		CSGState.UNCHANGED:
			return
		CSGState.IS_CHANGING:
			yield(self, "shapes_applied")
			continue
		CSGState.IS_CHANGING, CSGState.CHANGED:
			chunk_model.set_clip_outlines(clip.get_outlines())
			chunk_model.set_merge_outlines(merge.get_outlines())
			chunk_model.commit_chunk()


func _on_Self_shapes_applied() -> void:
	_state = CSGState.CHANGED


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
