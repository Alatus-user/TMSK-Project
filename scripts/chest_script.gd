extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var press_e_label: Label = $press_E
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var item_sprite: Sprite2D = $Item_Sprite
@onready var item_sprite_animation_player: AnimationPlayer = $Item_Sprite/Item_Sprite_AnimationPlayer
@export var item_inside : ItemData


var opened = false
var InRange = false
var player_ref : Node = null

func _ready() -> void:
	item_sprite.visible = false
	item_inside_update()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact") && !opened && InRange:
		opened = true
		press_e_label.visible = false
		animated_sprite.play("open")
		sprite_2d.visible = false
		await animated_sprite.animation_finished
		item_sprite_animation_player.play("item_sprite_pop")
		if player_ref and item_inside:
			if player_ref.has_node("Inventory"):
				var inv = player_ref.get_node("Inventory")
				inv.add_item(item_inside)
				print("Player received:", item_inside.item_name)
	


func _on_chest_area_2d_body_entered(body: Node2D) -> void:
	if "Player" in body.name:
		press_e_label.visible = true
		InRange = true
		player_ref = body


func _on_chest_area_2d_body_exited(body: Node2D) -> void:
	if "Player" in body.name:
		press_e_label.visible = false
		InRange = false
		player_ref = null

func item_inside_update() -> void:
	item_sprite.texture = item_inside.icon
	
