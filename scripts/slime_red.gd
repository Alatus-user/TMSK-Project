extends CharacterBody2D


@export var speed: float = 70

@export var player_chase: bool = false

@export var player: Node2D = null

@export var is_dead = false

@export var power: int = 500

@export var hp: int = power

@export var step_audio: AudioStreamPlayer2D

@export var player_in_attackzone = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label_enemy_power: Label = $Label_enemy_power
@onready var dead_timmer: Timer = $Dead_timmer
@onready var damage_nmber_origin: Node2D = $damage_nmber_origin
@export var die_audio: AudioStreamPlayer2D



func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	update_animation()
	
	display_power()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("attack"): # เช็คว่าเป็น player
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_chase = false

func enemy(): pass

func take_damage(damage: int) -> void:
	hp -= damage
	DamageNumber.displayDamage_Number(damage, damage_nmber_origin.global_position)
	print("%s took %d damage! (HP: %d)" % [name, damage, hp])
	if hp <= 0:
		die()
		

func die() -> void:
	if is_dead:
		return
	is_dead = true
	die_audio.play()
	print("%s defeated!" % name)
	if player: # player ดูดพลัง
		player.absorb_power(power)
		
		print("Dead")
		animated_sprite.play("dead")
		print("Dead")
		await animated_sprite.animation_finished
		self.queue_free()
		
	
			
		

func display_power():

	label_enemy_power.text = ""  + str(power)
	
func update_animation():
	if player_chase and player:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		move_and_slide()
		animated_sprite.play("side_walk")
		animated_sprite.flip_h = (player.position.x - position.x) < 0
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
	
	
# ============= 👣 FOOTSTEP AUDIO SYSTEM =============

# เรียกทุกครั้งที่เฟรมขยับ

func _ready() -> void:
	animated_sprite.frame_changed.connect(_on_frame_changed)
	
func _on_frame_changed():	
	var anim = animated_sprite.animation

	if anim == "side_walk" or anim == "front_walk" or anim == "back_walk":
		if animated_sprite.frame in [1, 4]:
			play_step_sound()


func play_step_sound():
	step_audio.stop()  # รีเซ็ตเสียง
	step_audio.play()  # เล่นใหม่ทุกครั้ง
