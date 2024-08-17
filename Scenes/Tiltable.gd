class_name Tiltable extends RigidBody3D

@export var tilt_sensitivity: float = 1.0


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if event is InputEventMouseMotion:
			var delta: Vector2 = event.relative / 10.0 * tilt_sensitivity
			var dir: Vector3 = Global.cam.global_position.direction_to(global_position)

			angular_velocity.x += lerpf(0.0, delta.y, dir.dot(Vector3.FORWARD))
			angular_velocity.y += delta.x
			angular_velocity.z += lerpf(0.0, delta.y, dir.dot(Vector3.RIGHT))
			get_viewport().set_input_as_handled()
