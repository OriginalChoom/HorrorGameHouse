extends StaticBody3D

func slide_door_lock_trigger():
	get_parent().get_parent().get_parent().get_parent().slide_door_lock()
