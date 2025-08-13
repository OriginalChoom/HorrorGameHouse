extends Node3D

var opened = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func open_front_gate():
	if animation_player.current_animation != "open_door" and animation_player.current_animation != "close_door":
		if !opened:
			animation_player.play("open_door")
		if opened:
			#await get_tree().create_timer(8.0).timeout
			animation_player.play("close_door")
		opened = !opened
