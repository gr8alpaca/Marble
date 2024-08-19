@icon("res://Art/ClassIcons16x16/character.png")
class_name Marble extends RigidBody3D


@export var ATT: ControllerAttributes = Global.ATT:
	set(val):
		ATT = Global.ATT


@export var input_active: bool = true:
	set(val):
		input_active = val
		set_process_input(val)
		set_process_unhandled_input(val)
		
@export_group("Nodes")

@export var cam: Cam

@export_category("Movement")

@export_range(1.0, 4.0, 0.2, "or_greater", "or_less")
var roll_speed: float = 3.0
# @export var att: ControllerAttributes = ControllerAttributes.new()

const MAX_TILT_DEGREES: float = 20.0
@export_range(1.0, 4.0, 0.2, "or_greater", "or_less")
var tilt_sensitivity: float = 1.0

@export_range(TAU, TAU * 4, PI / 2, "or_greater", "or_less")
var tilt_speed_radians_second: float = TAU * 3

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)

var data: Dictionary = {"Input": Vector2(), "LinVel": 0.0, "Pitch": 0.0, "Roll": 0.0}
signal update_debug

func _ready() -> void:
	Global.marble = self
	Global.cam = cam.cam
	update_debug.connect(get_node("%Debug").create_table("Marble", data))


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	const TILT_MOVE_TIME_DEGREES_PER_SECOND: float = 360.0
	if Engine.is_editor_hint(): return

	var input: Vector2 = Vector2(
		Input.get_action_strength(&"move_right") - Input.get_action_strength(&"move_left"),
        Input.get_action_strength(&"move_down") - Input.get_action_strength(&"move_up"), ) if input_active else Vector2.ZERO
	
	var yaw: float = cam.get_yaw()
	input = input.rotated(-yaw)

	var x_inp: float = input.x * 5.0 * tilt_sensitivity
	var z_inp: float = input.y * 5.0 * tilt_sensitivity

	var x_force: float = x_inp * roll_speed
	var z_force: float = z_inp * roll_speed

	state.apply_central_force(Vector3(x_force, 0, z_force) * roll_speed)


	data["Input"] = input
	data["LinVel"] = linear_velocity
	# data["Pitch"] = ATT.pitch
	# data["Roll"] = ATT.roll

	cam.update_cam(input, state)

	update_debug.emit()
