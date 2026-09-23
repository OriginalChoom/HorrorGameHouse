extends RigidBody3D

func pick_up_mansion_key():
	GlobalInteractions.mansion_key_picked_up = true
	queue_free()
