tool
extends Polygon2D


const MAX_STACK_SIZE = 1024 # Max size before Godot reaches stack overflow.
export(float) var radius setget set_radius
export(float) var circle_imprecision setget set_imprecision
export(bool) var draw_circle setget set_circle
export(bool) var tesselate_curve setget set_curved
# Attach this script to a collision polygon 2D and add a Path2D as a child.
# Make a Path using curves and then check the
# Tesselate in the inspector of this Collision Polygon.
# Delete path afterwards and then clear the script when you are finished.


func _ready() -> void:
	if not Engine.editor_hint:
		print("WARNING: Tool Script Running in game.")
		print_stack()


func set_curved(p_value: bool) -> void:
	if p_value and $Path2D != null:
		self.draw_circle = false
		tesselate_curve = true
		var tesselate_curve = $Path2D.curve
		polygon = tesselate_curve.tessellate()
		return
	
	tesselate_curve = false
	polygon = PoolVector2Array([])


func set_circle(p_value: bool) -> void:
	if p_value:
		self.tesselate_curve = false
		draw_circle = true
		var aliased: PoolVector2Array = convert_circle_to_ring(radius, circle_imprecision)
		polygon = aliased
		return
	
	draw_circle = false
	polygon = PoolVector2Array([])


func set_radius(p_radius: float) -> void:
	radius = p_radius
	set_circle(draw_circle)


func set_imprecision(p_error: float) -> void:
	circle_imprecision = p_error
	set_circle(draw_circle)


# Reference: https://github.com/godotengine/godot/pull/14416
# Imprecision/Error represents impreciseness in pixels. So 0.25 would mean 1/4px size of Error. 
func convert_circle_to_ring(p_radius: float, p_error: float=0.25) -> PoolVector2Array:
	var points: PoolVector2Array = PoolVector2Array()
	if radius <= 0.0:
		self.draw_circle = false
	
	var num_of_points: float = ceil(PI / acos(1 - p_error / p_radius))
	num_of_points = clamp(num_of_points, 3, MAX_STACK_SIZE)
	
	
	for i in num_of_points:
		var theta: float = i * PI * 2.0 / num_of_points
		var point := Vector2(sin(theta), cos(theta))
		points.push_back(point * radius)
	
	return points
