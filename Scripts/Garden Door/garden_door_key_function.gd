extends Node3D


func garden_door_key():
	var garden_door = get_node("/root/" + get_tree().current_scene.name + "/garden_door")
	garden_door.key_picked_up()
	queue_free()
