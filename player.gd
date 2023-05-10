extends CharacterBody3D


var speed = 7
const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1
@onready var accel = ACCEL_DEFAULT
var gravity = 9.8
var jump = 5

var cam_accel = 40
var mouse_sense = 0.1

var direction = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

@onready var head = $Head
@onready var camera = $Head/CamPivot/SpringArm3D/Camera3D

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

func _process(delta):
	pass
func _physics_process(delta):
	#get keyboard input
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	var h_input = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	#jumping and gravity
	if is_on_floor():
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		gravity_vec = Vector3.UP * jump
	
	#make it move
	movement = velocity.lerp(direction * speed, accel * delta)
	velocity = movement + gravity_vec
	
	move_and_slide()
