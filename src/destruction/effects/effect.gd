class_name Effect
extends Area2D

#signal body_overlap
signal shape_overlap

var _shape_overlaps: Array = [] setget private_set # Array of this area's shapes and their overlapping bodies in this frame.
# TODO: Damage calc and secondary effect properties.
# TODO: More types of classes for different type of effect shapes.
#var shape_ids := PoolIntArray() setget private_set # Meta information about all of the shapes and their respective id within an owner.


func _ready() -> void:
	yield($PolyCollisionShape2D, "shapes_applied")
	var shape_count: int = Physics2DServer.area_get_shape_count(get_rid())
	_shape_overlaps.resize(shape_count)
	for i in shape_count:
		_shape_overlaps[i] = {}


func setup(world_transform: Transform2D, monitoring_disabled: bool=false) -> void:
	global_transform = world_transform
	monitoring = monitoring_disabled
	$AnimationPlayer.play("init")


#func _on_Self_body_entered(p_body: PhysicsBody2D) -> void:
#	if p_body == null:
#		assert("ERROR: Colliding Body is a null instance!")
#	emit_signal("body_overlap", p_body, _type, global_transform)


func _on_Self_body_shape_entered(_p_body_rid: RID, p_body: PhysicsBody2D, _p_body_shape_idx: int, p_self_shape_idx: int) -> void:
	var body_instance_id: int = p_body.get_instance_id()
	if !_shape_is_overlapping_body(p_self_shape_idx, body_instance_id):
		_shape_overlaps[p_self_shape_idx][body_instance_id] = p_body
		var self_shape_owner: int = shape_find_owner(p_self_shape_idx)
		var self_shape_id: int = p_self_shape_idx - shape_owner_get_shape_index(self_shape_owner, 0)
		var self_shape: ConvexPolygonShape2D = shape_owner_get_shape(self_shape_owner, self_shape_id)
		var self_shape_global: Transform2D = global_transform * shape_owner_get_transform(self_shape_owner)
		call_deferred("_clear_shape_overlaps", p_self_shape_idx)

		emit_signal("shape_overlap", p_body, self_shape, self_shape_global)


func _shape_is_overlapping_body(p_self_shape_idx: int, p_body_instance_id: int) -> bool:
	return _shape_overlaps[p_self_shape_idx].has(p_body_instance_id)


func _clear_shape_overlaps(p_self_shape_idx: int) -> void:
	_shape_overlaps[p_self_shape_idx].clear()


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
#	emit_signal("exit")
	# Defer the queue_free call to ensure that this object is freed after any single deferred calls in this object.
	visible = false
	call_deferred("queue_free")


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
