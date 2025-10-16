extends CharacterBody2D


@export var speed: float = 10
var player_chase: bool = false
var player: Node2D = null
var is_dead = false

@export var power: int = 50
var hp: int = power
var player_in_attackzone = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label_enemy_power: Label = $Label_enemy_power
@onready var dead_timmer: Timer = $Dead_timmer
@onready var damage_nmber_origin: Node2D = $damage_nmber_origin



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
	
