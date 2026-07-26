extends Node

const MAIN_SCENE = preload("res://Scenes/Main/main.tscn")

const LEVELS: Dictionary = {
 
}


func change_to_main() -> void:
	get_tree().change_scene_to_packed(MAIN_SCENE)

func load_level(level_name: String) -> void:
	if LEVELS.has(level_name):
		get_tree().change_scene_to_packed(LEVELS[level_name])
	else:
		push_error("Level '%s' not found in LEVELS dictionary." % level_name)
