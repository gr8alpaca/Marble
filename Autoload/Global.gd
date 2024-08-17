extends Node

var germ: Germ
var cam: Camera3D


func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
    if Input.is_key_pressed(KEY_ESCAPE):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE