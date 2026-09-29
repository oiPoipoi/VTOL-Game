extends Node3D

@onready var grab_zone: Area3D = $GrabZone
@onready var yoke_mesh: MeshInstance3D = $YokeMesh

# Limits for your yoke movement (in degrees)
@export var max_pitch_deg: float = 30.0
@export var max_roll_deg: float = 45.0
@export var deadzone: float = 0.05
@export var return_speed: float = 5.0 # Speed it snaps back to center when let go

# Final outputs for your VTOL physics (-1.0 to 1.0)
var pitch_input: float = 0.0
var roll_input: float = 0.0

var active_controller: XRController3D = null
var is_grabbed: bool = false

func _ready() -> void:
	func _on_area_3d_area_entered(area: Area3D) -> void:
		pass # Replace with function body.
		
	func _on_area_3d_area_exited(area: Area3D) -> void:
		pass

func _process(delta: float) -> void:
	if is_grabbed and is_instance_valid(active_controller):
		# Check if the player let go of the grip button
		if not active_controller.get_is_active() or not active_controller.is_button_pressed("grip_click"):
			release_yoke()
			return
		
		track_controller_movement()
	else:
		# Auto-center the yoke when nobody is holding it
		pitch_input = lerp(pitch_input, 0.0, return_speed * delta)
		roll_input = lerp(roll_input, 0.0, return_speed * delta)
	
	# Apply visual rotation to the yoke mesh based on inputs
	yoke_mesh.rotation_degrees.x = pitch_input * max_pitch_deg
	yoke_mesh.rotation_degrees.z = roll_input * max_roll_deg

func track_controller_movement() -> void:
	# Get controller position relative to the Yoke's local space
	var local_controller_pos = to_local(active_controller.global_position)
	
	# Calculate Pitch (Forward / Backward movement along Z-axis)
	# Adjust the '0.3' scale multiplier to match the physical length of your yoke arm
	var raw_pitch = -local_controller_pos.z / 0.3 
	pitch_input = clamp(raw_pitch, -1.0, 1.0)
	if abs(pitch_input) < deadzone: pitch_input = 0.0
	
	# Calculate Roll (Left / Right movement along X-axis)
	var raw_roll = -local_controller_pos.x / 0.3
	roll_input = clamp(raw_roll, -1.0, 1.0)
	if abs(roll_input) < deadzone: roll_input = 0.0

func _on_area_entered(area: Area3D) -> void:
	# Look up the scene tree to see if the overlapping area belongs to an XRController3D
	var parent = area.get_parent()
	if parent is XRController3D and not is_grabbed:
		# If player is holding the grip button while entering or presses it inside
		active_controller = parent
		set_process(true)

func _physics_process(_delta: float) -> void:
	# Check for grab input inside physics loop for responsiveness
	if is_instance_valid(active_controller) and not is_grabbed:
		if active_controller.is_button_pressed("grip_click"):
			is_grabbed = true


func release_yoke() -> void:
	is_grabbed = false
	active_controller = null


func _on_area_3d_area_entered(area: Area3D) -> void:
	pass # Replace with function body.


func _on_area_3d_area_exited(area: Area3D) -> void:
	pass
