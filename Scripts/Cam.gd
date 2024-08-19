@icon("res://Art/ClassIcons16x16/camera.png")
@tool
class_name Cam extends Node3D


@export var att: ControllerAttributes = preload("res://Resources/ControllerAttributes.tres"):
	get: return att if att else preload("res://Resources/ControllerAttributes.tres")
	set(val):
		att = val
		
		att.pivot_distance_changed.connect(update_position)
	

@export var rotate_handler: Node3D
@export var cam: Camera3D


func _enter_tree() -> void:
	pass


func _physics_process(delta: float) -> void:
	pass
	

func _process(delta: float) -> void:
	position = Vector3.ZERO


func update_cam(input: Vector2, state: PhysicsDirectBodyState3D) -> void:
	const TILT_MOVE_TIME_DEGREES_PER_SECOND: float = 360.0


	var rotation_delta: float = TILT_MOVE_TIME_DEGREES_PER_SECOND * state.step

	var target_roll: float = lerpf(0.0, att.roll_limit_deg, input.x)
	var target_pitch: float = lerpf(0.0, att.roll_limit_deg, -input.y)
	
	att.pitch = move_toward(att.pitch, target_pitch, rotation_delta)
	att.roll = move_toward(att.roll, target_roll, rotation_delta)

	update_rotation()
	update_yaw(state)
	update_position()

func update_position() -> void:
	var pre_offset_position: Vector3 = Vector3.FORWARD.rotated(Vector3.RIGHT, PI + cam.global_rotation.x) * att.distance_from_pivot
	cam.position = pre_offset_position + Vector3(0, att.camera_y_offset, 0)


func update_rotation() -> void:
	cam.global_rotation_degrees.x = att.pitch + att.initial_dive_angle_deg
	cam.global_rotation_degrees.z = att.roll

func update_yaw(state: PhysicsDirectBodyState3D) -> void:
	const YAW_SPEED: float = 0.2
	const VELOCITY_CAM_MAX_SPEED: float = 30.0
	const MAX_RADIANS_PER_SECOND: float = PI
	const DEFAULT_VELOCITY_DIR: = Vector2.UP
	var vel_dir: Vector2 = Vector2(state.linear_velocity.x, state.linear_velocity.z, )
	var cam_dir: Vector2 = get_camera_dir()
	var vel_norm: Vector2 = vel_dir.normalized()
	var ang_delta: float = vel_norm.angle() - DEFAULT_VELOCITY_DIR.angle() 
	var t: float =  (vel_dir.length()*state.step)

	var rotated_angle: float = lerp_angle(rotate_handler.global_rotation.y, -ang_delta, t)
	var max_move: float = state.step * MAX_RADIANS_PER_SECOND
	var new_ang: float = move_toward(rotate_handler.global_rotation.y, rotated_angle, max_move)
	rotate_handler.global_rotation.y = new_ang #clampf( rotated_angle, rotated_angle - max_move, rotated_angle + max_move)

	print("Y: %0.3f " % (rotate_handler.global_rotation_degrees.y))

func get_camera_dir() -> Vector2:
	var position_deltas:= global_position - cam.global_position
	return Vector2(position_deltas.x, position_deltas.z).normalized()
	
func get_yaw() -> float:
	return rotate_handler.global_rotation.y
