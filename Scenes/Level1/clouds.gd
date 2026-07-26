extends Parallax2D
class_name CloudsLayer
var cloud_scene: PackedScene = preload("res://Scenes/Cloud/Cloud.tscn")
@export var camera: Camera2D
@export var cloud_textures: Array[Texture2D] = []
@export var enabled: bool = false
@export var min_cloud_scale: float = 0.5
@export var max_cloud_scale: float = 1.5

@export var min_drift_speed: float = 100.0
@export var max_drift_speed: float = 500.0
@export var max_clouds: float = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not enabled: 
		return
	var screen_size = get_viewport_rect().size
	
	for i in range(3):
		spawn_cloud(true)
	pass # Replace with function body.
	

func spawn_cloud(spawn_in_screen:bool = false) -> void:
	
	if cloud_textures.size() < 1:
		return
		
	var cloud: Cloud = cloud_scene.instantiate()
	
	var random_cloud_texture_index = randi() % cloud_textures.size()
	cloud.texture = cloud_textures[random_cloud_texture_index]
	
	var cloud_position = GameUtils.get_random_coords_in_camera_bounds(camera) if spawn_in_screen else GameUtils.get_random_coords_outside_camera_bounnds(camera, 100, 50, randf_range(300, 1500))
	cloud.position = cloud_position
	
	var random_scale = randf_range(min_cloud_scale, max_cloud_scale)
	cloud.scale = Vector2(random_scale, random_scale)
	cloud.flip_h = (randf() > 0.5)
	
	cloud.speed = randf_range(min_drift_speed, max_drift_speed)
	add_child(cloud)
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not enabled: 
		return
	manage_active_clouds()
	var cloud_count = get_children().filter(func(child): return child is Cloud).size()
	
	var clouds_to_spawn = max_clouds - cloud_count
	
	if clouds_to_spawn > 0:
		for i in range(clouds_to_spawn):
			spawn_cloud()
	
func manage_active_clouds():
	for child in get_children():
		if child is Cloud:
			if not GameUtils.is_object_on_camera_right_side(child, camera, child.size.x):
				child.queue_free()
