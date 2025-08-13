extends Node3D

var opened = false
var locked = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func garden_gate_open():
	if animation_player.current_animation != "open_door" and animation_player.current_animation != "close_door" and locked == false:
		if !opened:
			animation_player.play("open_door")
		if opened:
			animation_player.play("close_door")
		opened = !opened
	else:
		animation_player.play("door_handle_wiggle")
		
func key_picked_up():
	locked = false
