extends Node3D

@onready var animation_player: AnimationPlayer = $celler_door/AnimationPlayer

func open_celler_door():
	if animation_player.current_animation != "celler_open" and GlobalInteractions.celler_door_opened == false and GlobalInteractions.celler_door_chain_broken == true:
		animation_player.play("celler_open")
		GlobalInteractions.celler_door_opened = true
