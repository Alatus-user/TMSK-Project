extends Node2D
class_name PressurePlate

signal activated
signal deactivated

var bodies : int = 0
var is_active : bool = false
var off_rect : Rect2

@onready var area: Area2D = $Area2D
@onready var button: Sprite2D = $Button


func _ready() -> void:
	area.body_entered.connect(_on_area_2d_body_entered)
	area.body_exited.connect(_on_area_2d_body_exited)
	off_rect = button.region_rect



func _on_area_2d_body_entered(body: Node2D) -> void:
	bodies += 1
	check_is_activated()


func _on_area_2d_body_exited(body: Node2D) -> void:
	bodies -= 1
	check_is_activated()
	

func check_is_activated() -> void:
	if bodies > 0 and is_active == false:
		is_active = true
		button.region_rect.position.y = off_rect.position.y + 108
		activated.emit()
		
	elif bodies == 0 and is_active == true:
		is_active = false
		button.region_rect.position.y = off_rect.position.y
		deactivated.emit()
	
