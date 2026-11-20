extends Control

#@export var min_move := 0.2
@export var movement_curve: Curve

var _is_shooting := false

@onready var slider: Slider = $HSlider

@export var left_pos: Vector2
@export var right_pos: Vector2


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_is_shooting = event.pressed 


func get_shooting() -> bool:
	return _is_shooting


# Between 1 and -1
func get_move_dir() -> float:
	return movement_curve.sample_baked(slider.value)


func _on_slider_drag_ended(_changed: bool) -> void:
	slider.value = 0


func show_shoot() -> void:
	pass


func show_move() -> void:
	show()


func position_move_controls(side: Side) -> void:
	match side:
		SIDE_LEFT:
			slider.position = left_pos
		SIDE_RIGHT:
			slider.position = right_pos
