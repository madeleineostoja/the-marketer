extends CanvasLayer

@onready var global = get_node('/root/Global')

func _ready():
	$Score.text = str(global.score)
	$Restart.grab_focus()

func _on_restart_pressed():
	get_tree().change_scene_to_file('res://scenes/title/title.tscn')
