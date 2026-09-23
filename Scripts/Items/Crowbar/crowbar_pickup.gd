extends RigidBody3D

func crowbar_pickup():
	GlobalInteractions.has_crowbar = true
	queue_free()
