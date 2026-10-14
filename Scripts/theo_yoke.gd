@export var pitch: float = 0.0
@export var roll: float = 0.0

@export var pitch_max: float = 30.0
@export var roll_max: float = 30.0


@export var pitch_min: float = -30.0
@export var roll_min: float = -30.0

var is_grabbed: bool = false



func _on_area_entered(area: Area3D) -> void:
	pass # Replace with function body.
