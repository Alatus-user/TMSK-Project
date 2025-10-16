extends Node2D 
var player_current_attack = false

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("Quit")):
		get_tree().quit()
	if (Input.is_action_just_pressed("Restart")):
		get_tree().reload_current_scene()
