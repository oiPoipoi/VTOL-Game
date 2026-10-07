extends RigidBody3D
const BULLET = preload("uid://dhlncbg17775")

@export var max_thrust: float = 30.0
@export var throttle_power: float = 20.0
@export var pitch_speed: float = 20.0
@export var roll_speed: float = 5.0
@export var yaw_speed: float = 20.0

# Area3D Control Nodes
@onready var virtual_yoke: Area3D = $Yoke
@onready var forward_throttle_lever: Area3D = $"Forward Throttle"
@onready var up_thrust_lever: Area3D = $"Upwards Throttle"
@onready var engine_switch: Area3D = $EnginesToggle

@onready var label: Label = $CanvasLayer/Label
@onready var csg_box_3d: MeshInstance3D = $MeshInstance3D

var gas: float = 10000.0
var electric: float = 10000.0
var engines_on: bool = false

var needs_respawn: bool = false
var spawn_transform: Transform3D
var spawn_grace_period: float = 1.0 # Prevents frame 1 spawn teleports

# Damage Vars
var chassis_damage: int = 100
var rWingDamage: int = 95
var lWingDamage: int = 95

func _ready() -> void:
	spawn_transform = global_transform

func _physics_process(delta: float) -> void:
	if spawn_grace_period > 0.0:
		spawn_grace_period -= delta

	if $EnginesToggle.lever_position > 0.45:
		engines_on = true
	else:
		engines_on = false
	
	var thrust_input: float = 0.0
	var throttle_input: float = 0.0
	var pitch_input: float = 0.0
	var roll_input: float = 0.0
	var yaw_input: float = 0.0 
	
	if up_thrust_lever:
		thrust_input = up_thrust_lever.lever_position
		
	if forward_throttle_lever:
		throttle_input = forward_throttle_lever.lever_position
		
	if virtual_yoke:
		pitch_input = virtual_yoke.pitch_output
		roll_input = virtual_yoke.roll_output

	yaw_input = Input.get_action_strength("yaw_left") - Input.get_action_strength("yaw_right")
	
	var up_force = basis.y * thrust_input * max_thrust
	var forward_force = -basis.z * throttle_input * throttle_power
	
	if engines_on and gas > 0 and electric > 0:
		apply_central_force(up_force + forward_force)
		electric -= (abs(thrust_input) + abs(throttle_input) + 0.015)
		gas -= (abs(thrust_input) + abs(throttle_input) + 0.015)
	
	var torque = Vector3.ZERO
	torque.x = pitch_input * pitch_speed
	torque.z = roll_input * roll_speed
	torque.y = yaw_input * yaw_speed
	
	if engines_on and gas > 0 and electric > 0:
		apply_torque(basis * torque)
		
	if gas <= 0 and engines_on:
		electric -= 5.0
	
	if chassis_damage <= 0:
		needs_respawn = true
	
	if Input.is_action_just_pressed("fire"):
		var bullet = BULLET.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.position = global_position
		bullet.rotation = global_rotation
	
	# Clamping values
	electric = clamp(electric, 0.0, 10000.0)
	gas = clamp(gas, 0.0, 10000.0)
	chassis_damage = max(chassis_damage, 0)
	
	if label:
		label.text = "Gas: " + str(snapped(gas, 0.1)) + "\nEnergy: " + str(snapped(electric, 0.1)) + "\nChassis: " + str(chassis_damage) + "\nRight Wing: " + str(rWingDamage) + "\nLeft Wing: " + str(lWingDamage)

func _on_body_entered(body: Node) -> void:
	# Ignore ground collisions during initial spawn grace period
	if spawn_grace_period <= 0.0 and body.is_in_group("ground"):
		needs_respawn = true

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if needs_respawn:
		state.transform = spawn_transform
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		gas = 10000.0
		electric = 10000.0
		chassis_damage = 100
		rWingDamage = 95
		lWingDamage = 95
		$EnginesToggle.lever_position = 0.0
		$"Upwards Throttle".lever_position = 0.0
		$"Forward Throttle".lever_position = 0.0
		needs_respawn = false
		spawn_grace_period = 1.0

func _on_chassis_damage_area_entered(area: Area3D) -> void:
	if area.is_in_group("bullet"):
		chassis_damage -= randi_range(2, 6)

func _on_r_wing_damage_area_entered(area: Area3D) -> void:
	if area.is_in_group("bullet"):
		rWingDamage -= randi_range(2, 6)

func _on_l_wing_damage_area_entered(area: Area3D) -> void:
	if area.is_in_group("bullet"):
		lWingDamage -= randi_range(2, 6)
