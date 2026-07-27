extends Control

@export var y_coord: float = 0.0
@onready var sprite: Sprite2D = $Sprite
@onready var audio_stream_player = $AudioStreamPlayer
const warning_sound: AudioStream = preload("res://Assets/Effects/2 - 7 Space Sounds.mp3")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.position.y = y_coord
	audio_stream_player.stream = warning_sound
	audio_stream_player.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
