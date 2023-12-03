static func timeout(node: Node2D, duration: float):
	await node.get_tree().create_timer(duration).timeout
