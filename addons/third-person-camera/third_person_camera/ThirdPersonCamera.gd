@icon("res://Art/ClassIcons16x16/camera.png")
@tool
class_name ThirdPersonCamera extends Node3D

const ATT: ControllerAttributes = preload("res://Resources/ControllerAttributes.tres")

@onready var _camera: Camera3D = $Camera
@onready var _camera_rotation_pivot: Node3D = $RotationPivot
@onready var _camera_offset_pivot: Node3D = $RotationPivot/OffsetPivot
@onready var _camera_spring_arm: SpringArm3D = $RotationPivot/OffsetPivot/CameraSpringArm
@onready var _camera_marker: Node3D = $RotationPivot/OffsetPivot/CameraSpringArm/CameraMarker
@onready var _camera_shaker: CameraShaker = $CameraShaker


##
@export_group("Camera Shake")

@export var shake_presets: Array[CameraShakePreset]

# SpringArm3D properties replication
@export_category("SpringArm3D")
@export_flags_3d_render var spring_arm_collision_mask: int = 1:
	set(value):
		spring_arm_collision_mask = value
		_set_when_ready(^"RotationPivot/OffsetPivot/CameraSpringArm", &"collision_mask", value)

@export_range(0.0, 100.0, 0.01, "or_greater", "or_less", "hide_slider", "suffix:m") var spring_arm_margin: float = 0.01:
	set(value):
		spring_arm_margin = value
		_set_when_ready(^"RotationPivot/OffsetPivot/CameraSpringArm", &"margin", value)

# Camera3D properties replication
@export_category("Camera3D")
@export var keep_aspect: Camera3D.KeepAspect = Camera3D.KEEP_HEIGHT
@export_flags_3d_render var cull_mask: int = 1048575
@export var environment: Environment
@export var attributes: CameraAttributes
@export var doppler_tracking: Camera3D.DopplerTracking = Camera3D.DOPPLER_TRACKING_DISABLED
@export var projection: Camera3D.ProjectionType = Camera3D.PROJECTION_PERSPECTIVE
@export_range(1.0, 179.0, 0.1, "suffix:°") var FOV = 75.0
@export var near := 0.05
@export var far := 4000.0


var camera_tilt_deg: float = ATT.pitch
var camera_horizontal_rotation_deg: float = 0.0


func _on_pivot_distance_changed() -> void:
	_set_when_ready(^"RotationPivot/OffsetPivot/CameraSpringArm", &"spring_length", ATT.distance_from_pivot)

func _set_when_ready(node_path: NodePath, property_name: StringName, value: Variant) -> void:
	if not is_node_ready():
		await ready
		get_node(node_path).set(property_name, value)
	else:
		get_node(node_path).set(property_name, value)

func _enter_tree() -> void:
	for sig: Signal in [ATT.pivot_distance_changed, ATT.pitch_changed, ATT.roll_changed]:
		var callable: Callable = Callable(self, "_on_" + sig.get_name())
		if not sig.is_connected(callable):
			sig.connect(callable)

	if not ATT.pivot_distance_changed.is_connected(_on_pivot_distance_changed):
			ATT.pivot_distance_changed.connect(_on_pivot_distance_changed)
	# if not ATT.pitch_changed.is_connected(_on_pitch_changed):
	# 	ATT.pitch_changed.connect(_on_pitch_changed)
	# if not ATT.roll_changed.is_connected(_on_roll_changed):
	# 	ATT.roll_changed.connect(_on_roll_changed)

func _on_pitch_changed() -> void:
	# create_tween().tween_property(_camera_rotation_pivot, "global_rotation_degrees:x", ATT.initial_dive_angle_deg + ATT.pitch, 0.1)
	_camera_rotation_pivot.global_rotation_degrees.x = ATT.initial_dive_angle_deg + ATT.pitch

func _on_roll_changed(roll: float) -> void:
	create_tween().tween_property(_camera, "global_rotation_degrees:z", roll, 0.1)
	# _camera.global_rotation.z = roll

func _ready() -> void:
	_camera.top_level = true

func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	if not ATT:
		return

	_update_camera_properties()

	# if Engine.is_editor_hint():
	_camera_marker.global_position = Vector3(0.,0.,1.).rotated(Vector3(1.,0.,0.), deg_to_rad(ATT.initial_dive_angle_deg + ATT.roll)).rotated(Vector3(0.,1.,0.), deg_to_rad(-camera_horizontal_rotation_deg)) * _camera_spring_arm.spring_length + _camera_spring_arm.global_position
	
	
	_camera.global_position = _camera_marker.global_position

	# tweenCameraToMarker()

	_camera_offset_pivot.global_position = _camera_offset_pivot.get_parent().to_global(Vector3(ATT.pivot_offset.x, ATT.pivot_offset.y, 0.0))
	# _camera_rotation_pivot.global_rotation_degrees.x = ATT.initial_dive_angle_deg + ATT.pitch

	_camera_rotation_pivot.global_position = global_position


	_update_camera_rotation()


func process_tilt_input(tilt_variation: float, delta: float) -> void:
	tilt_variation = tilt_variation * delta * 5 * ATT.tilt_sensitiveness
	camera_tilt_deg = clamp(camera_tilt_deg + tilt_variation, ATT.tilt_lower_limit_deg - ATT.initial_dive_angle_deg, ATT.tilt_upper_limit_deg - ATT.initial_dive_angle_deg)


func _update_camera_pitch() -> void:
	var tilt_final_val: float = ATT.initial_dive_angle_deg + camera_tilt_deg
	create_tween().tween_property(_camera, "global_rotation_degrees:x", tilt_final_val, 0.1)


func _update_camera_rotation() -> void:
	# tween.parallel().tween_property(_camera, "global_rotation_degrees:z", ATT.roll, 0.1)
	var tween: Tween = create_tween()
	tween.tween_property(_camera_rotation_pivot, "global_rotation_degrees:y", camera_horizontal_rotation_deg * -1, 0.1).as_relative()


	camera_horizontal_rotation_deg = 0.0 # reset the value
	var vect_to_offset_pivot: Vector2 = (
		Vector2(_camera_offset_pivot.global_position.x, _camera_offset_pivot.global_position.z)
		-
		Vector2(_camera.global_position.x, _camera.global_position.z)
		).normalized()

	_camera.global_rotation.y = -Vector2(0., - 1.).angle_to(vect_to_offset_pivot.normalized())


func tweenCameraToMarker() -> void:
	_camera.global_position = lerp(_camera.global_position, _camera_marker.global_position, ATT.camera_speed)


func apply_preset_shake(preset_number: int) -> void:
	_camera_shaker.apply_preset_shake(shake_presets[preset_number])


func _update_camera_properties() -> void:
	_camera.keep_aspect = keep_aspect
	_camera.cull_mask = cull_mask
	_camera.doppler_tracking = doppler_tracking
	_camera.projection = projection
	_camera.fov = FOV
	_camera.near = near
	_camera.far = far
	if _camera.environment != environment:
		_camera.environment = environment
	if _camera.attributes != attributes:
		_camera.attributes = attributes


func get_camera() -> Camera3D:
	return $Camera


func get_front_direction() -> Vector3:
	var dir: Vector3 = _camera_offset_pivot.global_position - _camera.global_position
	dir.y = 0.
	dir = dir.normalized()
	return dir


func get_back_direction() -> Vector3:
	return -get_front_direction()

func get_left_direction() -> Vector3:
	return get_front_direction().rotated(Vector3.UP, PI / 2)

func get_right_direction() -> Vector3:
	return get_front_direction().rotated(Vector3.UP, -PI / 2)
