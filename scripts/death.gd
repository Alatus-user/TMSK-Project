extends CanvasLayer


func _physics_process(delta: float) -> void:
	if ($".".visible == true):
		get_tree().paused = true
	if (Input.is_action_just_pressed("Restart")):
		get_tree().reload_current_scene()
	if (Input.is_action_just_released("Restart")):
		get_tree().paused = false
