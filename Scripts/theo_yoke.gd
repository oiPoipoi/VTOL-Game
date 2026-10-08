extends Node3D

@onready var yoke_handle: XRToolsPickable = $XRToolsPickable

# The limits of your virtual physical yoke's movement
@export var max_pitch_distance: float = 0.25 # How far it pushes/pulls (meters)
@export var max_roll_angle: float = 45.0 # Max rotation side-to-side (degrees)

# Output values exported to your VTOL aerodynamics script (-1.0 to 1.0)
var pitch_input: float = 0.0
var roll_input: float = 0.0

var original_handle_transform: Transform3D

func _ready() -> void:
	# Cache the neutral position of the yoke
	original_handle_transform = yoke_handle.transform

func _physics_process(delta: float) -> void:
	if yoke_handle.is_picked_up():
		_process_pilot_input()
	else:
		_return_to_neutral(delta)
	
	print("roll: ", roll_input)
	print("pitch: ", pitch_input)

func _process_pilot_input() -> void:
	# Calculate displacement relative to the neutral base
	var local_pos = yoke_handle.transform.origin - original_handle_transform.origin
	var local_rot = yoke_handle.transform.basis.get_euler()
	
	# 1. PITCH (Z-axis Translation - pushing and pulling the yoke)
	# Clamp physical movement to legal ranges
	local_pos.z = clamp(local_pos.z, -max_pitch_distance, max_pitch_distance)
	local_pos.x = 0 # Prevent the yoke from tearing off left/right
	local_pos.y = 0 # Prevent vertical tearing
	yoke_handle.transform.origin = local_pos
	
	# Normalize pitch (-1.0 pulling back / climbing, 1.0 pushing forward / diving)
	pitch_input = local_pos.z / max_pitch_distance

	# 2. ROLL (Z-axis Rotation - turning the wheel side-to-side)
	var max_roll_rad = deg_to_rad(max_roll_angle)
	var current_roll = clamp(local_rot.z, -max_roll_rad, max_roll_rad)
	
	# Lock other rotational axes so it only rolls smoothly
	yoke_handle.transform.basis = Basis.from_euler(Vector3(0, 0, current_roll))
	
	# Normalize roll (-1.0 left, 1.0 right)
	roll_input = current_roll / max_roll_rad

func _return_to_neutral(delta: float) -> void:
	# Smoothly spring back to center when the player releases the grip button
	yoke_handle.transform.origin = yoke_handle.transform.origin.lerp(original_handle_transform.origin, 10.0 * delta)
	yoke_handle.transform.basis = yoke_handle.transform.basis.slerp(original_handle_transform.basis, 10.0 * delta)
	
	pitch_input = move_toward(pitch_input, 0.0, 5.0 * delta)
	roll_input = move_toward(roll_input, 0.0, 5.0 * delta)
