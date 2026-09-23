extends RayCast3D

@onready var crosshair_hand = get_parent().get_parent().get_parent().get_parent().get_node("player_ui/crosshair/crosshair_centar_hand")
@onready var crosshair = get_parent().get_parent().get_parent().get_parent().get_node("player_ui/crosshair/crosshair_centar")
@onready var player_ui: Control = $"../../../../player_ui"

var interactable
var hit

func _process(_delta):
	interactable = false
	
	if is_colliding():
		hit = get_collider()
		
		#flashlight pickup
		if hit != null and hit.has_method("pickup_flashlight"):
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.pickup_flashlight()
				
		#front gate methods
		elif hit != null and hit.has_method("toggle_door_trigger"):
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.toggle_door_trigger()
				
		elif hit != null and hit.has_method("open_front_gate_button"):
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.open_front_gate_button()
				
		#garden door methods
		elif hit != null and hit.has_method("garden_door_detect"):
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.garden_door_detect()
				
		elif hit != null and hit.has_method("garden_door_key"):
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.garden_door_key()
				
		#shack door metods
		elif hit != null and hit.has_method("shack_door_key_pickup"):
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.shack_door_key_pickup()
				
		elif hit != null and hit.has_method("open_shack_door_trigger") and GlobalInteractions.shack_hindge_unlocked:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.open_shack_door_trigger()
				
		elif hit != null and hit.has_method("shack_lock_unlock_trigger") and !GlobalInteractions.shack_door_lock_unlocked:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.shack_lock_unlock_trigger()
				
		elif hit != null and hit.has_method("shack_door_hindge_trigger") and GlobalInteractions.shack_door_lock_unlocked:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.shack_door_hindge_trigger()
				
		#safe methods
		elif hit != null and hit.has_method("safe_keypad_trigger") and !GlobalInteractions.is_keypad_unlocked:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				player_ui.safe_enter_password()
				
		elif hit != null and hit.has_method("safe_handle_trigger") and !GlobalInteractions.is_safe_handle_unlocked:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.safe_handle_trigger()
				
		elif hit != null and hit.has_method("safe_door_open_trigger") and GlobalInteractions.is_safe_handle_unlocked:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.safe_door_open_trigger()
				
		#crowbar pickup
		elif hit != null and hit.has_method("crowbar_pickup"):
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.crowbar_pickup()
				
		#falling bricks
		elif hit != null and hit.has_method("activate_falling_brick") and GlobalInteractions.has_crowbar:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.activate_falling_brick()
				
		#carper -> trenutno ga nema
		elif hit != null and hit.has_method("carpet_interact") and GlobalInteractions.is_carpet_moved == false:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.carpet_interact()
				
		#mansion methods
		elif hit != null and hit.has_method("pick_up_mansion_key"):
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.pick_up_mansion_key()
				
		elif hit != null and hit.has_method("unlock_mansion_door_trigger") and GlobalInteractions.mansion_key_picked_up and !GlobalInteractions.mansion_door_unlocked:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.unlock_mansion_door_trigger()
				
		elif hit != null and hit.has_method("open_door_trigger") and GlobalInteractions.mansion_door_unlocked:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.open_door_trigger()
				
		elif hit != null and hit.has_method("slide_door_lock_trigger") and !GlobalInteractions.slide_door_opened:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.slide_door_lock_trigger()
				
		elif hit != null and hit.has_method("slide_door_open_trigger") and GlobalInteractions.slide_door_unlocked:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.slide_door_open_trigger()
				
		elif hit != null and hit.has_method("door_window_opene_trigger") and GlobalInteractions.door_window_unlocked:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.door_window_opene_trigger()
				
		elif hit != null and hit.has_method("door_window_knob_trigger") and !GlobalInteractions.door_window_opened:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.door_window_knob_trigger()
				
		elif hit != null and hit.has_method("door_window_opener_2_triggger") and GlobalInteractions.door_window_unlocked_2:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.door_window_opener_2_triggger()
				
		elif hit != null and hit.has_method("door_window_knob_2_triggger") and !GlobalInteractions.door_window_opened_2:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.door_window_knob_2_triggger()
				
		#bolt cutters pickup
		elif hit != null and hit.has_method("bolt_cutters_pick_up"):
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.bolt_cutters_pick_up()
				
		#celler door methods
		elif hit != null and hit.has_method("celler_door_trigger") and !GlobalInteractions.celler_door_opened and GlobalInteractions.celler_door_chain_broken:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.celler_door_trigger()
				
		elif hit != null and hit.has_method("unlock_celler_door_chain") and GlobalInteractions.bolt_cutters_picked_up:
			interactable = true
			if Input.is_action_just_pressed("interact"):
				hit.unlock_celler_door_chain()
				
	crosshair.visible = !interactable
	crosshair_hand.visible = interactable
