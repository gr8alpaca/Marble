class_name TiltPivot extends Node3D

const MAX_ANGLE: float = PI / 8

@export var tilt_sensitivity: float = 1.0
@export var tilt_speed_radians_second: float = PI


@export var active: bool = true:
	set(val):
		active = val
		set_process(val)
	
@onready var stage: PhysicsBody3D = %Stage

func _ready() -> void:

	pass


var print_timer: float = 1.0
func _physics_process(delta: float) -> void:
	print_timer -= delta

	var input_dir: Vector2 = Vector2.ZERO

	if active:
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	
	if input_dir:
		var cam_dir: Vector3 = Global.cam.global_position.direction_to(Global.marble.global_position)
		var y_plane := Vector2(cam_dir.x, cam_dir.z)
		var rotated_input: Vector2 = input_dir.rotated(y_plane.angle())
		var rotated_rot := Vector2(rotated_input.dot(Vector2.UP), rotated_input.dot(Vector2.RIGHT))

		stage.rotation = Vector3(
			move_toward(rotation.x, clampf(rotated_rot.y, -MAX_ANGLE, MAX_ANGLE), tilt_speed_radians_second * delta),
			0.0,
			move_toward(rotation.z, clampf(-rotated_rot.x, -MAX_ANGLE, MAX_ANGLE), tilt_speed_radians_second * delta), )
		print("rotated amounds: %s" % rotated_rot)

	else:
		stage.rotation = rotation.move_toward(Vector3.ZERO, tilt_speed_radians_second * delta)
