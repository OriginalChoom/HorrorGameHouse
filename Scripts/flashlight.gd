extends Node3D


@onready var flashlight_light = $flashlight_mesh/flashlight_light

@onready var flashlight_mesh = $flashlight_mesh

var picked_up = false

func _input(event):
	
	if picked_up == true:
		flashlight_mesh.show()
		
	if Input.is_action_just_pressed("flash") and picked_up == true:
		flashlight_light.visible = !flashlight_light.visible
