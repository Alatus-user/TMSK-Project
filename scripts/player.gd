extends CharacterBody2D

# ============= ⚔️ PLAYER DATA =============
# ตัวแปรที่เชื่อมกับ node ย่อยภายใน Player scene
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var deal_attack_timer: Timer = $deal_attack_timer
@onready var label_player_power: Label = $Label_player_power
@onready var death_ui = $death
@onready var anim_player = $death_animation

# สัญญาณเมื่ออนิเมชันตายเล่นจบ (ใช้รอ await)
signal death_anim_finised

# ค่าพื้นฐานของตัวละคร
var speed: float = 40.0
var direction: Vector2
var current_dir: String = "none"
var is_attack_ip = false  # ใช้กันการเคลื่อนไหวระหว่างโจมตี

# ค่าพลังตัวละคร
var power: int = 5              
var hp: int = power              

# รายชื่อศัตรูที่อยู่ในระยะโจมตี
var enemies_in_range: Array = []


# ============= 🏃 MOVEMENT =============
func _physics_process(delta: float) -> void:
	# อ่านอินพุตจากปุ่มที่ตั้งไว้ใน Input Map
	direction.x = Input.get_axis("Move_Left", "Move_Right")
	direction.y = Input.get_axis("Move_Up", "Move_Down")
	direction = direction.normalized()  # ป้องกันการวิ่งเร็วเกินเมื่อกดสองทิศพร้อมกัน
	display_power()

	# ถ้ายังไม่อยู่ในสถานะโจมตี
	if not is_attack_ip:
		if direction.length() > 0:
			# เคลื่อนที่ปกติ
			velocity = direction * speed
			update_current_dir()   # อัปเดตทิศทางปัจจุบัน
			play_anim(1)           # เล่นอนิเมชันเดิน
		else:
			# ถ้าไม่กดเดิน ให้ค่อย ๆ หยุด
			velocity = velocity.move_toward(Vector2.ZERO, speed)
			play_anim(0)           # เล่นอนิเมชัน idle
	else:
		# ถ้าโจมตีอยู่ให้หยุดเคลื่อนที่
		velocity = velocity.move_toward(Vector2.ZERO, speed)

	# ปรับความเร็วตามประเภท tile (จากฟังก์ชัน get_tile_speed)
	velocity *= get_tile_speed()

	# เคลื่อนไหวจริง ๆ
	move_and_slide()


# ============= 🎭 ANIMATION =============
func update_current_dir() -> void:
	# ใช้เพื่อบอกว่า player หันหน้าไปทางไหน (เพื่อเลือกอนิเมชัน)
	if abs(direction.x) > abs(direction.y):
		current_dir = "right" if direction.x > 0 else "left"
	else:
		current_dir = "down" if direction.y > 0 else "up"

func play_anim(movement: int) -> void:
	var anim = animated_sprite_2d
	match current_dir:
		"right":
			anim.flip_h = false
			if movement == 1: anim.play("side_walk")
			elif movement == 0 and not is_attack_ip: anim.play("side_idle")
		"left":
			anim.flip_h = true
			if movement == 1: anim.play("side_walk")
			elif movement == 0 and not is_attack_ip: anim.play("side_idle")
		"down":
			if movement == 1: anim.play("front_walk")
			elif movement == 0 and not is_attack_ip: anim.play("front_idle")
		"up":
			if movement == 1: anim.play("back_walk")
			elif movement == 0 and not is_attack_ip: anim.play("back_idle")


# ============= 📏 COLLISION DETECTION =============
# ตรวจจับว่า Enemy เข้ามาในระยะโจมตีหรือไม่
func _on_player_hurtbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):   # ตรวจว่า node นั้นมี method enemy()
		enemies_in_range.append(body)

func _on_player_hurtbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemies_in_range.erase(body)


# ============= ⚔️ COMBAT SYSTEM =============
func attack_enemy(target) -> void:
	# สุ่มดาเมจ 1–6 แล้วคูณพลังโจมตีของผู้เล่น
	var damage = randi_range(1, 6) * power
	target.take_damage(damage)

	# ถ้าศัตรูยังไม่ตาย ให้สวนกลับ
	if target.hp > 0:
		var enemy_damage = target.power
		hp -= enemy_damage
		power = hp   # ให้ power แสดงค่าเท่ากับ HP ปัจจุบัน
		print("Enemy deals %d damage! Player HP now %d" % [enemy_damage, hp])

		# ถ้าตายให้เล่นอนิเมชันตาย
		if hp <= 0:
			print("Player defeated!")
			anim_player.play("death_animation")
			await death_anim_finised
			$death.visible = true
			# queue_free()  # ถ้าอยากลบ player ออกจากเกมก็เปิดบรรทัดนี้ได้

# ฟังก์ชันดูดพลังจากศัตรู (ตอนฆ่าศัตรู)
func absorb_power(enemy_power: int) -> void:
	power += enemy_power
	hp = power
	print("Absorbed %d power! Player new power = %d" % [enemy_power, power])
	

# ============= 🎮 INPUT HANDLER =============
func _input(event):
	# ถ้ากดปุ่ม "attack" และไม่อยู่ระหว่างโจมตี
	if Input.is_action_just_pressed("attack") and not is_attack_ip:
		if hp > 0:
			attack()

func attack():
	is_attack_ip = true
	
	# โจมตีเฉพาะถ้ามีศัตรูอยู่ในระยะ
	if enemies_in_range.size() > 0:
		var target = enemies_in_range[0]
		attack_enemy(target)

	# เล่นอนิเมชันโจมตี ตามทิศทางที่หันหน้าอยู่
	match current_dir:
		"right":
			animated_sprite_2d.flip_h = false
			animated_sprite_2d.play("side_ATK")
		"left":
			animated_sprite_2d.flip_h = true
			animated_sprite_2d.play("side_ATK")
		"down":
			animated_sprite_2d.play("front_ATK")
		"up":
			animated_sprite_2d.play("back_ATK")

	# เริ่มจับเวลาโจมตี (กัน spam)
	deal_attack_timer.start()

func _on_deal_attack_timer_timeout() -> void:
	deal_attack_timer.stop()
	is_attack_ip = false  # กลับมาเคลื่อนที่ได้อีกครั้ง


# อัปเดตค่า power ที่แสดงบน Label
func display_power():
	label_player_power.text = "" + str(power)


# เมื่ออนิเมชันตายเล่นจบ ให้ส่งสัญญาณออกมา
func _on_death_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death_animation":
		death_anim_finised.emit()


# ============= 🌍 TILE-BASED SPEED SYSTEM =============
# ดึงความเร็วจาก tile ปัจจุบันที่ผู้เล่นยืนอยู่
func get_tile_speed() -> float:
	var tilemap: TileMapLayer = get_tree().get_first_node_in_group("tilemap")
	
	if not tilemap: 
		return 1.0  # ถ้าไม่เจอ TileMapLayer ให้ความเร็วพื้นฐาน
	
	var cell: Vector2i = tilemap.local_to_map(position)
	var data: TileData = tilemap.get_cell_tile_data(cell)
	
	if data:
		var tile_speed: float = data.get_custom_data("tile_speed")
		if tile_speed > 0:
			return tile_speed  # คืนค่าความเร็วจาก custom data
	
	return 1.0  # ถ้าไม่มีข้อมูล custom data ก็ใช้ค่าเริ่มต้น
