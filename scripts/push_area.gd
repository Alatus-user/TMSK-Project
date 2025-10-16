extends Area2D
@onready var player: CharacterBody2D = $".."


func _ready() -> void:
	body_entered.connect(_on_body_enter)
	body_exited.connect(_on_body_exit)

func _on_body_enter (body : Node2D) -> void:
	if body is PushableBarrel:
		body.push_direction = player.direction
	
func _on_body_exit (body : Node2D) -> void:
	if body is PushableBarrel:
		body.push_direction = Vector2.ZERO
