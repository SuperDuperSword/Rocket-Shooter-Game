#@tool
extends TouchScreenButton
class_name InGameButton

@onready var area: Area2D = $Area2D
@onready var player=get_tree().get_first_node_in_group("player")
#@onready var logic: Node = %Logic

@export var lerp_speed=2
@export var transparency=0.5

@export var left_pos: Vector2
@export var right_pos: Vector2


func move_side(side: Side) -> void:
	match side:
		SIDE_RIGHT:
			position = right_pos
		SIDE_LEFT:
			position = left_pos
	#print(position)

var player_in:=false

func _ready():
	pass
	call_deferred("fix_visibility")
	
	#print(player)

func fix_visibility():
	#visible = player.uses_touch
	pass # It's automatically handled

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body==player:
		#print("The player has approached the button")
		player_in=true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body==player:
		#print("The player has exited the button")
		player_in=false

func _process(delta):
	self_modulate.a=lerp(self_modulate.a,transparency if player_in else 1.0, lerp_speed*delta)
