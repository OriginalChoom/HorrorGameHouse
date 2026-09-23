extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var opened = false
		
func unlock_door_window_2():
	if !GlobalInteractions.door_window_unlocked_2 and animation_player.current_animation != "door_unlock":
		GlobalInteractions.door_window_unlocked_2 = true
		animation_player.play("door_unlock")
		
	elif animation_player.current_animation != "door_unlock" and GlobalInteractions.door_window_unlocked_2:
		GlobalInteractions.door_window_unlocked_2 = false
		animation_player.play_backwards("door_unlock")
		
func open_door_window_2():
	if !opened and animation_player.current_animation != "door_unlock":
		animation_player.play("door_open")
		GlobalInteractions.door_window_opened_2 = true
	elif opened and animation_player.current_animation != "door_unlock":
		animation_player.play_backwards("door_open")
		GlobalInteractions.door_window_opened_2 = false
	opened = !opened
	
