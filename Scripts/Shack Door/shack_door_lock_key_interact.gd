extends StaticBody3D

func pickup_shack_key():
	get_parent().get_parent().shack_door_key_pickup()
