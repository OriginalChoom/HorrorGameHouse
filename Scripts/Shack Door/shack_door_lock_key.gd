extends Node3D

func shack_door_key_pickup():
	var shack_door = get_node("/root/" + get_tree().current_scene.name + "/shack_door")
	shack_door.shack_key_picked_up()
	queue_free()
