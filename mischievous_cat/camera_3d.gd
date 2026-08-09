#extends Camera3D
#@export var cat_path: NodePath
#@export var distance: float = 1.5       # distance behind cat
#@export var height: float = 1.0         # camera height above cat
#@export var follow_speed: float = 5.0
#var cat: Node3D
#
#func _ready():
	#cat = get_node(cat_path)
#
#func _process(delta):
	#if not cat:
		#return
	#
	## Position camera behind and above the cat
	#var behind = -cat.global_transform.basis.z.normalized() * distance
	#var target_pos = cat.global_position + behind + Vector3.UP * height
	#
	## Smoothly move camera
	#global_position = global_position.lerp(target_pos, follow_speed * delta)
	#
	## Look at the cat
	#var look_target = cat.global_position + Vector3.UP * 0.5
	#look_at(look_target, Vector3.UP)

extends Camera3D

@export var cat_path: NodePath
@export var distance: float = 2.0       # distance behind cat
@export var height: float = 2.5         # camera height above cat
@export var follow_speed: float = 5.0
@export var mouse_sensitivity: float = 0.003
@export var min_pitch: float = -60.0  # Degrees
@export var max_pitch: float = 60.0   # Degrees

var cat: Node3D
var camera_rotation_y: float = 0.0
var camera_rotation_x: float = -20.0  # Start slightly looking down

func _ready():
	cat = get_node(cat_path)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Initialize camera rotation based on cat's initial rotation
	if cat:
		camera_rotation_y = cat.rotation.y + PI  # Start behind cat

func _input(event):
	# Press ESC to free mouse
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Click to capture mouse again
	if event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Mouse rotation
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotate horizontally (around Y axis)
		camera_rotation_y -= event.relative.x * mouse_sensitivity
		
		# Rotate vertically (around X axis)
		camera_rotation_x -= event.relative.y * mouse_sensitivity
		camera_rotation_x = clamp(camera_rotation_x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

func _process(delta):
	if not cat:
		return
	
	# Calculate the direction vector from cat based on camera rotation
	var horizontal_offset = Vector3(
		sin(camera_rotation_y),
		0,
		cos(camera_rotation_y)
	) * distance
	
	# Apply pitch (vertical angle)
	var vertical_offset = height - (distance * sin(camera_rotation_x))
	var adjusted_distance = distance * cos(camera_rotation_x)
	
	# Recalculate with pitch
	horizontal_offset = Vector3(
		sin(camera_rotation_y),
		0,
		cos(camera_rotation_y)
	) * adjusted_distance
	
	# Calculate target position
	var target_pos = cat.global_position + horizontal_offset + Vector3(0, vertical_offset, 0)
	
	# Smoothly move camera
	global_position = global_position.lerp(target_pos, follow_speed * delta)
	
	# Look at the cat
	var look_target = cat.global_position + Vector3.UP * (height * 0.3)
	look_at(look_target, Vector3.UP)

# Function to get camera forward direction (for cat movement)
func get_camera_forward() -> Vector3:
	var forward = Vector3(
		sin(camera_rotation_y),
		0,
		cos(camera_rotation_y)
	)
	return -forward.normalized()  # Negative because forward is opposite of camera offset

func get_camera_right() -> Vector3:
	var right = Vector3(
		cos(camera_rotation_y),
		0,
		-sin(camera_rotation_y)
	)
	return right.normalized()
