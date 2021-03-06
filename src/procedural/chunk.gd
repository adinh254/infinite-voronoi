# class_name Chunk # Use explicit loading because of Godot's finicky custom Resource system.
extends Resource

# Properties here will be saved on disk.
# warning-ignore:unused_class_variable
export var col: int = 0
# warning-ignore:unused_class_variable
export var row: int = 0
# warning-ignore:unused_class_variable
export var hashed_seed: int = 0
# warning-ignore:unused_class_variable
export var initial_state: int = 0 # This chunk's initial rng state when it was generated.
# warning-ignore:unused_class_variable
export var points := PoolVector2Array()
export var clip_outlines: Array = [] setget set_clip_outlines, get_clip_outlines
export var merge_outlines: Array = [] setget set_merge_outlines, get_merge_outlines


func set_clip_outlines(p_clip_outlines: Array) -> void:
	if !_is_outlines(p_clip_outlines):
			push_error("Unable to set clipping outlines. At least one outline is not of type PoolVector2Array.")
			return
	clip_outlines = p_clip_outlines


func get_clip_outlines() -> Array:
	return clip_outlines


func set_merge_outlines(p_merge_outlines: Array) -> void:
	if !_is_outlines(p_merge_outlines):
			push_error("Unable to set merge outlines. At least one outline is not of type PoolVector2Array.")
			return
	merge_outlines = p_merge_outlines


func get_merge_outlines() -> Array:
	return merge_outlines


func _is_outlines(p_outlines: Array) -> bool:
	for outline in p_outlines:
		if !(outline is PoolVector2Array):
			return false
	return true
