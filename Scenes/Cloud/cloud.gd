extends TextureRect

class_name Cloud 

@export var speed: float = 10.0:
	set(value):
		speed = clamp(value, 0.0, 1000.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= speed * delta
	pass
