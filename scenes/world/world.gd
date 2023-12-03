extends Node2D

const Enemy = preload("res://scenes/enemy/enemy.tscn")
const PrimaryAttack = preload("res://scenes/attack/primary_attack.tscn")
const SecondaryAttack = preload("res://scenes/attack/secondary_attack.tscn")


func spawn_enemy():
	var enemy = Enemy.instantiate()
	var spawn_location = $SpawnPath/SpawnPathLocation

	spawn_location.progress_ratio = randf()
	enemy.position = spawn_location.position
	add_child(enemy)


func spawn_attack(primary: bool, direction: Vector2, position:Vector2):
	var attack: Attack = PrimaryAttack.instantiate() if primary else SecondaryAttack.instantiate()
	var position_modifier: int = 65 if primary else 25

	attack.position = position + (direction * position_modifier)
	attack.direction = direction
	attack.animation.rotate(direction.angle())
	add_child(attack)

func start_game():
	$SpawnRate.start()
	$DifficultyIncrease.start()


func game_over():
	$SpawnRate.stop()
	$DifficultyIncrease.stop()
	get_tree().call_group("enemies", "queue_free")
	$Player.queue_free()


func _ready():
	start_game()


func _on_spawn_rate_timeout():
	spawn_enemy()


func _on_difficulty_increase_timeout():
	$SpawnRate.wait_time *= 0.95


func _on_player_died():
	game_over()


func _on_player_attacked(primary, direction, position):
	spawn_attack(primary, direction, position)
