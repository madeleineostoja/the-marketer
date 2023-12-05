extends CharacterBody2D

@onready var global = get_node('/root/Global') 

const Utils = preload("res://lib/utils.gd")

enum State { ALIVE, DEAD }
@export var state: State = State.ALIVE


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
	state = State.DEAD
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	character.stop()
	character.hide()
	$Death.show()
	$Death.play()
	$DeathSound.play()
	global.score += 1
	await Utils.timeout(self, 1)
	queue_free()


func walk(movement: Vector2):
	var direction = movement.normalized().snapped(Vector2.ONE)

	if state == State.ALIVE:
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
