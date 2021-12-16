static func get_centroid_area(p_vertices: PoolVector2Array) -> Vector3:
	# Output Parameter: Vector3 represented as (Centroid.x, Centroid.y, Area).
	# Computes area of n-gon using the shoelace algorithm.
	# mathopenref.com/coordpolygonarea.html
	# Centroid of n-gon
	# http://blog.eppz.eu/cenroid-multiple-polygons/
	
	var num_of_points: int = p_vertices.size()
	var signed_area: float = 0.0
	var centroid := Vector2()
	for i in num_of_points - 1:
		var vert_a: Vector2 = p_vertices[i]
		var vert_b: Vector2 = p_vertices[i + 1]
		var tri_area: float = (vert_a.x * vert_b.y - vert_a.y * vert_b.x)
		signed_area += tri_area
		centroid += (vert_a + vert_b) * tri_area
	
	# Do last vertex separately to avoid performing an expensive
	# modulus operation in each iteration.
	var vert_a: Vector2 = p_vertices[num_of_points - 1]
	var vert_b: Vector2 = p_vertices[0]
	var tri_area: float = (vert_a.x * vert_b.y - vert_a.y * vert_b.x)
	signed_area += tri_area
	centroid += (vert_a + vert_b) * tri_area
	signed_area *= 0.5
	centroid /= (6.0 * signed_area)
	
	return Vector3(centroid.x, centroid.y, abs(signed_area))


static func get_signed_area(p_vertices: PoolVector2Array) -> float:
	var signed_area: float = 0.0
	if !p_vertices.empty():
		var num_of_points: int = p_vertices.size()
		for i in num_of_points - 1:
			var vert_a: Vector2 = p_vertices[i]
			var vert_b: Vector2 = p_vertices[i + 1]
			signed_area += (vert_a.x * vert_b.y - vert_a.y * vert_b.x)
		
		var vert_a: Vector2 = p_vertices[num_of_points - 1]
		var vert_b: Vector2 = p_vertices[0]
		signed_area += (vert_a.x * vert_b.y - vert_a.y * vert_b.x)
		signed_area *= 0.5
	
	return signed_area


static func get_tri_circumcenter(p_vert_a: Vector2, p_vert_b: Vector2, p_vert_c: Vector2) -> Vector2:
	# Get triangle circumcenter
	# Reference: https://www.geeksforgeeks.org/program-find-circumcenter-triangle-2/
	# Reference: https://math.stackexchange.com/questions/672721/given-position-vector-of-points-a-b-find-the-equation-of-perpendicular-bisecto
	var midpoint_ab: Vector2 = (p_vert_a + p_vert_b) * 0.5
	var midpoint_bc: Vector2 = (p_vert_b + p_vert_c) * 0.5
	var bisect_dir_ab := Vector2(p_vert_b.y - p_vert_a.y, p_vert_a.x - p_vert_b.x).normalized() # (y2 - y1, x1 - x2)
	var bisect_dir_bc := Vector2(p_vert_c.y - p_vert_b.y, p_vert_b.x - p_vert_c.x).normalized()
	var circumcenter: Vector2 = Geometry.line_intersects_line_2d(midpoint_ab, bisect_dir_ab, midpoint_bc, bisect_dir_bc)
	
	return circumcenter


static func vec_to_string(p_vector: Vector2, p_precision: int=6) -> String: 
	# Default floating 6 precision.
	var format_string: String = "%.*f"
	var string_x: String = format_string % [p_precision, p_vector.x]
	var string_y: String = format_string % [p_precision, p_vector.y]
	
	return "%s, %s" % [string_x, string_y]


static func get_poly_diameter(p_vertices: PoolVector2Array) -> Vector2:
	# Gets the longest diagonal in x distance and y distance scalar.
	var min_diagonal: Vector2 = p_vertices[0]
	var max_diagonal: Vector2 = p_vertices[p_vertices.size() - 1]
	for point in p_vertices:
		if point.x < min_diagonal.x:
			min_diagonal.x = point.x
		elif point.x > max_diagonal.x:
			max_diagonal.x = point.x
		if point.y < min_diagonal.y:
			min_diagonal.y = point.y
		elif point.y > max_diagonal.y:
			max_diagonal.y = point.y
	return max_diagonal - min_diagonal


static func filter_degenerate_points(p_points: PoolVector2Array, p_epsilon: float) -> PoolVector2Array:
	var num_of_points: int = p_points.size()
	var filtered_points := PoolVector2Array()
	
	var offset: int = 1
	var curr: int = 0
	var next: int = offset
	while offset < num_of_points + 1:
		var vert_a: Vector2 = p_points[curr]
		var vert_b: Vector2 = p_points[next]
		var distance: float = vert_a.distance_to(vert_b)
		distance = vert_a.distance_to(vert_b)
		if distance > p_epsilon:
			filtered_points.push_back(vert_a)
			curr = offset
		offset += 1
		next = offset % num_of_points
	return filtered_points


static func law_of_cos_angle(p_len_a: float, p_len_b: float, p_len_c: float) -> float:
	var denominator: float = 2 * p_len_a * p_len_b
	if denominator == 0.0:
		return 0.0
	return acos((p_len_a * p_len_a + p_len_b * p_len_b - p_len_c * p_len_c) / denominator)


static func find_extremes_y(p_polyline: PoolVector2Array) -> Vector2:
	var y_min: float = INF
	var y_max: float = -INF
	for point in p_polyline:
		if point.y < y_min:
			y_min = point.y
		if point.y > y_max:
			y_max = point.y
	return Vector2(y_min, y_max)
