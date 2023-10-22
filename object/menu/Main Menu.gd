extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Button1.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_button1_pressed():
	get_tree().change_scene_to_file("res://lvl/test/lvl_test.tscn")


func _on_button2_pressed():
		get_tree().change_scene_to_file("res://lvl/test/lvl_geometry.tscn")
