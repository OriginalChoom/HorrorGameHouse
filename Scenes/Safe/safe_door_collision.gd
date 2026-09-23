extends StaticBody3D

func safe_door_open_trigger():
	get_parent().get_parent().get_parent().get_parent().safe_open()
