extends StaticBody2D

# เมื่อ Node พร้อมใช้งาน จะโหลด Node ลูกต่าง ๆ มาเก็บในตัวแปร
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var press_e_label: Label = $press_E
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var item_sprite: Sprite2D = $Item_Sprite
@onready var item_sprite_animation_player: AnimationPlayer = $Item_Sprite/Item_Sprite_AnimationPlayer
@export var open_chest_sfx: AudioStreamPlayer2D

# ไอเทมที่อยู่ในกล่อง (ส่งค่ามาจาก Inspector)
@export var item_inside : ItemData

# สถานะกล่องและผู้เล่น
var opened = false
var InRange = false
var player_ref : Node = null

func _ready() -> void:
	# ซ่อน Sprite ของไอเทมก่อนที่กล่องจะถูกเปิด
	item_sprite.visible = false
	# อัปเดตภาพไอเทมที่อยู่ในกล่อง
	item_inside_update()
func _process(delta: float) -> void:
	# ถ้ากดปุ่ม Interact และอยู่ในระยะ และกล่องยังไม่เคยเปิด
	if Input.is_action_just_pressed("Interact") && !opened && InRange:
		opened = true
		press_e_label.visible = false
		# เล่นอนิเมชันเปิดกล่อง
		open_chest_sfx.play()
		animated_sprite.play("open")
		sprite_2d.visible = false
		
		# รอจนกว่าอนิเมชันเปิดกล่องจะจบ
		await animated_sprite.animation_finished
		# เล่นอนิเมชันเด้งไอเทม
		item_sprite_animation_player.play("item_sprite_pop")

		# ใส่ไอเทมให้ผู้เล่นถ้าผู้เล่นมี inventory
		if player_ref and item_inside:
			if player_ref.has_node("Inventory"):
				var inv = player_ref.get_node("Inventory")
				inv.add_item(item_inside)
				print("Player received:", item_inside.item_name)

func _on_chest_area_2d_body_entered(body: Node2D) -> void:
	# ถ้าตัวที่เข้ามาเป็น Player ให้แสดงป้ายกด E
	if "Player" in body.name:
		press_e_label.visible = true
		InRange = true
		player_ref = body

func _on_chest_area_2d_body_exited(body: Node2D) -> void:
	# เมื่อ Player เดินออกจากระยะ
	if "Player" in body.name:
		press_e_label.visible = false
		InRange = false
		player_ref = null

func item_inside_update() -> void:
	# อัปเดตภาพ Item Sprite ให้ตรงกับไอเทมในกล่อง
	item_sprite.texture = item_inside.icon
