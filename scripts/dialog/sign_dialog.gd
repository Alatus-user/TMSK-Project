extends Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var press_e: Label = $"../press_E"

const lines: Array[String] = [
	"How many times you have read this sign",
	"There is no way OUT",
]


var InRange = false
var player_ref : Node = null

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact") && InRange:
		print("Hi")
		DialogManager.start_dialog(global_position, lines)

		
	
func _on_body_entered(body: Node2D) -> void:
	if "Player" in body.name:
		press_e.visible = true
		InRange = true


func _on_body_exited(body: Node2D) -> void:
	if "Player" in body.name:
		press_e.visible = false
		InRange = false
