@tool
extends Area2D
class_name DamageBox

@export_category("Damage")
@export var damage_amount: int = 1
@export var explodes_on_hit: bool = true
@export var dies_on_hit: bool = true

@export var shape: Shape2D
@onready var collision_shape: CollisionShape2D = $CollisionShape


func _ready() -> void:
	_update_components()
	pass
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_POST_SAVE:
		_update_components()
	#_update_components()
		
		
func _update_components() -> void:
	if shape:
		collision_shape.shape = shape
func get_damage() -> int:
	return damage_amount

func _handle_on_collision() -> void:
	if dies_on_hit:
		get_parent().queue_free()

func _on_body_entered(body: Node2D) -> void:
	_handle_on_collision()


func _on_area_entered(area: Area2D) -> void:
	_handle_on_collision()
