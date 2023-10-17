extends Node3D

@onready var LABEL = $Bubble/Text/Viewport/Label
@onready var SOUND = $AudioStreamPlayer
@export var TEXT = "NO TEXT ? NO BITCHES ?"

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("up&down")
	LABEL.text = TEXT
