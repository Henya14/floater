extends Node


signal player_health_changed(current_health: int, max_health: int)
signal score_changed(changed_by: int)
signal game_over

func emit_player_health_changed(current_health: int, max_health: int):
	player_health_changed.emit(current_health, max_health)

func emit_score_changed(changed_by:int):
	score_changed.emit(changed_by)

func emit_game_over():
	game_over.emit()
