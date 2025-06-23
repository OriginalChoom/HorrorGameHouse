extends RayCast3D

func _process(_delta):
	if is_colliding():
		var hit = get_collider()
		if hit != null and hit.has_method("interact"):
			if Input.is_action_just_pressed("interact"):
				hit.interact()
