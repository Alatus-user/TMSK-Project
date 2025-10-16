extends Node2D
class_name DoorBoulder


@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	pass
	
func open() -> void:
	animation_player.play("Open")


func close() -> void:
	animation_player.play_backwards("Open")
