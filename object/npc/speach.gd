extends Node3D

@onready var LABEL = $Bubble/Text/Viewport/Label
@onready var SOUND = $AudioStreamPlayer
@onready var TIMER = $Timer
@export var TEXT = ""
@export var VOICE = ""
@export var VOICE_SPEED = 0.1
@export var EVENT_KEY = ""

var CURRENT_TEXT = ""
var VOICE_DIC = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("up&down")
	LABEL.text = ""
	CURRENT_TEXT = TEXT
	TIMER.wait_time = VOICE_SPEED
	for letter in "abcdefghijklmnopqrstuvwxyz":
		VOICE_DIC[letter] = load(VOICE + letter + ".wav")
	
func _process(delta):
	if Input.is_action_just_pressed(EVENT_KEY):
		LABEL.text = ""
		CURRENT_TEXT = TEXT
		TIMER.start()
	if len(CURRENT_TEXT) == 0:
		TIMER.stop()
		

func _on_timer_timeout():
	if len(CURRENT_TEXT) > 0:
		LABEL.text += CURRENT_TEXT[0]
		SOUND.stop()
		if CURRENT_TEXT[0] >= "a" and CURRENT_TEXT[0] <= "z":
			SOUND.set_stream(VOICE_DIC[CURRENT_TEXT[0]])
			SOUND.play()
		CURRENT_TEXT = CURRENT_TEXT.substr(1, -1)
