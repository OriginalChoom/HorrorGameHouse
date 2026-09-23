extends RigidBody3D

func _ready():
	freeze = true
	angular_damp = 3.0

func unlock_celler_door_chain():
	if GlobalInteractions.bolt_cutters_picked_up:
		GlobalInteractions.celler_door_chain_broken = true
		await get_tree().create_timer(0.1).timeout
		freeze = false
		
		# Direction away from wall (adjust depending on your wall orientation)
		var push_dir = -global_transform.basis.z.normalized()
		
		# Add some randomness so it feels natural
		push_dir += Vector3(
		randf_range(-0.3, 0.3),
		randf_range(0.2, 0.5),
		randf_range(-0.3, 0.3)
		).normalized()
		
		# Apply force (push OUT + slight upward)
		apply_impulse(Vector3.ZERO, push_dir * 4)
		
		# Add rotation (this is key for realism)
		apply_torque_impulse(Vector3(
			randf_range(-0.5, 0.5),
			randf_range(-0.5, 0.5),
			randf_range(-0.5, 0.5)
		))
		
		await get_tree().create_timer(2.0).timeout
		queue_free()
