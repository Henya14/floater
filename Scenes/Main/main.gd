extends Control

@onready var background: ColorRect = $Background

const R_COLOR_CHANGE_SPEED: float = 0.2
const G_COLOR_CHANGE_SPEED: float = 0.3
const B_COLOR_CHANGE_SPEED: float = 0.1

var r_up: bool = true
var g_up: bool = true
var b_up: bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	change_color_of_background(delta)
	pass

func change_color_of_background(delta: float) -> void:
	
	var current_color = background.color
	var r = current_color.r + (delta * R_COLOR_CHANGE_SPEED) * (1 if r_up else -1)
	var g = current_color.g + delta * G_COLOR_CHANGE_SPEED * (1 if g_up else -1)
	var b = current_color.b + delta * B_COLOR_CHANGE_SPEED * (1 if b_up else -1)
	if r > 1.0:
		r_up = false
	elif r <= 0:
		r_up = true
		
	if g > 1.0:
		g_up = false
	elif g <= 0:
		g_up = true
	if b > 1.0:
		b_up = false
	elif b <= 0:
		b_up = true
	
	r = clampf(r, 0, 1)
	g = clampf(g, 0, 1)
	b = clampf(b, 0, 1)
	background.color = Color(r, g, b, current_color.a)
	pass
