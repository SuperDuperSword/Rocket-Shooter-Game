extends Node


func get_shooting() -> bool:
	return Input.is_action_pressed("shoot")


func get_move_dir() -> float:
	return round(Input.get_axis("moveL", "moveR"))


func position_move_controls(_side: Side) -> void:
	pass
