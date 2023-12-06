extends CanvasLayer

@onready var global = get_node('/root/Global')

func _ready():
	$ScoreValue.text = str(global.score)
	$Restart.grab_focus()

func _on_restart_pressed(): 
	SceneManager.change_scene('res://scenes/menu/menu.tscn', {
		"speed": 5,
		"wait_time": 0,
	})
