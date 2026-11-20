extends Control

#region vars
@onready var gamemode_button: OptionButton = $"ScrollContainer/VBoxContainer/Game Mode/OptionButton"
@onready var difficulty_button: OptionButton = $ScrollContainer/VBoxContainer/Difficulty/OptionButton
@onready var control_mode: OptionButton = $ScrollContainer/VBoxContainer/ControlMode/OptionButton
@onready var wait_after_loss: HSlider = $"ScrollContainer/VBoxContainer/Time After Death/HSlider"
@onready var mouse_follow_button: OptionButton = $ScrollContainer/VBoxContainer/DoMouseFollow/OptionButton
@onready var skin_screen: Control = %SkinScreen
@onready var options: ScrollContainer = $ScrollContainer
@onready var shoot_method_button: OptionButton = $ScrollContainer/VBoxContainer/TouchShootMethod/OptionButton
@onready var move_method_button: OptionButton = $ScrollContainer/VBoxContainer/TouchMoveMethod/OptionButton
@onready var touch_orientation_button: OptionButton = $ScrollContainer/VBoxContainer/TouchControlOrientation/OptionButton
#endregion

const settings_location="user://options.cfg"

#const GAME = preload("res://scenes/game.tscn")

func start_game():
	save_settings()
	print("Starting game...")
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func save_settings():
	if not has_aim:
		mouse_follow_button.select(0)
	
	var cfg: ConfigFile = ConfigFile.new()
	#cfg.set_value("Misc.","Game Mode", gamemode_button.selected)
	#cfg.set_value("Difficulty","Difficulty",difficulty_button.selected)
	#cfg.set_value("Misc.","Control Mode", control_mode.selected)
	#cfg.set_value("Misc.","Wait to Restart", wait_after_loss.value)
	#cfg.set_value("Skin", "Skin Index", skin_screen.skin_index)
	
	# ------------
	
	cfg.set_value("Options", "Options", {
		GameManager.OPTION_NAME_GAMEMODE: gamemode_button.selected,
		GameManager.OPTION_NAME_DIFFICULTY: difficulty_button.selected,
		GameManager.OPTION_NAME_CONTROL_MODE: control_mode.selected,
		GameManager.OPTION_NAME_RETRY_TIME: wait_after_loss.value,
		GameManager.OPTION_NAME_SKIN: skin_screen.skin_index,
		GameManager.OPTION_NAME_MOUSE_AIM: mouse_follow_button.selected as bool,
		GameManager.OPTION_NAME_MOVE_METHOD: move_method_button.selected,
		GameManager.OPTION_NAME_SHOOT_METHOD: shoot_method_button.selected,
		GameManager.OPTION_NAME_TOUCH_ORIENTATION: touch_orientation_button.selected,
	})
	
	GameManager.options = cfg.get_value("Options", "Options") as Dictionary
	
	#print(cfg.get_value("Options", "Options"))
	
	var err = cfg.save(settings_location)
	
	if err:
		push_warning("Couldn't save settings! ", error_string(err))
	else:
		print ("Saved settings!")

func read_settings():
	var cfg=ConfigFile.new()
	var err=cfg.load(settings_location)
	if err: #or not cfg.has_section_key("Options", "Options"):
		#_on_control_mode_item_selected(control_mode.selected)
		cfg = ConfigFile.new()
		cfg.set_value("Options", "Options", GameManager.DEFAULT_OPTIONS)
	GameManager.options = cfg.get_value("Options", "Options")
	#prints(GameManager.options, GameManager.options.merged(GameManager.DEFAULT_OPTIONS))
	
	gamemode_button.selected=GameManager.get_option(GameManager.OPTION_NAME_GAMEMODE)
	difficulty_button.selected=GameManager.get_option(GameManager.OPTION_NAME_DIFFICULTY)
	control_mode.select(GameManager.get_option(GameManager.OPTION_NAME_CONTROL_MODE))
	if GameManager.get_option(GameManager.OPTION_NAME_CONTROL_MODE) == 3:
		control_mode.selected = 1
	wait_after_loss.value=GameManager.get_option(GameManager.OPTION_NAME_RETRY_TIME)
	skin_screen.skin_index = GameManager.get_option(GameManager.OPTION_NAME_SKIN)
	mouse_follow_button.select(GameManager.get_option(GameManager.OPTION_NAME_MOUSE_AIM) as int)
	shoot_method_button.select(GameManager.get_option(GameManager.OPTION_NAME_SHOOT_METHOD))
	move_method_button.select(GameManager.get_option(GameManager.OPTION_NAME_MOVE_METHOD))
	touch_orientation_button.select(GameManager.get_option(GameManager.OPTION_NAME_TOUCH_ORIENTATION))
	
	_on_control_mode_item_selected(control_mode.selected)

func _ready():
	read_settings()

func to_skin_screen():
	options.visible = false
	skin_screen.visible = true

func exit_skin_screen():
	options.visible = true
	skin_screen.visible = false
	
@onready var mouse_follow_label: Label = $ScrollContainer/VBoxContainer/DoMouseFollow/Label

var has_aim := true

func _on_control_mode_item_selected(index: int) -> void:
	var has_keyboard := false
	match index:
		0: # Auto
			has_keyboard = not DisplayServer.is_touchscreen_available()
		1: # Modern Touch
			has_keyboard = false
		2: # Keyboard
			has_keyboard = true
	
	if has_keyboard:
		has_aim = true
	else:
		_on_shoot_method_item_selected(shoot_method_button.selected)
	
	wait_after_loss.get_parent().visible = has_keyboard
	shoot_method_button.get_parent().visible = not has_keyboard
	move_method_button.get_parent().visible = not has_keyboard
	touch_orientation_button.get_parent().visible = not has_keyboard
	mouse_follow_label.text = "Aim With Mouse" if has_keyboard else "Aim With Touch"


func _on_shoot_method_item_selected(index: int) -> void:
	has_aim = index == 0 # 0 is the "tap" method
	mouse_follow_button.get_parent().visible = has_aim
