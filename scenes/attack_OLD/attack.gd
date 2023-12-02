extends Area2D

enum Type {PRIMARY,SECONDARY}

const PRIMARY_SPEED : int = 500
const SECONDARY_SPEED : int = 800

@export var type : Type;
@export var direction: Vector2

func _ready():
	rotate(direction.angle())
	if (type == Type.PRIMARY):
		$AnimatedSprite2D.play('primary');
		$PrimaryCollision.disabled = false;
	else:
		$AnimatedSprite2D.play('secondary');
		$SecondaryCollision.disabled = false;

func _physics_process(delta):
	var speed = PRIMARY_SPEED if type == Type.PRIMARY else SECONDARY_SPEED;
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.hit()
	queue_free()

func _on_animated_sprite_2d_animation_finished():
	queue_free()
