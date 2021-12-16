class_name VisibilityBounds
extends Node2D


signal bounds_entered

onready var left_bound: VisibilityNotifier2D = $Left
onready var top_bound: VisibilityNotifier2D = $Top
onready var right_bound: VisibilityNotifier2D = $Right
onready var bottom_bound: VisibilityNotifier2D = $Bottom


func enclose_rect(p_rect: Rect2) -> void:
	# Sets all of the VisibilityNotifier2D rects to enclose this Rect2 region.
	left_bound.global_position = p_rect.position
	top_bound.global_position = p_rect.position
	right_bound.global_position = Vector2(p_rect.end.x, p_rect.position.y)
	bottom_bound.global_position = Vector2(p_rect.position.x, p_rect.end.y)
	
	var grow_size := Vector2(p_rect.size.x - top_bound.rect.size.x, p_rect.size.y - left_bound.rect.size.y)
	left_bound.rect = left_bound.rect.grow_margin(MARGIN_BOTTOM, grow_size.y)
	top_bound.rect = top_bound.rect.grow_margin(MARGIN_RIGHT, grow_size.x)
	right_bound.rect = right_bound.rect.grow_margin(MARGIN_BOTTOM, grow_size.y)
	bottom_bound.rect = bottom_bound.rect.grow_margin(MARGIN_RIGHT, grow_size.x)


func get_enclosed_rect() -> Rect2:
	var rect_end := Vector2(bottom_bound.rect.size.x, right_bound.rect.size.y)
	return Rect2(left_bound.global_position, rect_end)


func resize_margin(p_margin_type: int, p_margin_size: float) -> void:
	# Resets notifier rectangles and settings to be the margin size.
	if p_margin_type & MARGIN_LEFT:
		left_bound.rect.size.x = p_margin_size
	if p_margin_type & MARGIN_TOP:
		top_bound.rect.size.y = p_margin_size
	if p_margin_type & MARGIN_RIGHT:
		right_bound.rect.size.x = p_margin_size
		right_bound.rect.position.y = p_margin_size
	if p_margin_type & MARGIN_BOTTOM:
		bottom_bound.rect.size.y = p_margin_size
		bottom_bound.rect.position.x = p_margin_size
	push_error("Unable to resize margin. %s is an invalid margin type!")


func get_margin_size(p_margin_type: int) -> float:
	if p_margin_type & MARGIN_LEFT:
		return left_bound.rect.size.x
	if p_margin_type & MARGIN_TOP:
		return top_bound.rect.size.y
	if p_margin_type & MARGIN_RIGHT:
		return right_bound.rect.size.x
	if p_margin_type & MARGIN_BOTTOM:
		return bottom_bound.rect.size.y
	push_warning("Unable to return margin size. %s is an invalid margin type!")
	return 0.0


func _on_Left_screen_entered():
	print("Left screen entered.")
	emit_signal("bounds_entered", 2.0 * left_bound.rect.size.x)


func _on_Left_screen_exited():
	print("Left screen Exited.")
	emit_signal("bounds_entered", 2.0 * left_bound.rect.size.x)


func _on_Top_screen_entered():
	print("Top screen entered.")
	emit_signal("bounds_entered", 2.0 * top_bound.rect.size.y)


func _on_Top_screen_exited():
	print("Top screen Exited.")
	emit_signal("bounds_entered", 2.0 * top_bound.rect.size.y)


func _on_Right_screen_entered():
	print("Right screen entered.")
	emit_signal("bounds_entered", right_bound.rect.size.x)


func _on_Right_screen_exited():
	print("Right screen Exited.")
	emit_signal("bounds_entered", 2.0 * right_bound.rect.size.x)


func _on_Bottom_screen_entered():
	print("Bottom screen entered.")
	emit_signal("bounds_entered", 2.0 * bottom_bound.rect.size.y)


func _on_Bottom_screen_exited():
	print("Bottom screen exited.")
	emit_signal("bounds_entered", bottom_bound.rect.size.y)


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
