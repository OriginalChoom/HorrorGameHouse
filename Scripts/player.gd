extends CharacterBody3D

@onready var head = $head
@onready var head_x_rotation = $head/head_x_rotation

@onready var flashlight = $flashlight
@onready var flashlight_light = $flashlight/flashlight_mesh/flashlight_light

@onready var flashlight_mesh = $flashlight/flashlight_mesh

@onready var animation_tree = $head/head_x_rotation/player_camera/AnimationTree


const SPEED = 5.0
const FLASHLIGHT_FOLLOW_SPEED = 15.0
const ANIM_SMOOTHING_SPEED = 8.0 

var sensitivity = -0.1
var anim_blend = 0.0

#mouse movement
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event):
	#camera rotation
	if event is InputEventMouseMotion:
		head.rotation_degrees.y += sensitivity * event.relative.x
		head_x_rotation.rotation_degrees.x += sensitivity * event.relative.y
		head_x_rotation.rotation_degrees.x = clamp(head_x_rotation.rotation_degrees.x, -89, 89)
		
	#flashlight follow camera
	if event is InputEventKey:
		if Input.is_action_just_pressed("flash"):
			flashlight_light.visible = !flashlight_light.visible


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta):
	make_flashligh_follow(delta)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	var head_basis = head.get_transform().basis
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("up"):
		direction -= head_basis.z
	elif Input.is_action_pressed("down"):
		direction += head_basis.z
	if Input.is_action_pressed("left"):
		direction -= head_basis.x
	elif Input.is_action_pressed("right"):
		direction += head_basis.x
		
	direction = direction.normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	move_and_slide()
	
	anim_blend = lerp(anim_blend, direction.length(), delta * ANIM_SMOOTHING_SPEED)
	animation_tree.set("parameters/blend_position", anim_blend)
	
func make_flashligh_follow(delta):
	flashlight.rotation.y = lerp(flashlight.rotation.y, head.rotation.y, delta * FLASHLIGHT_FOLLOW_SPEED)
	flashlight.rotation.x = lerp(flashlight.rotation.x, head_x_rotation.rotation.x, delta * FLASHLIGHT_FOLLOW_SPEED)



