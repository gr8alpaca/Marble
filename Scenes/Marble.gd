class_name Marble extends RigidBody3D

@export var tpc: ThirdPersonCamera
@export var cam: Camera3D

@export var input_active: bool = true:
    set(val):
        input_active = val
        set_process_input(val)
        set_process_unhandled_input(val)


@export_category("Movement")

@export var att: ControllerAttributes = ControllerAttributes.new()

# @export_range(6.0, 14.0, 0.1, "or_greater", "or_less")
# var gravity_magnitude: float = 9.8

# @export_range(1.0, 10.0, 0.5, "or_greater", "or_less")
# var directional_acceleration: float = 4.0


const MAX_TILT_DEGREES: float = 20.0
@export_range(1.0, 4.0, 0.2, "or_greater", "or_less")
var tilt_sensitivity: float = 1.0

@export_range(1.0, 4.0, 0.2, "or_greater", "or_less")
var tilt_speed_radians_second: float = PI

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)


func _init() -> void:
    Global.marble = self
    Global.cam = cam


func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint(): return

    var gravity_vector: Vector3 = Vector3.DOWN * gravity

    var input: Vector2 = Vector2(
        Input.get_action_strength(&"move_right") - Input.get_action_strength(&"move_left"),
        Input.get_action_strength(&"move_down") - Input.get_action_strength(&"move_up"), )
    
    var forward_tilt_degrees: float = 0.0
    var horizontal_tilt_degrees: float
    
    if input_active:
        var forward_tilt_delta: float = input.y * delta * 5.0 * tilt_sensitivity
        forward_tilt_degrees = clamp(tpc.camera_tilt_deg + forward_tilt_delta, tpc.tilt_lower_limit_deg - tpc.initial_dive_angle_deg, tpc.tilt_upper_limit_deg - tpc.initial_dive_angle_deg)


    else:
        pass
    
    tpc.camera_tilt_deg = forward_tilt_degrees
    apply_central_force(gravity_vector)
    # var acc: Vector3 = Vector3(input.x * directional_acceleration * delta, 0, input.y * directional_acceleration * delta, )
    
    
    process_swivel(Vector2(linear_velocity.x, linear_velocity.z), delta)




func process_swivel(velocity: Vector2, delta: float) -> void:
    # marble.linear_velocity
	# _camera.position.angle
	# camera_horizontal_rotation_deg
    pass

# func _get_property_list() -> Array:
#     var result: Array = []

#     if tpc:
#         for property: Dictionary in tpc.get_property_list():
#             match property["name"]:
#                 "tilt_lower_limit_deg"

#     return []
