extends RigidBody3D

func bolt_cutters_pick_up():
	GlobalInteractions.bolt_cutters_picked_up = true
	queue_free()
