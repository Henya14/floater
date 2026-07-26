extends Node


@export var speed_x: float = 50.0
@export var speed_y: float = 50.0
@export var y_max_movement_height: float = 200.0
@export var bounce_y: bool = true
@export var moving_upward = true

var starting_y_position:float
var random_y_movement_height: float
var parent: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	starting_y_position = parent.position.y
	random_y_movement_height = randf_range(0, y_max_movement_height)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	
	if not parent:
		print("NO PARENT")
		return
	parent.position.x -= delta * speed_x
	

	parent.position.y += delta * speed_y * (-1 if moving_upward else 1)
	
	if bounce_y:
		if parent.position.y > random_y_movement_height + starting_y_position:
			moving_upward = true
		elif parent.position.y < starting_y_position:
			moving_upward = false
		pass

	
