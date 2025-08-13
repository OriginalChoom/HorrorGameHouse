extends RayCast3D

func _process(_delta):
	if is_colliding():
		var hit = get_collider()
		
		if hit != null and hit.has_method("pickup_flashlight"):
			if Input.is_action_just_pressed("interact"):
				hit.pickup_flashlight()
				
		#front gate methods
		if hit != null and hit.has_method("toggle_door_trigger"):
			if Input.is_action_just_pressed("interact"):
				hit.toggle_door_trigger()
				
		if hit != null and hit.has_method("open_front_gate_button"):
			if Input.is_action_just_pressed("interact"):
				hit.open_front_gate_button()
				
		#garden door methods
		if hit != null and hit.has_method("garden_door_detect"):
			if Input.is_action_just_pressed("interact"):
				hit.garden_door_detect()
				
		if hit != null and hit.has_method("pickup_garden_door_key"):
			if Input.is_action_just_pressed("interact"):
				hit.pickup_garden_door_key()
				
		#shack door metods
		if hit != null and hit.has_method("pickup_shack_key"):
			if Input.is_action_just_pressed("interact"):
				hit.pickup_shack_key()
				
		if hit != null and hit.has_method("open_shack_door_trigger"):
			if Input.is_action_just_pressed("interact"):
				hit.open_shack_door_trigger()
				
		if hit != null and hit.has_method("shack_lock_unlock_trigger"):
			if Input.is_action_just_pressed("interact"):
				hit.shack_lock_unlock_trigger()
				
		if hit != null and hit.has_method("shack_door_hindge_trigger"):
			if Input.is_action_just_pressed("interact"):
				hit.shack_door_hindge_trigger()
