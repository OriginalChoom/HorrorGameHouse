extends StaticBody3D

func shack_lock_unlock_trigger():
	get_parent().get_parent().unlock_the_lock()
	
