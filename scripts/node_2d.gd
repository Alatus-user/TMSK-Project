extends Node2D

var power: int = 10
var hp: int = power

func attack_enemy(enemy) -> bool:
	var damage = randi_range(1, 6) * power
	enemy.hp -= damage
	print("Player deals %d damage!" % damage)

	if enemy.hp <= 0:
		print("Enemy defeated!")
		absorb_power(enemy.power)
		return true

	var enemy_damage = enemy.power
	hp -= enemy_damage
	power = hp
	print("Enemy deals %d damage! Player HP now %d" % [enemy_damage, hp])

	if hp <= 0:
		print("Player defeated!")
		return true

	return false

func absorb_power(enemy_power: int) -> void:
	power += enemy_power
	hp = power
	print("Absorbed %d power! Player new power = %d" % [enemy_power, power])
