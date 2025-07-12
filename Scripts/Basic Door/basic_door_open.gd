extends Node3D

var opened = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var static_body_3d: StaticBody3D = $basic_door/door_hinge/door/door_handle/StaticBody3D
@onready var static_body_3d_door_other_side: StaticBody3D = $basic_door/door_hinge/door/door_handle_001/StaticBody3D


func _ready():
	static_body_3d.door = self
	static_body_3d_door_other_side.door_other_side = self
	
func toggle_door():
	if animation_player.current_animation != "open" and animation_player.current_animation != "close":
		if !opened:
			animation_player.play("open")
		if opened:
			animation_player.play("close")
	opened = !opened
