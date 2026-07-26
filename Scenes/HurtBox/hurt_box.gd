@tool
extends Area2D

signal died
signal damge_taken(amount: int)
signal current_health_changed(amount: int)

@export var max_health = 4
@export var kills_parent_on_death: bool = false

@export var shape: Shape2D
@onready var collision_shape: CollisionShape2D = $CollisionShape

var current_health:
	set(value):
		current_health = value
		current_health_changed.emit(value)
		
func _ready() -> void:
	current_health = max_health
	_update_components()


func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_POST_SAVE:
		_update_components()
	#_update_components()
		
		
func _update_components() -> void:
	if shape:
		collision_shape.shape = shape
	
func die():
	died.emit()
	if kills_parent_on_death:
		get_parent().queue_free()
		
func take_damage(amount: int):
	damge_taken.emit(amount)
	current_health = clamp(current_health - amount, 0, max_health)
	if current_health <= 0:
		die()
	
	pass

func _on_area_entered(area: Area2D) -> void:
	if area is DamageBox:
		take_damage(area.get_damage())
