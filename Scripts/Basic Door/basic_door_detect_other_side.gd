extends StaticBody3D

var door_other_side

func toggle_door_trigger():
	if door_other_side != null:
		door_other_side.toggle_door()
