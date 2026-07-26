extends Control

@onready var score_label: Label = $"Top Container/MarginContainer2/Score Label"
@onready var heart_container: HFlowContainer = $"Top Container/MarginContainer2/MarginContainer/Heart Container"
@export var HEALTHY_HEART: Texture2D
@export var BROKEN_HEART: Texture2D
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	SignalHub.player_health_changed.connect(player_health_changed)
	SignalHub.score_changed.connect(score_changed)
	score_label.text = format_score(score)
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func format_score(score: int) -> String:
	return "SCORE: %04d" % score

func player_health_changed(current_health: int, max_health: int):
	for child in heart_container.get_children():
		child.queue_free();
	for i in max_health:
		if i  < current_health:
			var heart_texture = TextureRect.new()
			heart_texture.texture = HEALTHY_HEART
			heart_container.add_child(heart_texture)
		else:
			var heart_texture = TextureRect.new()
			heart_texture.texture = BROKEN_HEART
			heart_container.add_child(heart_texture)

func score_changed(change_by: int): 
	score += change_by
	score_label.text = format_score(score)
