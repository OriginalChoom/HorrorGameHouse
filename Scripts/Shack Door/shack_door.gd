extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var locked = true

var lock_unlocked = false
var opened = false

var shack_hinge_lock = true

func open_shack_door():
	if animation_player.current_animation != "door_open" and animation_player.current_animation != "door_close" and locked == false and lock_unlocked == true and shack_hinge_lock == false and animation_player.current_animation != "hinge_lock_open":
		if !opened:
			animation_player.play("door_open")
		if opened:
			animation_player.play("door_close")
		opened = !opened

func open_shack_lock():
	var hinge_collision = get_node("shack_door_main/lock_hinge/StaticBody3D/CollisionShape3D")
	if locked == false and lock_unlocked == true and animation_player.current_animation != "lock_unlocked" and shack_hinge_lock == true:
		animation_player.play("hinge_lock_open")
		hinge_collision.set_deferred("disabled", true)
		shack_hinge_lock = false
		GlobalInteractions.shack_hindge_unlocked = true
		
	
func unlock_the_lock():
	var collision = get_node("shack_door_main/shack_door_lock/lock/StaticBody3D/CollisionShape3D")
	if locked == true and lock_unlocked == false:
		animation_player.play("lock_locked_interact")
	if locked == false and lock_unlocked == false:
		collision.set_deferred("disabled", true)
		animation_player.play("lock_unlocked")
		lock_unlocked = true
		GlobalInteractions.shack_door_lock_unlocked = true
	
func shack_key_picked_up():
	locked = false
