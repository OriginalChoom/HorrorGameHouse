extends Node3D

var opened = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func toggle_door():
	if animation_player.current_animation != "open" and animation_player.current_animation != "close":
		if !opened:
			animation_player.play("open")
		if opened:
			animation_player.play("close")
		opened = !opened
	#else:
		#animation_player.play("door_handle_wiggle")
