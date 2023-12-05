extends CanvasLayer

var World = preload ('res://scenes/world/world.tscn')


func _ready():
	$Start.grab_focus()



func _on_start_pressed():
	get_tree().change_scene_to_file('res://scenes/world/world.tscn')
