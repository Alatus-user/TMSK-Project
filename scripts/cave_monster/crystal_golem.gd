extends CharacterBody2D


@export var speed: float = 0

var player_chase: bool = false

var player: Node2D = null

var is_dead = false


@export var power: int = 1000

var hp: int = power

var player_in_attackzone = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label_enemy_power: Label = $Label_enemy_power
@onready var dead_timmer: Timer = $Dead_timmer
@onready var damage_nmber_origin: Node2D = $damage_nmber_origin
@export var audio_stream_player_2d: AudioStreamPlayer2D
@export var die_audio: AudioStreamPlayer2D



func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	update_animation()
	
	display_power()

func enemy(): pass

func take_damage(damage: int) -> void:
	if is_dead:
		return
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
	
	# ส่วนที่ 1: ถ้ามีผู้เล่นอยู่ ให้ดูดพลัง (ทำเฉพาะตอนมี player)
	if player: 
		player.absorb_power(power)
		
	# ส่วนที่ 2: อนิเมชั่นการตายและการลบตัวละคร (ต้องทำเสมอ ไม่ว่าใครจะฆ่า)
	print("Playing death animation")
	animated_sprite.play("dead")
	await animated_sprite.animation_finished
	self.queue_free()
		
	
			
		

func display_power():

	label_enemy_power.text = ""  + str(power)
	
func update_animation():
	animated_sprite.play("idle")
	

# ============= 👣 FOOTSTEP AUDIO SYSTEM =============

# เรียกทุกครั้งที่เฟรมขยับ

func _ready() -> void:
	animated_sprite.frame_changed.connect(_on_frame_changed)
	
func _on_frame_changed():	
	var anim = animated_sprite.animation

	if anim == "idle":
		if animated_sprite.frame in [2]:
			play_step_sound()


func play_step_sound():
	audio_stream_player_2d.stop()  # รีเซ็ตเสียง
	audio_stream_player_2d.play()  # เล่นใหม่ทุกครั้ง
