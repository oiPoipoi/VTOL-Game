extends StaticBody3D

@onready var hinge: XRToolsInteractableHinge = $XRToolsInteractableHinge

func _ready() -> void:
	# Connect the signal using the Godot 4.x Callable syntax
	hinge.hinge_moved.connect(_on_lever_moved)

func _on_lever_moved(angle: float) -> void:
	# 'angle' returns the current angle of rotation in radians
	# You can track if it passes a certain threshold to trigger gameplay events
	if angle > 0.5:
		print("Lever is pushed forward!")
	elif angle < -0.5:
		print("Lever is pulled back!")
