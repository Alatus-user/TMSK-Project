extends CharacterBody2D

@export var speed: float = 25

var player_chase: bool = false
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


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	update_animation()
	display_power()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("attack"):
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
	step_audio.play()
	print("%s defeated!" % name)

	if player: # player ดูดพลังถ้ามี
		player.absorb_power(power)

	# เล่นแอนิเมชันตายทุกกรณี
	animated_sprite.play("dead")
	await animated_sprite.animation_finished
	queue_free()


func display_power() -> void:
	label_enemy_power.text = str(power)


func update_animation() -> void:
	# ไม่มีการเดินแล้ว → ใช้ idle ตลอด
	animated_sprite.play("idle")

func _ready() -> void:
	animated_sprite.frame_changed.connect(_on_frame_changed)
	
func _on_frame_changed():	
	var anim = animated_sprite.animation

	if anim == "idle":
		if animated_sprite.frame in [2]:
			play_step_sound()


func play_step_sound():
	step_audio.stop()  # รีเซ็ตเสียง
	step_audio.play()  # เล่นใหม่ทุกครั้ง
