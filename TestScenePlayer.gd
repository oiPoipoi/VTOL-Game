extends RigidBody3D

@export_group("Acceleration Profiles")
@export var vertical_accel: float = 20.0       # Upward power multiplier
@export var forward_accel: float = 35.0        # Forward/Backward power multiplier
@export var vertical_ramp: float = 4.0         # Engine spool up speed (higher = snappier)
@export var forward_ramp: float = 6.0

@export_group("Custom Thruster Offsets")
# Position coordinates relative to the Center of Mass (0,0,0)
@export var left_thruster_pos: Vector3 = Vector3(-1.5, 0.0, 0.2)
@export var right_thruster_pos: Vector3 = Vector3(1.5, 0.0, 0.2)
@export var tail_thruster_pos: Vector3 = Vector3(0.0, 0.0, -2.5)

@export_group("Arcade Handling Tuning")
@export var turn_speed: float = 4.0            # How fast the ship rotates
@export var auto_level_strength: float = 5.0   # How aggressively it snaps back to upright

# Internal engine tracking
var _lift_throttle: float = 0.0
var _forward_throttle: float = 0.0

func _ready() -> void:
	# Built-in damping acts like arcade friction. Adjust these in the inspector!
	# Higher linear damp stops slide/drift. Higher angular damp stops spin wobbles.
	linear_damp = 1.5
	angular_damp = 4.0

func _physics_process(delta: float) -> void:
	_handle_inputs(delta)
	_apply_thrust_forces()
	_apply_arcade_steering()

func _handle_inputs(delta: float) -> void:
	# 1. Gather vertical targets
	var target_lift = 0.0
	if Input.is_action_pressed("ui_accept"): # Up (Space)
		target_lift = 1.0
	elif Input.is_action_pressed("ui_down"): # Down (Ctrl)
		target_lift = -0.4
	else:
		# Balanced hover value to fighting gravity roughly (assuming 9.8 m/s²)
		target_lift = 9.8 / vertical_accel

	# 2. Gather forward targets (W/S)
	var target_forward = Input.get_axis("ui_down", "ui_up")

	# 3. Smoothly ramp up the engine power profiles independently
	_lift_throttle = move_toward(_lift_throttle, target_lift, vertical_ramp * delta)
	_forward_throttle = move_toward(_forward_throttle, target_forward, forward_ramp * delta)

func _apply_thrust_forces() -> void:
	var local_up = global_transform.basis.y
	var local_forward = -global_transform.basis.z # Godot forward is -Z

	# Convert requested accelerations to absolute Forces (F = m * a)
	var total_lift_force = _lift_throttle * vertical_accel * mass
	var total_forward_force = _forward_throttle * forward_accel * mass

	# Transform local offset coordinates to world space coordinates
	var world_left_offset = global_transform.basis * left_thruster_pos
	var world_right_offset = global_transform.basis * right_thruster_pos
	var world_tail_offset = global_transform.basis * tail_thruster_pos

	# Split lift evenly across left and right thruster placement points
	var split_lift = local_up * (total_lift_force / 2.0)
	apply_force(split_lift, world_left_offset)
	apply_force(split_lift, world_right_offset)

	# Fire forward propulsion directly from the back tail position
	var forward_vector = local_forward * total_forward_force
	apply_force(forward_vector, world_tail_offset)

func _apply_arcade_steering() -> void:
	var local_forward = -global_transform.basis.z
	var local_up = global_transform.basis.y
	var local_right = global_transform.basis.x

	# 1. Simple, direct torque inputs for Pitch, Roll, and Yaw steering
	var pitch_input = Input.get_axis("ui_up", "ui_down") # Up/Down Arrow
	var roll_input = -Input.get_axis("ui_left", "ui_right") # Left/Right Arrow
	var yaw_input = Input.get_axis("ui_page_down", "ui_page_up") # Q/E or Page keys

	var torque_vector = (local_right * pitch_input) + (local_up * yaw_input) + (local_forward * roll_input)
	apply_torque(torque_vector * turn_speed * mass)

	# 2. Automatic Auto-Level (Snaps ship upright on Z/Roll and X/Pitch when steering stops)
	# Reads the world up direction relative to our current ship tilt
	var current_tilt_roll = local_right.dot(Vector3.UP) 
	var current_tilt_pitch = local_forward.dot(Vector3.UP)

	# If player isn't overriding controls, smoothly torque the ship flat
	if is_zero_approx(roll_input):
		apply_torque(local_forward * -current_tilt_roll * auto_level_strength * mass)
	if is_zero_approx(pitch_input):
		apply_torque(local_right * current_tilt_pitch * auto_level_strength * mass)
