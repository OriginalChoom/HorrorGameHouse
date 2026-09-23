extends StaticBody3D

func unlock_mansion_door_trigger():
	get_parent().get_parent().get_parent().get_parent().unlock_mansion_door()
