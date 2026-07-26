extends Node

@onready var camera: Camera2D = $Camera2D
@onready var pickup_container: Node = $PickUpContainer

@onready var danger_container: Node = $DangerContainer
@onready var caution_container: Node = $CanvasLayer/MarginContainer/CautionSignHolder
@onready var clouds_layer_1: CloudsLayer = $"Clouds Layer"
@onready var clouds_layer_2: CloudsLayer = $"Clouds Layer2"
@onready var sky_layer: Parallax2D = $"SkyLayer"
@onready var pickup_timer: Timer = $PickUpTimer
@onready var danger_timer: Timer = $DangerTimer
@onready var hud: Control = $CanvasLayer/HUD
@onready var main_menu: MarginContainer = $CanvasLayer/MainScreen/MainMenuContainer
@onready var credits: MarginContainer = $CanvasLayer/MainScreen/CreditsContainer
@onready var credits_button: Button = $CanvasLayer/MainScreen/MainMenuContainer/HContainer/CreditsButton
@onready var credits_button_back_button: Button = $CanvasLayer/MainScreen/CreditsContainer/HContainer/CreditsBackButton
@onready var main_screen: Control = $CanvasLayer/MainScreen
@onready var game_over_container: VBoxContainer = $CanvasLayer/MainScreen/GameOverContainer
@onready var restart_button: Button = $CanvasLayer/MainScreen/GameOverContainer/RestartButton
@onready var credits_label: RichTextLabel = $CanvasLayer/MainScreen/CreditsContainer/HContainer/ScrollContainer/CreditsText
@export var camera_speed = 10.0
@export var danger_sign_timeout: float = 1.0


var started: bool = false
var CHERRY_SCENE: PackedScene = preload("res://Scenes/Pickup/Cherry.tscn")

var ROCKET_SCENE: PackedScene = preload("res://Scenes/Danger/Rocket/rocket.tscn")
var CAUTION_SCENE: PackedScene = preload("res://Scenes/Caution Sign/CautionSign.tscn")
const CREDITS_FILE_PATH := "res://Assets/Credits/credits.txt"

func get_file_content(file_path: String) -> String:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_warning("Could not open file: %s" % file_path)
		return ""

	return file.get_as_text()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	SignalHub.player_health_changed.connect(player_health_changed)
	credits_button.pressed.connect(_credits_button_pressed)
	credits_button_back_button.pressed.connect(_credits_back_button_pressed)
	restart_button.disabled = true
	restart_button.pressed.connect(restart)
	var credits_text := get_file_content(CREDITS_FILE_PATH)
	if credits_text.is_empty():
		credits_text = "Credits file missing from export."
	credits_label.bbcode_text = credits_text
	pass # Replace with function body.
 
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_accept"):
		if event.is_pressed() and not started:
			start_game()
		
func restart():
	get_tree().reload_current_scene()
	pass
func _credits_button_pressed():

	await fade_out(main_menu, 0.5)
	main_menu.visible = false
	credits.modulate.a = 0.0
	credits.visible = true
	fade_in(credits,0.5)
	
	pass

func fade_out(element: Control, duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(element, "modulate",Color(1, 1, 1, 0), duration)
	await  tween.finished
	element.visible = false

func fade_in(element: Control, duration: float = 0.5, ignore_pause: bool = false):
	var tween = create_tween()
	
	if ignore_pause:
		tween.bind_node(element).set_ignore_time_scale(true)

		
	tween.tween_property(element, "modulate",Color(1, 1, 1, 1), duration)
	await  tween.finished
	
func _credits_back_button_pressed():
	await fade_out(credits, 0.5)
	main_menu.modulate.a = 0.0
	main_menu.visible = true
	fade_in(main_menu,0.5)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if not started: 
		return
	move_camera(delta)
	manage_pickups()
	manage_dangers()
	pass

func start_game():

	fade_out(main_screen)
	main_menu.visible = false
	credits.visible = false
	started = true
	camera_speed = 100.0
	hud.modulate.a = 0.0
	fade_in(hud)
	hud.visible = true
	
	await get_tree().create_timer(2.0).timeout
	clouds_layer_1.enabled = true
	clouds_layer_2.enabled = true
	await get_tree().create_timer(2.0).timeout
	pickup_timer.start()
	await get_tree().create_timer(2.0).timeout
	danger_timer.start()
	
func player_health_changed(current_health: int, max_health: int):
	if current_health == 0:
		game_over()
	
	pass
func game_over():
	main_screen.visible = true
	main_screen.modulate.a = 1.0
	restart_button.disabled = false

	get_tree().paused = true
	game_over_container.modulate.a = 0.0
	game_over_container.visible = true
	fade_in(game_over_container, 0.5, true)
	danger_timer.stop()
	pickup_timer.stop()
	clouds_layer_2.enabled = false
	clouds_layer_1.enabled = false
	sky_layer.autoscroll = Vector2(0,0)
	started = false
	
func move_camera(delta: float):
	camera.position.x += camera_speed * delta
	
func manage_pickups():
	for child in pickup_container.get_children():
		if child is Node:
			if not GameUtils.is_object_on_camera_right_side(child, camera, 50):
				child.queue_free()
				
func manage_dangers():
	for child in danger_container.get_children():
		if child is Node:
			if not GameUtils.is_object_on_camera_right_side(child, camera, 100):
				child.queue_free()

func _on_pick_up_timer_timeout() -> void:
	var pickup_pos = GameUtils.get_random_coords_outside_camera_bounnds(camera, 100, 64)
	GameUtils.spawn_scene(pickup_pos, pickup_container, CHERRY_SCENE)
	pass # Replace with function body.


func _on_danger_timer_timeout() -> void:
	var danger_pos = GameUtils.get_random_coords_outside_camera_bounnds(camera, 100, 50)
	var caution_instance = GameUtils.spawn_scene(Vector2(0, danger_pos.y), caution_container, CAUTION_SCENE)
	await get_tree().create_timer(danger_sign_timeout).timeout
	caution_instance.queue_free()
	GameUtils.spawn_scene(danger_pos, danger_container, ROCKET_SCENE)
	pass # Replace with function body.
