extends StaticBody3D

var flashlight

func _ready():
	var current_scene = get_tree().get_current_scene()
	var player = current_scene.get_node("player_node/player")
	flashlight = player.get_node("flashlight")

func interact():
	flashlight.picked_up = true
	flashlight.flashlight_mesh.show()
	queue_free()
