# I'm an autoload!
extends Node

var skin := 0

var skins: SkinCollection = preload("uid://bcsqd2nmbllp")

var options: Dictionary = {}

const DEFAULT_OPTIONS : Dictionary = {
	OPTION_NAME_GAMEMODE: Logic.score_index,
	OPTION_NAME_DIFFICULTY: Logic.normal_index,
	OPTION_NAME_CONTROL_MODE: Logic.auto_touch_index,
	OPTION_NAME_RETRY_TIME: 0.6,
	OPTION_NAME_SKIN: 0,
	OPTION_NAME_MOUSE_AIM: false,
	OPTION_NAME_SHOOT_METHOD: 0,
	OPTION_NAME_MOVE_METHOD: 0,
	OPTION_NAME_TOUCH_ORIENTATION: 0,
}

const OPTION_NAME_GAMEMODE := "game_mode"
const OPTION_NAME_DIFFICULTY := "difficulty"
const OPTION_NAME_CONTROL_MODE := "control_mode"
const OPTION_NAME_RETRY_TIME := "wait_to_retry"
const OPTION_NAME_SKIN := "skin_index"
const OPTION_NAME_MOUSE_AIM := "aim_with_mouse"
const OPTION_NAME_MOVE_METHOD := "move_method"
const OPTION_NAME_SHOOT_METHOD := "shoot_method"
const OPTION_NAME_TOUCH_ORIENTATION := "touch_side"

const NON_GAMEPLAY_SETTINGS: Array[String] = [
	OPTION_NAME_CONTROL_MODE,
	OPTION_NAME_SKIN,
	OPTION_NAME_RETRY_TIME,
	OPTION_NAME_MOVE_METHOD,
	OPTION_NAME_SHOOT_METHOD,
	OPTION_NAME_TOUCH_ORIENTATION,
]


func get_option(option: String) -> Variant:
	if option in options:
		return options[option]
	elif option in DEFAULT_OPTIONS:
		return DEFAULT_OPTIONS[option]
	else:
		push_error("Option name ", option, " is not an valid setting/option. Returning -1.")
		return -1


func get_skin() -> GameSkin:
	return skins.skins[skin]


func uses_touch() -> bool:
	return get_option(OPTION_NAME_CONTROL_MODE) == 1 or \
			(get_option(OPTION_NAME_CONTROL_MODE) == 0 and \
			DisplayServer.is_touchscreen_available())
