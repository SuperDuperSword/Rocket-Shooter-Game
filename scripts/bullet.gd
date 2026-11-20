extends Area2D

@export var speed=-300

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

var direction := Vector2.UP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += -speed * delta * direction
	if position.y <- 1500:
		queue_free()
	pass

var score:Label
var logic

func _on_body_entered(body: Node2D) -> void:
	animation_player.play("Hit")
	body.queue_free()
	logic.add_score()
	pass # Replace with function body.
