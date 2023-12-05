extends CanvasLayer

@onready var global = get_node('/root/Global')

func _process(_delta):
	$Score.text = str(global.score)
