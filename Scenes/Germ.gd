class_name Germ extends RigidBody3D

@export var cam: Camera3D

func _ready() -> void:
    Global.germ = self
    Global.cam = cam