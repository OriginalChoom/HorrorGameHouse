extends Node3D

@onready var flashlight_light = $flashlight_mesh/flashlight_light
@onready var flashlight_mesh = $flashlight_mesh

var picked_up = false

func _ready():
	flashlight_mesh.hide()

func _input(_event):
	if picked_up:
		if Input.is_action_just_pressed("flash"):
			flashlight_light.visible = !flashlight_light.visible
