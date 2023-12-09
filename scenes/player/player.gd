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

var movement_buffer = [Vector2.ZERO]
var movement_buffer_readout = Vector2()


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


func handle_movement():
	if Input.is_action_just_pressed("right"):
		movement_buffer.append(Vector2.RIGHT)
	elif Input.is_action_just_pressed("left"):
		movement_buffer.append(Vector2.LEFT)
	elif Input.is_action_just_pressed("up"):
		movement_buffer.append(Vector2.UP)
	elif Input.is_action_just_pressed("down"):
		movement_buffer.append(Vector2.DOWN)

	if Input.is_action_just_released("right"):
		movement_buffer.erase(Vector2.RIGHT)
	elif Input.is_action_just_released("left"):
		movement_buffer.erase(Vector2.LEFT)
	elif Input.is_action_just_released("up"):
		movement_buffer.erase(Vector2.UP)
	elif Input.is_action_just_released("down"):
		movement_buffer.erase(Vector2.DOWN)

	movement_buffer_readout = movement_buffer[-1]
	movement = movement_buffer_readout
	if movement_buffer_readout != Vector2.ZERO:
		direction = movement_buffer_readout


func idle():
	animate("idle")
	velocity = Vector2.ZERO


func walk():
	animate("walk")
	velocity = movement * WALK_SPEED


func roll():
	animate("roll")
	$RollSound.play()
	velocity = direction * ROLL_SPEED
	set_process_input(false)
	await Utils.timeout(self, 0.35)
	set_process_input(true)
	state = State.IDLE


func attack(primary: bool):
	if $AttackCooldown.time_left > 0:
		state = State.IDLE
		return

	$AttackCooldown.start()
	animate("attack")
	attacked.emit(primary, direction, position)
	await Utils.timeout(self, 0.25)
	state = State.IDLE


func die():
	state = State.DEAD
	velocity = Vector2.ZERO
	set_process_input(false)
	dying.emit()
	$AnimatedSprite2D.play("death")
	$DeathSound.play()
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


func limit_camera():
	var map: TileMap = get_node("../Map")
	var map_rect: Rect2i = map.get_used_rect()
	var map_size: Vector2i = map.tile_set.tile_size * Vector2i(map.scale)
	print(map.transform.get_origin())

	$Camera.limit_top = map_rect.position.y * map_size.y
	$Camera.limit_left = map_rect.position.x * map_size.x
	$Camera.limit_right = map_rect.end.x * map_size.x
	$Camera.limit_bottom = map_rect.end.y * map_size.y


# func _ready():
# 	limit_camera()


func _physics_process(_delta):
	var motion: Vector2 = Input.get_vector("left", "right", "up", "down")

	die_on_impact()
	handle_movement()
	move_and_slide()

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
