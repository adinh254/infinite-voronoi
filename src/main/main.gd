extends Node2D


const Effect := preload("res://src/destruction/effects/effect.tscn")


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_LEFT:
				if event.pressed:
					print("============================================EXPLODE TEST============================================")
					var location: Vector2 = get_global_mouse_position()
					var mouse_transform := Transform2D()
					mouse_transform.origin = location
					_on_Projectile_detonate(mouse_transform)
					print("at Position %s" % location)


func _on_Projectile_detonate(p_transform: Transform2D) -> void:
	var effect := Effect.instance()
	add_child(effect)
	# warning-ignore:return_value_discarded
	effect.connect("shape_overlap", self, "_on_Effect_shape_overlap")
	effect.setup(p_transform)


func _on_Effect_shape_overlap(p_body: DynamicChunkBody, effect_shape: ConvexPolygonShape2D, effect_shape_global: Transform2D) -> void:
	p_body.clip_colliders(effect_shape, p_body.global_transform.affine_inverse() * effect_shape_global)
