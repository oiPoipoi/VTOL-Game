extends RigidBody3D
const BULLET = preload("uid://dhlncbg17775")

@export var max_thrust: float = 30.0
@export var throttle_power: float = 20.0
@export var pitch_speed: float = 20.0
@export var roll_speed: float = 5.0
@export var yaw_speed: float = 20.0
@onready var label: Label = $CanvasLayer/Label
@onready var csg_box_3d: MeshInstance3D = $MeshInstance3D

var gas: float = 10000
var electric: float = 10000
var engines_on: bool = false

var needs_respawn: bool = false
var spawn_transform: Transform3D

# Damage Vars
var chassis_damage: int = 100
var rWingDamage: int = 95
var lWingDamage: int = 95

func _ready() -> void:
	spawn_transform = global_transform

func _physics_process(delta: float) -> void:
	var thrust_input = Input.get_action_strength("thrust_up") - Input.get_action_strength("thrust_down")
	var throttle_input = Input.get_action_strength("throttle_forward") - Input.get_action_strength("throttle_back")
	
	var pitch_input = Input.get_action_strength("pitch_down") - Input.get_action_strength("pitch_up")
	var roll_input = Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right")
	var yaw_input = Input.get_action_strength("yaw_left") - Input.get_action_strength("yaw_right")
	
	var up_force = basis.y * thrust_input * max_thrust
	var forward_force = -basis.z * throttle_input * throttle_power
	
	if engines_on && gas != 0 && electric != 0:
		apply_central_force(up_force + forward_force)
		electric -= -abs(thrust_input) + abs(throttle_input) + 1.5 / 100
		gas -= abs(thrust_input) + abs(throttle_input) + 1.5 / 100
	
	var torque = Vector3.ZERO
	torque.x = pitch_input * pitch_speed
	torque.z = roll_input * roll_speed
	torque.y = yaw_input * yaw_speed
	
	if engines_on && gas != 0 && electric != 0:
		apply_torque(basis * torque)
		
	if gas == 0 && engines_on == true:
		electric -= 5
	
	if chassis_damage == 0:
		needs_respawn = true
	
	if Input.is_action_just_pressed("fire"):
		var bullet = BULLET.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.position = global_position
		bullet.rotation = global_rotation
	
	if Input.is_action_just_pressed("restart"):
		needs_respawn = true
	
	if Input.is_action_just_pressed("engines"):
		if engines_on == false:
			engines_on = true
		else:
			engines_on = false
			
	if electric >= 10000:
		electric = 10000
	if electric <= 0:
		electric = 0
	if gas <= 0:
		gas = 0
	if chassis_damage <= 0:
		chassis_damage = 0
	label.text = "Gas: " +str(gas) + "\nEnegry: " +str(electric) + "\nChassis Damage: " + str(chassis_damage)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("ground"):
		needs_respawn = true

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if needs_respawn:
		state.transform = spawn_transform
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		engines_on = false
		gas = 10000
		electric = 10000
		chassis_damage = 100
		needs_respawn = false

#	var chassis_rand = randi_range(2,6)
#	chassis_damage -= chassis_rand

func _on_chassis_damage_area_entered(area: Area3D) -> void:
	pass # Replace with function body.
