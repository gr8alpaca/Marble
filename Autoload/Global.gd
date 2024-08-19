@tool
extends Node

const ATT: ControllerAttributes = preload("res://Resources/ControllerAttributes.tres")
const DEBUG: PackedScene = preload("res://Scenes/debug.tscn")

var marble: Marble
var cam: Camera3D
var debug: DebugWindow

func _ready() -> void:
	if Engine.is_editor_hint(): return
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	debug = DEBUG.instantiate()
	add_child(debug, true)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if Input.is_key_pressed(KEY_ESCAPE):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
