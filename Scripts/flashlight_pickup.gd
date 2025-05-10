extends StaticBody3D

var flashlight

func _ready():
	flashlight = get_node("/root/" + get_tree().current_scene.name + "/player/player_head/flashlight")

func pickup_flashlight():
	flashlight.picked_up = true
	queue_free()
