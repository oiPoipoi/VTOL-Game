extends Node3D

var xr_interface: XRInterface

func _ready() -> void:
	xr_interface = XRServer.find_interface("OpenXR")

	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized")

		# Let OpenXR control frame timing
		DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_DISABLED
		)

		# Send the game view to the headset
		get_viewport().use_xr = true
	else:
		print("OpenXR could not be initialized")
		print("Check that your headset and OpenXR runtime are active.")
