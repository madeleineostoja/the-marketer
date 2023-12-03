extends CharacterBody2D

@export var state: State = State.IDLE
@export var movement: Vector2 = Vector2.ZERO
@export var direction: Vector2 = Vector2.DOWN

const Utils = preload("res://lib/utils.gd")

enum State { IDLE, WALK, ROLL, PRIMARY_ATTACK, SECONDARY_ATTACK, DEAD }

const WALK_SPEED: int = 450
const ROLL_SPEED: int = 1000

signal died
signal dying
signal attacked(primary: bool, direction: Vector2, position: Vector2)

var input_buffer = [Vector2.ZERO]
var input_buffer_readout = Vector2()


func animate(animation: String):
	match direction:
		Vector2.UP:
			$AnimatedSprite2D.play("%s-up" % animation)
		Vector2.DOWN:
			$AnimatedSprite2D.play("%s-down" % animation)
		Vector2.RIGHT:
			$AnimatedSprite2D.play("%s-right" % animation)
		Vector2.LEFT:
			$AnimatedSprite2D.play("%s-left" % animation)


func update_direction():
	if Input.is_action_just_pressed("right"):
		input_buffer.append(Vector2.RIGHT)
	elif Input.is_action_just_pressed("left"):
		input_buffer.append(Vector2.LEFT)
	elif Input.is_action_just_pressed("up"):
		input_buffer.append(Vector2.UP)
	elif Input.is_action_just_pressed("down"):
		input_buffer.append(Vector2.DOWN)

	if Input.is_action_just_released("right"):
		input_buffer.erase(Vector2.RIGHT)
	elif Input.is_action_just_released("left"):
		input_buffer.erase(Vector2.LEFT)
	elif Input.is_action_just_released("up"):
		input_buffer.erase(Vector2.UP)
	elif Input.is_action_just_released("down"):
		input_buffer.erase(Vector2.DOWN)

	input_buffer_readout = input_buffer[-1]
	movement = input_buffer_readout
	if input_buffer_readout != Vector2.ZERO:
		direction = input_buffer_readout


func idle():
	animate("idle")
	velocity = Vector2.ZERO


func walk():
	animate("walk")
	velocity = movement * WALK_SPEED


func roll():
	animate("roll")
	velocity = direction * ROLL_SPEED
	set_process_input(false)
	await Utils.timeout(self, 0.35)
	set_process_input(true)
	state = State.IDLE


func attack(primary: bool):
	animate("attack")
	attacked.emit(primary, direction, position)
	await Utils.timeout(self, 0.25)
	state = State.IDLE


func die():
	velocity = Vector2.ZERO
	dying.emit()
	$AnimatedSprite2D.play("death")
	$DeathSound.play()
	set_process_input(false)
	await Utils.timeout(self, 2)
	died.emit()


func die_on_impact():
	if state != State.DEAD:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var body = collision.get_collider()
			if !body.is_in_group("enemies") || state == State.ROLL:
				return

			die()
			state = State.DEAD


func _physics_process(_delta):
	var motion: Vector2 = Input.get_vector("left", "right", "up", "down")

	update_direction()
	move_and_slide()
	die_on_impact()

	if motion != Vector2.ZERO && state == State.IDLE:
		state = State.WALK

	match state:
		State.WALK:
			walk()
		State.IDLE:
			idle()


func _unhandled_input(event):
	if state == State.DEAD:
		return

	if event.is_action_pressed("primary_attack"):
		state = State.PRIMARY_ATTACK
		attack(true)

	if event.is_action_pressed("secondary_attack"):
		state = State.SECONDARY_ATTACK
		attack(false)

	if event.is_action_pressed("roll"):
		state = State.ROLL
		roll()
