@icon("res://Art/ClassIcons16x16/camera_edit.png")
@tool
class_name ControllerAttributes extends Resource



signal pivot_distance_changed
signal pitch_changed(new_pitch: float)
signal roll_changed(new_roll: float)

##
@export var distance_from_pivot: float = 3.0:
	set(value):
		distance_from_pivot = value
		pivot_distance_changed.emit()
		emit_changed()

@export var camera_y_offset: float = 0.5

##
@export var pivot_offset := Vector2.ZERO:
	set(val):
		pivot_offset = val
		emit_changed()

##
@export_range(-90.0, 90.0) var initial_dive_angle_deg: float = -17.0:
	set(value):
		initial_dive_angle_deg = clampf(value, tilt_lower_limit_deg, tilt_upper_limit_deg);
		pitch_changed.emit()
		emit_changed()
##
@export_range(-90.0, 90.0) var tilt_upper_limit_deg: float = -2.0
##
@export_range(-90.0, 90.0) var tilt_lower_limit_deg: float = -32.0

##
@export_range(-90.0, 90.0) var roll_limit_deg: float = 15.0


##
@export_range(1.0, 1000.0) var tilt_sensitiveness: float = 10.0

##
@export_range(1.0, 1000.0) var horizontal_rotation_sensitiveness: float = 10.0

##
@export_range(0.1, 1) var camera_speed: float = 0.1

## Additional pitch to add to [initial_dive_angle_deg]
@export_custom(0, "", PROPERTY_USAGE_EDITOR) var pitch: float = 0.0:
	set(val):
		pitch = clampf(val, tilt_lower_limit_deg - initial_dive_angle_deg, tilt_upper_limit_deg - initial_dive_angle_deg)
		pitch_changed.emit()
		emit_changed()

##
@export_custom(0, "", PROPERTY_USAGE_EDITOR) var roll: float = 0.0:
	set(val):
		roll = clampf(val, -roll_limit_deg, roll_limit_deg)
		roll_changed.emit(roll)
		emit_changed()





