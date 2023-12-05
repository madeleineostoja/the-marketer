extends CanvasLayer

@onready var global = get_node('/root/Global')

func _ready():
	$Score.text = str(global.score)
	$Restart.grab_focus()

func _on_restart_pressed():
	pass
