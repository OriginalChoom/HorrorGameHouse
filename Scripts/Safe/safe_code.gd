extends RigidBody3D

@export var paper_code_positions : Array[Node3D]
@onready var random = RandomNumberGenerator.new()

func _ready() -> void:
	var random_position = random.randi_range(0, paper_code_positions.size() - 1)
	global_transform.origin = paper_code_positions[random_position].global_transform.origin
