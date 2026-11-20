extends RigidBody2D

var rand=RandomNumberGenerator.new();
@export var spawnHeight=-940
@export var spawnWidth=1200

@export var velocityRangeX=750
@export var velocityY=500
@export var velocityRangeRotate=10;

@export var sprite_2d: Sprite2D

#var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#player=get_tree().get_first_node_in_group("player")
	position=Vector2(rand.randi_range(-spawnWidth,spawnWidth),spawnHeight)
	linear_velocity=Vector2(rand.randi_range(-velocityRangeX,velocityRangeX),velocityY)
	angular_velocity=rand.randf_range(-velocityRangeRotate,velocityRangeRotate)
	rotation_degrees=randf_range(0,360)
