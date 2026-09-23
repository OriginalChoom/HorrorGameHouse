extends RigidBody3D

@export var shack_door_key_position : Array[Node3D]
@onready var random = RandomNumberGenerator.new()

func _ready() -> void:
	var random_position = random.randi_range(0, shack_door_key_position.size() - 1)
	global_transform.origin = shack_door_key_position[random_position].global_transform.origin

func shack_door_key_pickup():
	var shack_door = get_node("/root/" + get_tree().current_scene.name + "/shack_door")
	shack_door.shack_key_picked_up()
	queue_free()
