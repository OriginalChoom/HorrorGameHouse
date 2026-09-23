extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var opened = false
		
func unlock_door_window():
	if !GlobalInteractions.door_window_unlocked and animation_player.current_animation != "door_unlock":
		GlobalInteractions.door_window_unlocked = true
		animation_player.play("door_unlock")
		
	elif animation_player.current_animation != "door_unlock" and GlobalInteractions.door_window_unlocked:
		GlobalInteractions.door_window_unlocked = false
		animation_player.play_backwards("door_unlock")
		
func open_door_window():
	if !opened and animation_player.current_animation != "door_unlock":
		animation_player.play("door_open")
		GlobalInteractions.door_window_opened = true
	elif opened and animation_player.current_animation != "door_unlock":
		animation_player.play_backwards("door_open")
		GlobalInteractions.door_window_opened = false
	opened = !opened
	
