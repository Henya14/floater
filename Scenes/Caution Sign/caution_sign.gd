extends Control

@export var y_coord: float = 0.0
@onready var sprite: Sprite2D = $Sprite
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.position.y = y_coord
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
