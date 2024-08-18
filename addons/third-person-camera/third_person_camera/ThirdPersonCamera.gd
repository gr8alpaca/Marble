@icon("./ThirdPersonCameraIcon.svg")
@tool
class_name ThirdPersonCamera extends Node3D


@onready var _camera := $Camera
@onready var _camera_rotation_pivot = $RotationPivot
@onready var _camera_offset_pivot = $RotationPivot/OffsetPivot
@onready var _camera_spring_arm := $RotationPivot/OffsetPivot/CameraSpringArm
@onready var _camera_marker := $RotationPivot/OffsetPivot/CameraSpringArm/CameraMarker
@onready var _camera_shaker := $CameraShaker

## 
@export var att: ControllerAttributes = ControllerAttributes.new():
	set(val):
		if not val:
			val = ControllerAttributes.new()

		att = val
		
		if not att.pivot_distance_changed.is_connected(_on_pivot_distance_changed):
			att.pivot_distance_changed.connect(_on_pivot_distance_changed)

## Unused!
@export_group("mouse")
##
@export var mouse_follow: bool = false

##
@export_range(0.,100.) var mouse_x_sensitiveness: float = 1

##
@export_range(0.,100.) var mouse_y_sensitiveness: float = 1

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


var camera_tilt_deg: float = 0.0
var camera_horizontal_rotation_deg: float = 0.0

func _on_pivot_distance_changed() -> void:
	_set_when_ready(^"RotationPivot/OffsetPivot/CameraSpringArm", &"spring_length", att.distance_from_pivot)

func _set_when_ready(node_path: NodePath, property_name: StringName, value: Variant) -> void:
	if not is_node_ready():
		await ready
		get_node(node_path).set(property_name, value)
	else:
		get_node(node_path).set(property_name, value)

func _ready() -> void:
	_camera.top_level = true

func _physics_process(delta: float) -> void:

	_update_camera_properties()

	if Engine.is_editor_hint():
		if att:
			_camera_marker.global_position = Vector3(0.,0.,1.).rotated(Vector3(1.,0.,0.), deg_to_rad(att.initial_dive_angle_deg)).rotated(Vector3(0.,1.,0.), deg_to_rad(-camera_horizontal_rotation_deg)) * _camera_spring_arm.spring_length + _camera_spring_arm.global_position
		pass

	#_camera.global_position = _camera_marker.global_position
	tweenCameraToMarker()
	_camera_offset_pivot.global_position = _camera_offset_pivot.get_parent().to_global(Vector3(att.pivot_offset.x, att.pivot_offset.y, 0.0))
	_camera_rotation_pivot.global_rotation_degrees.x = att.initial_dive_angle_deg
	_camera_rotation_pivot.global_position = global_position
	
	_update_camera_tilt()
	_update_camera_horizontal_rotation()
	# camera_horizontal_rotation_deg


func process_tilt_input(tilt_variation: float, delta: float) -> void:
	tilt_variation = tilt_variation * delta * 5 * att.tilt_sensitiveness
	camera_tilt_deg = clamp(camera_tilt_deg + tilt_variation, att.tilt_lower_limit_deg - att.initial_dive_angle_deg, att.tilt_upper_limit_deg - att.initial_dive_angle_deg)


func tweenCameraToMarker() -> void:
	_camera.global_position = lerp(_camera.global_position, _camera_marker.global_position, att.camera_speed)

func _update_camera_tilt() -> void:
	var tilt_final_val = clampf(att.initial_dive_angle_deg + camera_tilt_deg, att.tilt_lower_limit_deg, att.tilt_upper_limit_deg)
	var tween = create_tween()
	tween.tween_property(_camera, "global_rotation_degrees:x", tilt_final_val, 0.1)


func _update_camera_horizontal_rotation() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_camera_rotation_pivot, "global_rotation_degrees:y", camera_horizontal_rotation_deg * -1, 0.1).as_relative()
	camera_horizontal_rotation_deg = 0.0 # reset the value
	var vect_to_offset_pivot: Vector2 = (
		Vector2(_camera_offset_pivot.global_position.x, _camera_offset_pivot.global_position.z)
		-
		Vector2(_camera.global_position.x, _camera.global_position.z)
		).normalized()
	_camera.global_rotation.y = -Vector2(0., - 1.).angle_to(vect_to_offset_pivot.normalized())


func apply_preset_shake(preset_number: int) -> void:
	_camera_shaker.apply_preset_shake(shake_presets[preset_number])


func _unhandled_input(event: InputEvent) -> void:
	if mouse_follow and event is InputEventMouseMotion:
		camera_horizontal_rotation_deg += event.relative.x * 0.1 * mouse_x_sensitiveness
		camera_tilt_deg -= event.relative.y * 0.07 * mouse_y_sensitiveness
		return

	pass


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
