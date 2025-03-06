extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	set_visible(OS.get_name() in ["Android", "iOS"])
