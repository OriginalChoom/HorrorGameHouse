extends RigidBody3D

@export var garden_door_key_positions : Array[Node3D]
@onready var random = RandomNumberGenerator.new()

func _ready() -> void:
	var random_position = random.randi_range(0, garden_door_key_positions.size() - 1)
	global_transform.origin = garden_door_key_positions[random_position].global_transform.origin

func garden_door_key():
	var garden_door = get_node("/root/" + get_tree().current_scene.name + "/garden_door")
	garden_door.key_picked_up()
	queue_free()
