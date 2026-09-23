extends CharacterBody3D

@onready var head = $head

#camera
@onready var head_x_rotation: Node3D = $head/cameraSmooth/head_x_rotation
@onready var player_camera: Camera3D = $head/cameraSmooth/head_x_rotation/player_camera
@onready var camera_smooth: Node3D = $head/cameraSmooth


@onready var flashlight = $flashlight
@onready var flashlight_light = $flashlight/flashlight_mesh/flashlight_light

@onready var flashlight_mesh = $flashlight/flashlight_mesh

@onready var animation_tree: AnimationTree = $head/cameraSmooth/head_x_rotation/player_camera/AnimationTree

@onready var color_rect = $Control/ColorRect

@onready var player_collison: CollisionShape3D = $player_collison

@onready var stairs_ahead_ray_cast_3d: RayCast3D = $StairsAheadRayCast3D
@onready var stairs_below_ray_cast_3d: RayCast3D = $StairsBelowRayCast3D


var SPEED = 5.0
const FLASHLIGHT_FOLLOW_SPEED = 15.0
const ANIM_SMOOTHING_SPEED = 8.0 

@export var sensitivity = -0.1 
var anim_blend = 0.0

var crouching = false

const MAX_STEP_HEIGHT = 0.2
var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor = -INF

#mouse movement
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	color_rect.material.set("shader_parameter/effect_amount", 1.0)


func _input(event):
	#camera rotation
	if event is InputEventMouseMotion:
		head.rotation_degrees.y += sensitivity * event.relative.x
		head_x_rotation.rotation_degrees.x += sensitivity * event.relative.y
		head_x_rotation.rotation_degrees.x = clamp(head_x_rotation.rotation_degrees.x, -89, 89)


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta):
	make_flashligh_follow(delta)
	
	if Input.is_action_just_pressed("crouch"):
		crouching = !crouching
	crouching_speed()

func _physics_process(delta):
	if is_on_floor(): _last_frame_was_on_floor = Engine.get_physics_frames() 
	
	# Add the gravity.
	if not is_on_floor() or not _snapped_to_stairs_last_frame:
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
	
	anim_blend = lerp(anim_blend, direction.length(), delta * ANIM_SMOOTHING_SPEED)
	animation_tree.set("parameters/blend_position", anim_blend)
	
	#crouching
	if crouching and player_collison.shape.height > 0.5:
		var crouch_height = lerp(player_collison.shape.height, 0.5, 0.1)
		player_collison.shape.height = crouch_height
	if !crouching and player_collison.shape.height < 1.7:
		var crouch_height = lerp(player_collison.shape.height, 1.7, 0.1)
		player_collison.shape.height = crouch_height
	
	if not _snap_up_stairs_check(delta):
		move_and_slide()
		_snap_down_the_stairs_check()
		
	_slide_camera_smooth_back_to_origin(delta)
	
	
func make_flashligh_follow(delta):
	flashlight.rotation.y = lerp(flashlight.rotation.y, head.rotation.y, delta * FLASHLIGHT_FOLLOW_SPEED)
	flashlight.rotation.x = lerp(flashlight.rotation.x, head_x_rotation.rotation.x, delta * FLASHLIGHT_FOLLOW_SPEED)

func crouching_speed():
	if crouching and SPEED != 2.5:
		SPEED = 2.5
	elif !crouching and SPEED != 5.0:
		SPEED = 5.0
		
#camera smoothing
var _saved_camera_global_pos = null
func _save_camera_pos_for_smoothing():
	if _saved_camera_global_pos == null:
		_saved_camera_global_pos = camera_smooth.global_position
		
func _slide_camera_smooth_back_to_origin(delta):
	if _saved_camera_global_pos == null : return
	camera_smooth.global_position.y = _saved_camera_global_pos.y
	camera_smooth.position.y = clampf(camera_smooth.position.y, -0.7, 0.7)
	var move_ammount = max(self.velocity.length() * delta, SPEED/2 * delta)
	camera_smooth.position.y = move_toward(camera_smooth.position.y, 0.0, move_ammount)
	_saved_camera_global_pos = camera_smooth.global_position
	if camera_smooth.position.y == 0:
		_saved_camera_global_pos = null
		
		
#stairs movement
func is_surface_to_steep(normal : Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle
	
func _run_body_test_motion(from : Transform3D, motion : Vector3, result = null) -> bool:
	if not result: result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)
	
func _snap_down_the_stairs_check() -> void:
	var did_snap := false
	var floor_below : bool = stairs_below_ray_cast_3d.is_colliding() and not is_surface_to_steep(stairs_below_ray_cast_3d.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if _run_body_test_motion(self.global_transform, Vector3(0,-MAX_STEP_HEIGHT,0), body_test_result):
			_save_camera_pos_for_smoothing()
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap
	
func _snap_up_stairs_check(delta) -> bool:
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false
	var expected_move_motion = self.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT *2, 0))
	var down_check_result = PhysicsTestMotionResult3D.new()
	if (_run_body_test_motion(step_pos_with_clearance, Vector3(0, -MAX_STEP_HEIGHT*2, 0), down_check_result) and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_collision_point() - self.global_position).y > MAX_STEP_HEIGHT: return false
		stairs_ahead_ray_cast_3d.global_position = down_check_result.get_collision_point() + Vector3(0, MAX_STEP_HEIGHT, 0) + expected_move_motion.normalized() * 0.1
		stairs_ahead_ray_cast_3d.force_raycast_update()
		if stairs_ahead_ray_cast_3d.is_colliding() and not is_surface_to_steep(stairs_ahead_ray_cast_3d.get_collision_normal()):
			_save_camera_pos_for_smoothing()
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false
	
	
	
	
