extends RayCast3D

var pickup_text

func _ready():
	pickup_text = get_node("/root/" + get_tree().current_scene.name + "/flashlight")
	
func _process(delta):
	if is_colliding():
		var hit = get_collider()
		if hit.has_method("pickup_flashlight"):
			pickup_text.visible = true
			if Input.is_action_just_pressed("interact"):
				hit.pickup_flashlight()
		else:
			pickup_text.visible = false
