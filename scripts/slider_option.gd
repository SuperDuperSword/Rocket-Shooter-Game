# @tool
extends HBoxContainer

@onready var h_slider: HSlider = $HSlider
@onready var value_label: Label = $Label2

@export var value_append=" "

func _process(_delta: float) -> void:
	value_label.text = str(h_slider.value) + value_append
	
