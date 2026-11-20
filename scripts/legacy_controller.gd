extends Node2D

@export var shoot_button: InGameButton
@export var left_button: InGameButton
@export var right_button: InGameButton


func get_shooting() -> bool:
	return shoot_button.is_pressed()


# Between 1 and -1
func get_move_dir() -> float:
	return (-1 if left_button.is_pressed() else 0) + (1 if right_button.is_pressed() else 0)


func show_shoot() -> void:
	shoot_button.show()


func show_move() -> void:
	left_button.show()
	right_button.show()
	print_debug("shown")


func position_move_controls(side: Side) -> void:
	left_button.move_side(side)
	right_button.move_side(side)
	shoot_button.move_side(side)
