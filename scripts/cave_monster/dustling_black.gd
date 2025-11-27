extends CharacterBody2D

@export var speed: float = 30
@export var power: int = 600
@export var patrol_points: Array[Marker2D] = []

@export var wait_time: float = 3.0          # เวลาหยุดพักที่จุด patrol
@export var arrive_distance: float = 8.0     # ระยะถือว่าถึงจุด
@onready var damage_nmber_origin: Node2D = $damage_nmber_origin

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label_enemy_power: Label = $Label_enemy_power
@onready var detection_area: Area2D = $Detection_Area
@export var step_audio: AudioStreamPlayer2D
@export var die_audio: AudioStreamPlayer2D

var hp: int = power
var current_point_index = 0
var player: Node2D = null
var is_dead = false
var state: String = "patrol"                 # "patrol", "wait", "chase"
var wait_timer: Timer


func _ready() -> void:
	animated_sprite.frame_changed.connect(_on_frame_changed)

	if patrol_points.is_empty():
		print("No patrol points assigned!")

	detection_area.body_entered.connect(_on_player_detected)
	detection_area.body_exited.connect(_on_player_lost)

	wait_timer = Timer.new()
	wait_timer.one_shot = true
	add_child(wait_timer)
	wait_timer.timeout.connect(_on_wait_finished)

	display_power()


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	match state:
		"chase":
			chase_player()

		"patrol":
			patrol()

		"wait":
			velocity = Vector2.ZERO

	update_animation()
	move_and_slide()


# --------------------------
#        PATROL LOGIC
# --------------------------
func patrol() -> void:
	if patrol_points.size() == 0:
		velocity = Vector2.ZERO
		return

	var target = patrol_points[current_point_index].global_position
	var dir = (target - position).normalized()

	velocity = dir * speed

	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x > 0

	if position.distance_to(target) < arrive_distance:
		start_wait()


func start_wait() -> void:
	state = "wait"
	velocity = Vector2.ZERO
	wait_timer.start(wait_time)


func _on_wait_finished() -> void:
	current_point_index = (current_point_index + 1) % patrol_points.size()
	state = "patrol"


# --------------------------
#       CHASE LOGIC
# --------------------------
func chase_player() -> void:
	if not player:
		state = "patrol"
		return

	var dir = (player.global_position - global_position).normalized()
	velocity = dir * speed

	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x > 0


# --------------------------
#    ANIMATION & DISPLAY
# --------------------------
func update_animation() -> void:
	match state:
		"wait":
			animated_sprite.play("idle")

		"chase":
			animated_sprite.play("side_walk")   # ไม่มี run → ใช้เดินแทน

		"patrol":
			animated_sprite.play("side_walk")


func display_power():
	label_enemy_power.text = str(power)


# --------------------------
#     PLAYER DETECTION
# --------------------------
func _on_player_detected(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		state = "chase"


func _on_player_lost(body: Node2D) -> void:
	if body == player:
		player = null
		state = "patrol"


# --------------------------
#         DAMAGE & DEATH
# --------------------------
func die() -> void:
	if is_dead:
		return
	is_dead = true
	die_audio.play()
	print("%s defeated!" % name)
	if player:
		player.absorb_power(power)

	animated_sprite.play("dead")
	await animated_sprite.animation_finished
	queue_free()


func take_damage(damage: int) -> void:
	hp -= damage
	DamageNumber.displayDamage_Number(damage, damage_nmber_origin.global_position)
	print("%s took %d damage! (HP: %d)" % [name, damage, power])
	if hp <= 0:
		die()


func enemy():
	pass

# ============= 👣 FOOTSTEP AUDIO SYSTEM =============

# เรียกทุกครั้งที่เฟรมขยับ


	
func _on_frame_changed():	
	var anim = animated_sprite.animation

	if anim == "side_walk" or anim == "front_walk" or anim == "back_walk":
		if animated_sprite.frame in [1, 4]:
			play_step_sound()


func play_step_sound():
	step_audio.stop()  # รีเซ็ตเสียง
	step_audio.play()  # เล่นใหม่ทุกครั้ง
