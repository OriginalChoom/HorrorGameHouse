extends StaticBody3D

func shack_door_hindge_trigger():
	get_parent().get_parent().get_parent().open_shack_lock()
