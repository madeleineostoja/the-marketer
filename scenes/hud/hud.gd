extends CanvasLayer

@onready var Global = get_node('/root/Global')

func _process(_delta):
	$Score.text = str(Global.score)
