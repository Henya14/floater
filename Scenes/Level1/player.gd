extends CharacterBody2D
class_name Player

@onready var hurt_effect: AudioStreamPlayer = $HurtEffect
@onready var booster_effect: AudioStreamPlayer = $BoosterEffect
@export var CAMERA_MOVE_SPEED = 100.0
@export var SPEED = 200.0
const JUMP_VELOCITY = -50.0
const MAX_VELOCITY = 600.0
@export var max_health = 4

@export var camera: Camera2D;
var current_health = 4:
	set(value):
		SignalHub.emit_player_health_changed(value, max_health)
		current_health = value

func _ready() -> void:
	current_health = max_health
	pass
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("ui_accept"):
		velocity.y += JUMP_VELOCITY
		if not booster_effect.playing:
			booster_effect.play()
	
	if  Input.is_action_just_released("ui_accept"):
		if booster_effect.playing:
			booster_effect.stop()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x += direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if velocity.y < -MAX_VELOCITY:
		velocity.y = -MAX_VELOCITY
	
	if velocity.x < -(MAX_VELOCITY - CAMERA_MOVE_SPEED):
		velocity.x = -(MAX_VELOCITY - CAMERA_MOVE_SPEED)
	if velocity.x > MAX_VELOCITY:
		velocity.x = MAX_VELOCITY

	move_and_slide()
	GameUtils.clamp_node_to_be_in_camera_bounds(self, camera, 64)
		  

func _on_hurt_box_current_health_changed(amount: int) -> void:
	if amount < current_health:
		if not  hurt_effect.playing:
			hurt_effect.play()
	current_health = amount
	
	pass # Replace with function body.
