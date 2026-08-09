extends CharacterBody3D

@export var walk_speed: float = 3.0
@export var acceleration: float = 10.0
@export var deceleration: float = 15.0
@export var rotation_speed: float = 10.0
@export var jump_strength: float = 7.0
@export var coyote_time: float = 0.15
@export var walk_anim: String = "four_leg_walk"
@export var idle_anim: String = "Animation"
@export var gravity: float = 15.0

var current_health: float = 50.0
var drain_timer: float = 0.0

@onready var anim_player: AnimationPlayer = $CatModel/AnimationPlayer

var camera: Camera3D
var time_since_grounded: float = 0.0
var joystick: Node = null

func _ready():
	Input.vibrate_handheld()
	camera = get_viewport().get_camera_3d()
	add_to_group("cat")
	update_ui()

	# Find the virtual joystick
	joystick = get_tree().root.find_child("VirtualJoystickPlus", true, false)
	if joystick:
		print("Joystick found!")
	else:
		print("No joystick found - using keyboard only")

func _physics_process(delta):
	# Health drain: 1% every 5 seconds
	drain_timer += delta
	if drain_timer >= 5.0:
		current_health -= 1.0
		current_health = clamp(current_health, 0, 100)
		drain_timer = 0.0
		update_ui()

	# Get input from BOTH keyboard and joystick
	var input_dir = Vector2.ZERO

	# Keyboard input
	var keyboard_input = Vector2.ZERO
	keyboard_input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	keyboard_input.y = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")

	# Joystick input
	var joystick_input = Vector2.ZERO
	if joystick and joystick.has_method("get_value"):
		joystick_input = joystick.get_value()

	# Combine inputs (joystick takes priority if being used)
	if joystick_input.length() > 0.1:
		input_dir = joystick_input
	else:
		input_dir = keyboard_input

	# Ground check
	if is_on_floor():
		time_since_grounded = 0.0
	else:
		time_since_grounded += delta

	# Jump (works with keyboard or you can add a button)
	if Input.is_action_just_pressed("jump") and time_since_grounded < coyote_time:
		velocity.y = jump_strength

	var target_velocity = Vector3.ZERO

	if input_dir.length() > 0.1:
		input_dir = input_dir.normalized()

		# Get camera directions
		var cam_forward = camera.get_camera_forward() if camera else -global_transform.basis.z
		var cam_right = camera.get_camera_right() if camera else global_transform.basis.x

		# Calculate movement relative to camera
		var move_dir = (cam_forward * -input_dir.y + cam_right * input_dir.x).normalized()
		target_velocity = move_dir * walk_speed

		# Rotate cat to face movement direction
		if move_dir.length() > 0.1:
			var target_angle = atan2(move_dir.x, move_dir.z)
			rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)

		# Animation
		if is_on_floor() and anim_player.current_animation != walk_anim:
			anim_player.play(walk_anim)

		if is_on_floor():
			var speed_ratio = velocity.length() / walk_speed
			anim_player.speed_scale = clamp(speed_ratio, 0.5, 1.5)
	else:
		if is_on_floor() and anim_player.current_animation != idle_anim:
			anim_player.play(idle_anim)
			anim_player.speed_scale = 1.0

	# Apply movement
	var accel_rate = acceleration if input_dir.length() > 0.1 else deceleration
	velocity.x = lerp(velocity.x, target_velocity.x, accel_rate * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, accel_rate * delta)

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

func restore_health(amount: float):
	current_health += amount
	current_health = clamp(current_health, 0, 100)
	update_ui()

func update_ui():
	var ui = get_tree().root.get_node_or_null("UI")
	if ui and ui.has_method("update_health"):
		ui.update_health(current_health)

