extends CanvasLayer
signal transition_finished
@onready var color_rect = $ColorRect
@onready var anim_player = $AnimationPlayer

func _transiton():
	color_rect.visible = true
	anim_player.play("fade_anim")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_anim":
		transition_finished.emit()
		anim_player.play_backwards("fade_anim")
		color_rect.visible = false
