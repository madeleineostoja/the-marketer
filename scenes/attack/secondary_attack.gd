extends Attack


func _on_body_entered(body):
	Attack.hit_enemy(body)
