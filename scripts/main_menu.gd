extends Control

const scene_level = preload("res://scene/world.tscn")


func _input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("Quit")):
		get_tree().quit()


func _on_start_pressed() -> void:
	print("Start Pressed")
	$load_scene.layer = 2
	$load_scene._transiton()
	await $load_scene.transition_finished
	get_tree().change_scene_to_packed(scene_level)
	
