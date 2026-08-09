extends Node3D

@export var detection_radius: float = 2.0
@export var restore_rate: float = 5.0

var area: Area3D
var cat_ref = null

func _ready():
	area = Area3D.new()
	add_child(area)
	
	var collision = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = detection_radius
	collision.shape = sphere
	area.add_child(collision)
	
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _process(delta):
	if cat_ref and cat_ref.has_method("restore_health"):
		cat_ref.restore_health(restore_rate * delta)

func _on_body_entered(body):
	if body.is_in_group("cat"):
		cat_ref = body

func _on_body_exited(body):
	if body.is_in_group("cat"):
		cat_ref = null
