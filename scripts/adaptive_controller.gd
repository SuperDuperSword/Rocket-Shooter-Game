extends Node

@onready var aimable_touch_controller: Control = %AimableTouchController
@onready var buttons_touch_controller: Node2D = %Buttons

@onready var keyboard_controller: Node = $KeyboardController

@onready var shoot_controller: Node = keyboard_controller
@onready var move_controller: Node = keyboard_controller


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ready_2()


func ready_2() -> void:
	await get_parent().ready
	if not GameManager.uses_touch():
		return
	
	
	match GameManager.get_option(GameManager.OPTION_NAME_MOVE_METHOD):
		0: # Buttons
			move_controller = buttons_touch_controller
		1: # Slider
			move_controller = aimable_touch_controller
		_:
			move_controller = buttons_touch_controller
	
	match GameManager.get_option(GameManager.OPTION_NAME_SHOOT_METHOD):
		0: # Tap
			shoot_controller = aimable_touch_controller
		1: # Button
			shoot_controller = buttons_touch_controller
		_:
			shoot_controller = aimable_touch_controller
	
	if not shoot_controller.is_node_ready():
		await shoot_controller.ready
	shoot_controller.show_shoot()
	if not move_controller.is_node_ready():
		await move_controller.ready
	move_controller.show_move()


func get_shooting() -> bool:
	return shoot_controller.get_shooting()


func get_move_dir() -> float:
	return move_controller.get_move_dir()


func position_move_controls(side: Side) -> void:
	move_controller.position_move_controls(side)
	shoot_controller.position_move_controls(side)
	print(side)
