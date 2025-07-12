extends RayCast3D

func _process(_delta):
	if is_colliding():
		var hit = get_collider()
		
		if hit != null and hit.has_method("pickup_flashlight"):
			if Input.is_action_just_pressed("interact"):
				hit.pickup_flashlight()
				
		if hit != null and hit.has_method("toggle_door_trigger"):
			if Input.is_action_just_pressed("interact"):
				hit.toggle_door_trigger()
