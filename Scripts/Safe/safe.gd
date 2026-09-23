extends Node3D

@onready var animation_player: AnimationPlayer = $safe2/AnimationPlayer

var locked = true
var safe_handle_locked = true
var safe_handle_interact = true
var safe_opened = false

func safe_handle():
	if locked:
		animation_player.play("handle_jiggle")
	elif locked == false and safe_handle_interact == true:
		safe_handle_locked = false
		animation_player.play("handle_unlock")
		safe_handle_interact = false
		GlobalInteractions.is_safe_handle_unlocked = true
		
func safe_open():
	if safe_handle_locked == false and safe_opened == false and animation_player.current_animation != "handle_unlock":
		animation_player.play("open_safe")
		safe_opened = !safe_opened
	elif safe_handle_locked == false and safe_opened == true:
		animation_player.play_backwards("open_safe")
		safe_opened = !safe_opened
		
