extends StaticBody3D

func open_door_trigger():
	get_parent().get_parent().get_parent().get_parent().open_mansion_door()
