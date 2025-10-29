extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var press_e_label: Label = $press_E
@onready var sprite_2d: Sprite2D = $Sprite2D

var opened = false
var InRange = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact") && !opened && InRange:
		opened = true
		press_e_label.visible = false
		animated_sprite.play("open")
		sprite_2d.visible = false
		


func _on_chest_area_2d_body_entered(body: Node2D) -> void:
	if "Player" in body.name:
		press_e_label.visible = true
		InRange = true
		


func _on_chest_area_2d_body_exited(body: Node2D) -> void:
	if "Player" in body.name:
		press_e_label.visible = false
		InRange = false
