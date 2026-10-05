extends Area3D

@export var max_angle_deg: float = 40.0

var lever_position: float = 0.0

var active_hand: Node3D = null
var is_grabbed: bool = false


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area3D) -> void:
	if not is_grabbed:
		active_hand = area

func _on_area_exited(area: Area3D) -> void:
	if area == active_hand and not is_grabbed:
		active_hand = null

func _process(_delta: float) -> void:
	if active_hand:
		# Get the parent XRController3D node (LeftHand or RightHand)
		var controller = active_hand.get_parent() as XRController3D
		if controller:
			# Check native Quest 3 grip squeeze value (0.0 to 1.0)
			var grip_val = controller.get_float("grip")
			if grip_val > 0.3 or controller.is_button_pressed("grip_click"):
				is_grabbed = true
			else:
				is_grabbed = false

	if is_grabbed and active_hand:
		var local_pos = to_local(active_hand.global_position)
		lever_position = clamp((-local_pos.z + 0.2) * 2.5, 0.0, 1.0)
		rotation_degrees.x = -lever_position * max_angle_deg
	
