extends CharacterBody2D

@export var speed: float = 0    # Slime2 ไม่เดิน → ตั้ง speed = 0

var player_chase: bool = false  # ไม่ได้ใช้แล้ว แต่เก็บไว้ให้ระบบอื่นไม่พัง
var player: Node2D = null
var is_dead = false

@export var power: int = 10
var hp: int = power

var player_in_attackzone = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label_enemy_power: Label = $Label_enemy_power
@onready var dead_timmer: Timer = $Dead_timmer
@onready var damage_nmber_origin: Node2D = $damage_nmber_origin

@export var step_audio: AudioStreamPlayer2D
@export var die_audio: AudioStreamPlayer2D


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	update_animation()
	display_power()
	# ❌ Slime2 ไม่มีการเคลื่อนที่เลย


# -------------------------------------------------------
# Slime2 ถูกตรวจโดย player ได้ แต่จะไม่ไล่ผู้เล่น
# -------------------------------------------------------
func _on_detection_area_body_entered(body: Node2D) -> void:
	# สิ่งนี้ทำให้ player รู้ว่าเป็นศัตรู → คงไว้
	if body.has_method("attack"):
		player = body
		player_chase = false   # ❗ ไม่ไล่ผู้เล่น
		

#func _on_detection_area_body_exited(body: Node2D) -> void:
#	if body == player:
#		player_chase = false


func enemy(): pass


# -------------------------------------------------------
# รับดาเมจจาก player
# -------------------------------------------------------
func take_damage(damage: int) -> void:
	hp -= damage
	DamageNumber.displayDamage_Number(damage, damage_nmber_origin.global_position)
	print("%s took %d damage! (HP: %d)" % [name, damage, hp])

	if hp <= 0:
		die()


# -------------------------------------------------------
# ตาย
# -------------------------------------------------------
func die() -> void:
	if is_dead:
		return

	is_dead = true
	die_audio.play()

	print("%s defeated!" % name)
	
	# ให้ player ดูดพลัง (ถ้าต้องการ)
	if player:
		print("Are you player")
		player.absorb_power(power)

	animated_sprite.play("dead")
	await animated_sprite.animation_finished
	queue_free()


# -------------------------------------------------------
# UI
# -------------------------------------------------------
func display_power() -> void:
	label_enemy_power.text = str(power)


# -------------------------------------------------------
# Animation — ไม่มีการเดิน → เล่น idle ตลอด
# -------------------------------------------------------
func update_animation() -> void:
	animated_sprite.play("idle")


func _ready() -> void:
	animated_sprite.frame_changed.connect(_on_frame_changed)


# -------------------------------------------------------
# เอฟเฟกต์เสียงตอน idle (ถ้าใช้)
# -------------------------------------------------------
func _on_frame_changed():	
	var anim = animated_sprite.animation

	if anim == "idle":
		if animated_sprite.frame in [2]:
			play_step_sound()


func play_step_sound():
	step_audio.stop()
	step_audio.play()
