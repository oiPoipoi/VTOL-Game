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
		if Input.is_action_just_pressed("grip") or Input.is_action_pressed("grip"):
			is_grabbed = true
		elif Input.is_action_just_released("grip"):
			is_grabbed = false

	if is_grabbed and active_hand:
		var local_pos = to_local(active_hand.global_position)
		lever_position = clamp((-local_pos.z + 0.2) * 2.5, 0.0, 1.0)
		rotation_degrees.x = -lever_position * max_angle_deg
