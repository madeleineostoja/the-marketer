extends CharacterBody2D

signal killed

const SPEED: int = 150
@onready var characters := [
	$Character1,
	$Character2,
	$Character3,
	$Character4,
	$Character5,
	$Character6,
	$Character7,
	$Character8,
	$Character9,
	$Character10
]
@onready var player: CharacterBody2D = get_node("../Player")

var character: AnimatedSprite2D


func spawn():
	character = characters[randi() % characters.size()]
	character.show()


func hit():
	killed.emit()
	queue_free()
	

func walk(movement: Vector2):
	var direction = movement.normalized().snapped(Vector2.ONE)

	velocity = movement * SPEED

	match direction:
		Vector2.UP:
			character.play("up")
		Vector2.DOWN:
			character.play("down")
		Vector2.RIGHT:
			character.play("right")
		Vector2.LEFT:
			character.play("left")
		Vector2.UP + Vector2.LEFT:
			character.play("left")
		Vector2.UP + Vector2.RIGHT:
			character.play("right")
		Vector2.DOWN + Vector2.LEFT:
			character.play("left")
		Vector2.DOWN + Vector2.RIGHT:
			character.play("right")


func _ready():
	spawn()


func _physics_process(_delta):
	var movement = Vector2.ZERO
	movement += position.direction_to(player.position)
	walk(movement)
	move_and_slide()
