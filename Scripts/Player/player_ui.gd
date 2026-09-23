extends Control

@onready var pause_menu: CanvasLayer = $pause_menu
@onready var safe_ui: CanvasLayer = $safe_ui
@onready var safe_pass: LineEdit = $safe_ui/safe_pass
@onready var button_confirm: Button = $safe_ui/button_confirm

@onready var safe = get_tree().current_scene.get_node("safe")
@onready var safe_code = get_tree().current_scene.get_node("safe_code")

@onready var random = RandomNumberGenerator.new()

var safe_password
var safe_interactable = true

func _ready() -> void:
	pause_menu.visible = false
	safe_ui.visible = false
	var p1 = random.randi_range(0,9)
	var p2 = random.randi_range(0,9)
	var p3 = random.randi_range(0,9)
	var p4 = random.randi_range(0,9)
	var p5 = random.randi_range(0,9)
	safe_password = str(p1) + str(p2) + str(p3) + str(p4) + str(p5)
	safe_code.get_node("paper_text").mesh.text = safe_password
	print(safe_password)
	
#pause menu
func resume_game():
	get_tree().paused = false
	pause_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func quit_game():
	get_tree().quit()
	
#safe ui
#func kojeg raycast hvata na keypadu
func safe_enter_password(): 
	if safe_interactable:
		safe_ui.visible = true
		get_tree().paused = true
		safe_pass.grab_focus()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func exit_safe():
	safe_ui.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func confirm_safe_password():
	if safe_pass.text == safe_password:
		safe.locked = false
		safe_interactable = false
		safe_pass.max_length = 9
		safe_pass.add_theme_color_override("font_uneditable_color", Color.GREEN)
		safe_pass.text = "CONFIRMED"
		safe_pass.editable = false
		GlobalInteractions.is_keypad_unlocked = true
		
		if button_confirm.pressed.is_connected(confirm_safe_password):
			button_confirm.pressed.disconnect(confirm_safe_password)
			
		
	else:
		safe_pass.add_theme_color_override("font_uneditable_color", Color.RED)
		safe_pass.editable = false
		safe_pass.text = "ERROR"
		await get_tree().create_timer(1).timeout
		safe_pass.text = ""
		safe_pass.add_theme_color_override("font_color", Color.WHITE)
		safe_pass.editable = true
		safe_pass.grab_focus()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape") and !safe_ui.visible:
		pause_menu.visible = !pause_menu.visible
		get_tree().paused = pause_menu.visible
		if get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if !get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	elif safe_ui.visible and Input.is_action_just_pressed("escape"):
		safe_ui.visible = false
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
