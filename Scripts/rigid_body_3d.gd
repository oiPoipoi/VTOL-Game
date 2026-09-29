extends RigidBody3D


var grabbing_controller: XRController3D = null

func _physics_process(_delta: float) -> void:
	if grabbing_controller:
		# Check if the player let go of the grab button
		if not grabbing_controller.is_button_pressed("trigger"): 
			grabbing_controller = null
			return
			
		var local_target_pos = to_local(grabbing_controller.global_position)
		
		# Pull the lever toward the controller using physical force
		var torque_strength = 20.0
		apply_torque(Vector3(local_target_pos.z, 0, -local_target_pos.x) * torque_strength)

func _process(_delta: float) -> void:
	# FIX: Using global_rotation_degrees instead of rotation_degrees
	# Check rotation on the chosen axis (e.g., X axis)
	if global_rotation_degrees.x > 35:
		print("Lever is ON")
	elif global_rotation_degrees.x < -35:
		print("Lever is OFF")

func _on_area_3d_body_entered(body: Node3D) -> void:
	# If a controller enters, listen for an initial grab input
	if body is XRController3D and body.is_button_pressed("trigger"):
		grabbing_controller = body
