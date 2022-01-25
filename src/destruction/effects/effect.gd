class_name Effect
extends Area2D

#signal body_overlap
signal shape_overlap

# TODO: Damage calc and secondary effect properties.
# TODO: More types of classes for different type of effect shapes.
#var shape_ids := PoolIntArray() setget private_set # Meta information about all of the shapes and their respective id within an owner.


#func _ready() -> void:
#	var total_shape_count: int = Physics2DServer.area_get_shape_count(get_rid())
#	shape_ids.resize(total_shape_count)
#	var shape_owners: Array = get_shape_owners()
#	for shape_owner in shape_owners:
#		var owner_shape_count: int = shape_owner_get_shape_count(shape_owner)
#		for i in owner_shape_count:
#			var shape_idx: int = shape_owner_get_shape_index(shape_owner, i)
#			shape_ids[shape_idx] = i


func setup(world_transform: Transform2D, monitoring_disabled: bool=false) -> void:
	global_transform = world_transform
	monitoring = monitoring_disabled
	$AnimationPlayer.play("init")


#func _on_Self_body_entered(p_body: PhysicsBody2D) -> void:
#	if p_body == null:
#		assert("ERROR: Colliding Body is a null instance!")
#	emit_signal("body_overlap", p_body, _type, global_transform)


func _on_Self_body_shape_entered(_p_body_rid: RID, p_body: PhysicsBody2D, p_body_shape_idx: int, p_self_shape_idx: int) -> void:
	if p_body != null:
		var self_shape_owner: int = shape_find_owner(p_self_shape_idx)
		var self_shape_id: int = p_self_shape_idx - shape_owner_get_shape_index(self_shape_owner, 0)
		var self_shape: ConvexPolygonShape2D = shape_owner_get_shape(self_shape_owner, self_shape_id)
		var self_shape_global: Transform2D = global_transform * shape_owner_get_transform(self_shape_owner)
		
		emit_signal("shape_overlap", p_body, p_body_shape_idx, self_shape, self_shape_global)
	else:
		assert("ERROR: Colliding Body is a null instance!")


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
#	emit_signal("exit")
	queue_free()


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
