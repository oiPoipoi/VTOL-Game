extends Area3D

var is_on: bool = false
var active_hand: Node3D = null
var cooldown: float = 0.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area3D) -> void:
	active_hand = area

func _on_area_exited(area: Area3D) -> void:
	if area == active_hand:
		active_hand = null

func _process(delta: float) -> void:
	if cooldown > 0.0:
		cooldown -= delta

	if active_hand and cooldown <= 0.0:
		if Input.is_action_just_pressed("trigger") or Input.is_action_just_pressed("grip"):
			is_on = not is_on
			cooldown = 0.4
			rotation_degrees.x = 35.0 if is_on else -35.0
