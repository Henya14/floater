extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screen_center = get_viewport_rect().size / 2
	
	global_position = screen_center
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
