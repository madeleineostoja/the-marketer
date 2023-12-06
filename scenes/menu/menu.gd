extends CanvasLayer

var World = preload('res://scenes/world/world.tscn')

func _ready():
	$Start.grab_focus()



func _on_start_pressed():
	SceneManager.change_scene('res://scenes/world/world.tscn', {
		"wait_time": 0.25,
		"pattern": "squares",
		"invert_on_leave": false
	})
