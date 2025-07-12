extends StaticBody3D

var door

func toggle_door_trigger():
	if door != null:
		door.toggle_door()
