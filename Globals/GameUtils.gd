extends Node



func get_random_coords_outside_camera_bounnds(camera: Camera2D, x_offset: float,y_padding: float = 50, x_padding: float = 50) -> Vector2:
	return get_random_coords_outside_camera_bounds(camera, x_offset, y_padding, x_padding)


func get_random_coords_outside_camera_bounds(camera: Camera2D, x_offset: float, y_padding: float = 50, x_padding: float = 50) -> Vector2:
	var bounds := get_camera_bounds(camera)
	var min_y = bounds.position.y + y_padding
	var max_y = bounds.position.y + bounds.size.y - y_padding
	if min_y > max_y:
		var mid_y = bounds.position.y + bounds.size.y * 0.5
		min_y = mid_y
		max_y = mid_y

	var random_x = bounds.position.x + bounds.size.x + x_offset + x_padding
	var random_y = randf_range(min_y, max_y)
	return Vector2(random_x, random_y)
	
func get_random_coords_in_camera_bounds(camera: Camera2D, y_padding: float = 100) -> Vector2:
	var bounds := get_camera_bounds(camera)
	var min_y = bounds.position.y + y_padding
	var max_y = bounds.position.y + bounds.size.y - y_padding
	if min_y > max_y:
		var mid_y = bounds.position.y + bounds.size.y * 0.5
		min_y = mid_y
		max_y = mid_y

	var random_x = randf_range(bounds.position.x, bounds.position.x + bounds.size.x)
	var random_y = randf_range(min_y, max_y)
	return Vector2(random_x, random_y)


func spawn_scene(position: Vector2, parent: Node, scene: PackedScene):
	var instance = scene.instantiate()
	instance.position = position
	parent.add_child(instance)
	return instance
	

	
func get_camera_bounds(camera: Camera2D) -> Rect2:
	# Convert visible viewport pixels into world space using the active camera transform.
	var viewport_rect := camera.get_viewport().get_visible_rect()
	var canvas_to_world := camera.get_canvas_transform().affine_inverse()
	var world_top_left := canvas_to_world * viewport_rect.position
	var world_bottom_right := canvas_to_world * viewport_rect.end

	var min_x = min(world_top_left.x, world_bottom_right.x)
	var max_x = max(world_top_left.x, world_bottom_right.x)
	var min_y = min(world_top_left.y, world_bottom_right.y)
	var max_y = max(world_top_left.y, world_bottom_right.y)

	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))
	
func is_object_in_camera_bounds(node: Node2D, camera: Camera2D, offset: float = 0.0)->bool:
	var bounds := get_camera_bounds(camera)
	if offset != 0.0:
		bounds = bounds.grow(offset)
	
	return bounds.has_point(node.global_position)
	
func is_object_on_camera_right_side(node: Node, camera: Camera2D, offset: float = 0.0)->bool:
	var bounds := get_camera_bounds(camera)
	if node.global_position.x + offset < bounds.position.x:
		return false
		
	return true
	
	
func clamp_node_to_be_in_camera_bounds(node: Node2D, camera: Camera2D, x_offset: float=0.0):
	
	var bounds := get_camera_bounds(camera)
	var should_nullify_x_velocity = false 
	var should_nullify_y_velocity = false 
	if node.global_position.x > bounds.position.x + bounds.size.x - x_offset:
		node.global_position.x = bounds.position.x + bounds.size.x - x_offset
		should_nullify_x_velocity = true
		
	if node.global_position.x < bounds.position.x + x_offset:
		node.global_position.x = bounds.position.x + x_offset
		should_nullify_x_velocity = true
		
	if node.global_position.y < bounds.position.y:
		node.global_position.y = bounds.position.y
		should_nullify_y_velocity = true
		
	if node.global_position.y > bounds.position.y + bounds.size.y:
		node.global_position.y = bounds.position.y + bounds.size.y
		should_nullify_y_velocity = true
	
	if node is CharacterBody2D:
		if should_nullify_x_velocity:
			node.velocity.x = 0
		if should_nullify_y_velocity:
			node.velocity.y = 0
	
	pass
