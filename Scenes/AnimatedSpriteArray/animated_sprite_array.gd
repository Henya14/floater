extends Node2D

@onready var animation_sprite: AnimatedSprite2D = $"AnimatedSprite2D"

@export var texture: Texture2D
@export var columns: int = 3
@export var rows: int = 4
@export var frames_per_second: float = 5.0

const IDLE_ANIMATION_NAME = "idle"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_build_idle_animation()
	animation_sprite.play(IDLE_ANIMATION_NAME)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


func _build_idle_animation() -> void:
	if !texture:
		return
	var sprite_frames := SpriteFrames.new()
	sprite_frames.add_animation(IDLE_ANIMATION_NAME)
	sprite_frames.set_animation_loop(IDLE_ANIMATION_NAME, true)
	sprite_frames.set_animation_speed(IDLE_ANIMATION_NAME, frames_per_second)
	
	var frame_width = texture.get_width() / columns
	var frame_height = texture.get_height() / rows
	
	for row in rows:
		for col in columns:
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(col * frame_width, row * frame_height, frame_width, frame_height)
			sprite_frames.add_frame(IDLE_ANIMATION_NAME, atlas)
			
	animation_sprite.sprite_frames = sprite_frames
	
