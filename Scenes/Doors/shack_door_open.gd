extends StaticBody3D

func open_shack_door_trigger():
	get_parent().get_parent().open_shack_door()