#extends CharacterBody3D
#
#@export var walk_speed: float = 3.0
#@export var acceleration: float = 10.0
#@export var deceleration: float = 15.0
#@export var rotation_speed: float = 10.0
#@export var jump_strength: float = 7.0
#@export var coyote_time: float = 0.15
#@export var walk_anim: String = "four_leg_walk"
#@export var idle_anim: String = "Animation"
#@export var gravity: float = 15.0
#
#var current_health: float = 50.0
#var drain_timer: float = 0.0
#
#@onready var anim_player: AnimationPlayer = $CatModel/AnimationPlayer
#
#var camera: Camera3D
#var time_since_grounded: float = 0.0
#var joystick: Node = null
#
#func _ready():
	#Input.vibrate_handheld()
	#camera = get_viewport().get_camera_3d()
	#add_to_group("cat")
	#update_ui()
	#
	## Find the virtual joystick
	#joystick = get_tree().root.find_child("VirtualJoystickPlus", true, false)
	#if joystick:
		#print("Joystick found!")
	#else:
		#print("No joystick found - using keyboard only")
#
#func _physics_process(delta):
	## Health drain: 1% every 5 seconds
	#drain_timer += delta
	#if drain_timer >= 5.0:
		#current_health -= 1.0
		#current_health = clamp(current_health, 0, 100)
		#drain_timer = 0.0
		#update_ui()
	#
	## Get input from BOTH keyboard and joystick
	#var input_dir = Vector2.ZERO
	#
	## Keyboard input
	#var keyboard_input = Vector2.ZERO
	#keyboard_input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#keyboard_input.y = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	#
	## Joystick input
	#var joystick_input = Vector2.ZERO
	#if joystick and joystick.has_method("get_output"):
		#joystick_input = joystick.get_output()
	#
	## Combine inputs (joystick takes priority if being used)
	#if joystick_input.length() > 0.1:
		#input_dir = joystick_input
	#else:
		#input_dir = keyboard_input
	#
	## Ground check
	#if is_on_floor():
		#time_since_grounded = 0.0
	#else:
		#time_since_grounded += delta
	#
	## Jump (works with keyboard or you can add a button)
	#if Input.is_action_just_pressed("jump") and time_since_grounded < coyote_time:
		#velocity.y = jump_strength
	#
	#var target_velocity = Vector3.ZERO
	#
	#if input_dir.length() > 0.1:
		#input_dir = input_dir.normalized()
		#
		## Get camera directions
		#var cam_forward = camera.get_camera_forward() if camera else -global_transform.basis.z
		#var cam_right = camera.get_camera_right() if camera else global_transform.basis.x
		#
		## Calculate movement relative to camera
		#var move_dir = (cam_forward * -input_dir.y + cam_right * input_dir.x).normalized()
		#target_velocity = move_dir * walk_speed
		#
		## Rotate cat to face movement direction
		#if move_dir.length() > 0.1:
			#var target_angle = atan2(move_dir.x, move_dir.z)
			#rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)
		#
		## Animation
		#if is_on_floor() and anim_player.current_animation != walk_anim:
			#anim_player.play(walk_anim)
		#
		#if is_on_floor():
			#var speed_ratio = velocity.length() / walk_speed
			#anim_player.speed_scale = clamp(speed_ratio, 0.5, 1.5)
	#else:
		#if is_on_floor() and anim_player.current_animation != idle_anim:
			#anim_player.play(idle_anim)
			#anim_player.speed_scale = 1.0
	#
	## Apply movement
	#var accel_rate = acceleration if input_dir.length() > 0.1 else deceleration
	#velocity.x = lerp(velocity.x, target_velocity.x, accel_rate * delta)
	#velocity.z = lerp(velocity.z, target_velocity.z, accel_rate * delta)
	#
	## Gravity
	#if not is_on_floor():
		#velocity.y -= gravity * delta
	#
	#move_and_slide()
#
#func restore_health(amount: float):
	#current_health += amount
	#current_health = clamp(current_health, 0, 100)
	#update_ui()
#
#func update_ui():
	#var ui = get_tree().root.get_node_or_null("UI")
	#if ui and ui.has_method("update_health"):
		#ui.update_health(current_health)
