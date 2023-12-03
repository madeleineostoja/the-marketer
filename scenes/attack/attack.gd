extends Area2D
class_name Attack

@export var animation: AnimatedSprite2D
@export var speed: int
@export var direction: Vector2


func _ready():
	if animation:
		animation.play()
	await get_tree().create_timer(0.5).timeout
	queue_free()


func _physics_process(delta):
	position += direction * speed * delta


static func hit_enemy(body: Node2D):
	if body.is_in_group("enemies"):
		body.hit()
