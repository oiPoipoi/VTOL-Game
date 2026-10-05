extends Area3D

@export var max_pitch_deg: float = 30.0
@export var max_roll_deg: float = 30.0

var pitch_output: float = 0.0
var roll_output: float = 0.0

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

func _process(delta: float) -> void:
	if active_hand:
		if Input.is_action_just_pressed("grip") or Input.is_action_pressed("grip"):
			is_grabbed = true
		elif Input.is_action_just_released("grip"):
			is_grabbed = false

	if is_grabbed and active_hand:
		var local_pos = to_local(active_hand.global_position)
		pitch_output = clamp(-local_pos.z * 5.0, -1.0, 1.0)
		roll_output = clamp(local_pos.x * 5.0, -1.0, 1.0)
		
		rotation_degrees.x = pitch_output * max_pitch_deg
		rotation_degrees.z = -roll_output * max_roll_deg
	else:
		pitch_output = move_toward(pitch_output, 0.0, delta * 3.0)
		roll_output = move_toward(roll_output, 0.0, delta * 3.0)
		rotation_degrees.x = pitch_output * max_pitch_deg
		rotation_degrees.z = -roll_output * max_roll_deg
