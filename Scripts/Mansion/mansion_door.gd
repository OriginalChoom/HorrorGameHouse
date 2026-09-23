extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var opened = false

func open_mansion_door():
	if GlobalInteractions.mansion_door_unlocked and animation_player.current_animation != "mansion_door_open" and opened == false:
		animation_player.play("mansion_door_open")
		opened = true
	elif GlobalInteractions.mansion_door_unlocked and animation_player.current_animation != "mansion_door_open" and opened == true:
		animation_player.play_backwards("mansion_door_open")
		opened = false
	
func unlock_mansion_door():
	if !GlobalInteractions.mansion_door_unlocked:
		GlobalInteractions.mansion_door_unlocked = true
