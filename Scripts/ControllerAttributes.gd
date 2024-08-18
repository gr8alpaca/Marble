@icon("res://Art/ClassIcons16x16/camera_edit.png")
@tool
class_name ControllerAttributes extends Resource

signal pivot_distance_changed

##
@export var distance_from_pivot: float = 10.0:
	set(value):
		distance_from_pivot = value
		pivot_distance_changed.emit()

##
@export var pivot_offset := Vector2.ZERO

##
@export_range(-90.0, 90.0) var initial_dive_angle_deg: float = -17.0:
	set(value):
		initial_dive_angle_deg = clampf(value, tilt_lower_limit_deg, tilt_upper_limit_deg)

##
@export_range(-90.0, 90.0) var tilt_upper_limit_deg: float = 60.0

##
@export_range(-90.0, 90.0) var tilt_lower_limit_deg: float = -60.0

##
@export_range(1.0, 1000.0) var tilt_sensitiveness: float = 10.0

##
@export_range(1.0, 1000.0) var horizontal_rotation_sensitiveness: float = 10.0

##
@export_range(0.1, 1) var camera_speed: float = 0.1

@export_custom(0, "", PROPERTY_USAGE_EDITOR)
var pitch: float = 0.0

@export_custom(0, "", PROPERTY_USAGE_EDITOR)
var roll: float = 0.0