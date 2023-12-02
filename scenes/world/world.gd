extends Node2D

var enemy_scene = preload("res://scenes/enemy/enemy.tscn")


func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	var spawn_location = $SpawnPath/SpawnPathLocation

	spawn_location.progress_ratio = randf()
	enemy.position = spawn_location.position
	add_child(enemy)


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
