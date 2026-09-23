extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var opened = false

func slide_door_lock():
	if !GlobalInteractions.slide_door_unlocked and animation_player.current_animation != "unlocking_door":
		GlobalInteractions.slide_door_unlocked = true
		animation_player.play("unlocking_door")
		
	elif animation_player.current_animation != "unlocking_door" and GlobalInteractions.slide_door_unlocked:
		GlobalInteractions.slide_door_unlocked = false
		animation_player.play_backwards("unlocking_door")
		
func slide_door_open():
	if !opened and animation_player.current_animation != "unlocking_door":
		animation_player.play("slide_door_open")
		GlobalInteractions.slide_door_opened = true
	elif opened and animation_player.current_animation != "unlocking_door":
		animation_player.play_backwards("slide_door_open")
		GlobalInteractions.slide_door_opened = false
	opened = !opened
