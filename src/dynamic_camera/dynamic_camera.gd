class_name DynamicCamera
extends Camera2D


enum Modes {
	FREE,
	FOLLOW,
	# EXPAND,
}
# TODO: Different minimum/maximum zoom distances depending on node type.
# TODO: Camera UI Settings.
export(Vector2) var min_zoom = Vector2(0.1, 0.1) setget set_min_zoom
export(Vector2) var max_zoom = Vector2(1.0, 1.0) setget set_max_zoom
export(int) var zoom_steps = 10

var _mode: int = Modes.FREE setget private_set
var _zoom_step: float = 5.0 setget private_set
var _target: Node2D setget private_set
## DEBUG START
#var _previous_position := Vector2.ZERO
#var _move_camera: bool = false
## DEBUG END

func _ready() -> void:
	process_mode = Camera2D.CAMERA2D_PROCESS_IDLE
	# Convert zoom limits to logarithmic form.
	# Reference: https://www.gamedev.net/forums/topic/666225-equation-for-zooming/
	# Set default zoom value.
	zoom = get_stepped_zoom()
	_mode = Modes.FREE


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cam_zoom_in"):
		if _zoom_step > 0:
			decrement_zoom()
	if event.is_action_pressed("cam_zoom_out"):
		if _zoom_step < zoom_steps:
			increment_zoom()
	
#	# DEBUG START
#	# Enables the camera to be dragged with the mouse.
#	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
#		if event.is_pressed():
#			_previous_position = event.position
#			_move_camera = true
#		else:
#			_move_camera = false
#	elif event is InputEventMouseMotion && _move_camera:
#		position += (_previous_position - event.position)
#		_previous_position = event.position
#	# DEBUG END


func _physics_process(_delta: float) -> void:
	match _mode:
		Modes.FOLLOW:
			global_position = _target.global_position


func follow(p_target: Node2D) -> void:
	# Camera will track the target node.
	_target = p_target
	_mode = Modes.FOLLOW


func get_camera_screen_rect() -> Rect2:
	# Gets the camera's visible rectangle relative to its parent viewport. 
	var screen_center: Vector2 = get_camera_screen_center()
	var visible_size: Vector2 = get_viewport_rect().size * zoom
	return Rect2(
		screen_center.x - visible_size.x / 2.0,
		screen_center.y - visible_size.y / 2.0,
		visible_size.x,
		visible_size.y
	)


#func go_to(p_target: Node2D) -> void:
#	# Moves camera to target using interpolation.
#	if !is_processing():
#		pass


func increment_zoom() -> void:
	# Increments the zoom by a step. The camera moves "farther" out.
	_zoom_step += 1
	zoom = get_stepped_zoom()


func decrement_zoom() -> void:
	# Decrements the zoom by a step. The camera moves "closer" in.
	_zoom_step -= 1
	zoom = get_stepped_zoom()


func get_stepped_zoom() -> Vector2:
	# Returns current zoom value calculated from the current step.
	var log_zoom: Vector2 = get_log_stepped_zoom()
	return Vector2(exp(log_zoom.x), exp(log_zoom.y))


func get_log_min_zoom() -> Vector2:
	# Returns current zoom value in log form.
	return Vector2(log(min_zoom.x), log(min_zoom.y))


func get_log_max_zoom() -> Vector2:
	return Vector2(log(max_zoom.x), log(max_zoom.y))


func get_log_stepped_zoom() -> Vector2:
	# Returns current stepped zoom value in log form.
	return get_log_min_zoom().linear_interpolate(get_log_max_zoom(), _zoom_step / zoom_steps)


func set_min_zoom(p_min_zoom: Vector2) -> void:
	if p_min_zoom.x > max_zoom.x || p_min_zoom.y > max_zoom.y:
		push_error("Cannot set minimum zoom to be higher than maximum zoom.")
	else:
		min_zoom = p_min_zoom


func set_max_zoom(p_max_zoom: Vector2) -> void:
	if p_max_zoom.x < min_zoom.x || p_max_zoom.y < min_zoom.y:
		push_error("Cannot set maximum zoom to be lower than minimum zoom.")
	else:
		max_zoom = p_max_zoom


func private_set(_value=null) -> void:
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
