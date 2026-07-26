extends Area2D
@export var score = 10
@onready var audio_effect: AudioStreamPlayer = $AudioEffect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		SignalHub.emit_score_changed(score)
		remove()
	

func remove():
	hide()
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	audio_effect.play()
	await  audio_effect.finished
	queue_free()
