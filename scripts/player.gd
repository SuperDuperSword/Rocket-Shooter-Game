extends CharacterBody2D


@export var speed = 300.0
@export var reload = 0.3
@export var sprite_2d: Sprite2D
@export var do_mouse_rotate := true
@export var controller: Node
@export_custom(PROPERTY_HINT_NONE, "radians") var max_rotation_angle := deg_to_rad(35)

@onready var timer: Timer = $"Reload Timer"
@onready var refresh_scene_timer: Timer = $"Refresh Scene Timer"
@onready var bullets: Node = %Bullets
@onready var player: CharacterBody2D = $"."
@onready var score: Label = %Score
@onready var logic: Node = %Logic
@onready var hitbox: CollisionShape2D = $"Player Hitbox"

const BULLET:PackedScene = preload("res://scenes/bullet.tscn")

var has_shot := false
var uses_touch := false

var shot_direction := Vector2.UP

signal shot(skin:GameSkin, bullet: Sprite2D)

func _process(_delta: float) -> void:
	if logic.is_dead:
		return
	
	if not controller.get_shooting():
		has_shot = true
	if timer.is_stopped() and controller.get_shooting() and has_shot:
			# If space is pressed in keyboard control, or button pressed in touch
			has_shot = true
			shoot()
			timer.start(reload)

func shoot()->void:
	_update_with_mouse()
	
	var bullet = BULLET.instantiate();
	bullet.score=score
	bullet.logic=logic
	bullet.direction = shot_direction
	bullet.rotation = rotation
	bullets.add_child(bullet,true)
	bullet.global_position=global_position
	
	shot.emit(GameManager.get_skin(),bullet.sprite_2d)

#region named vars
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var music: AudioStreamPlayer2D = %Music

#@onready var right: TouchScreenButton = %Right
#@onready var left: TouchScreenButton = %Left
#@onready var shoot_button: TouchScreenButton = %Shoot
#@onready var buttons: Node2D = %Buttons

@export var lerp_speed = 2
@export var area_border = 1000.0
#endregion

func _physics_process(delta: float) -> void:
	if logic.is_dead:
		return
	# Get the input direction and handle the movement/deceleration.
	#var direction := roundf(Input.get_axis("moveL", "moveR"))
	
	# Touchscreen input
	var direction = controller.get_move_dir()
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	# Push the player inside the play area
	if   position.x > area_border:
		position.x = lerp(position.x, area_border, lerp_speed * delta)
	elif position.x < -area_border:
		position.x = lerp(position.x, -area_border, lerp_speed* delta)
	
	if not uses_touch: # When it rotates around a spot it gets kinda weird.
		# Better to keep the rotation the same.
		_update_with_mouse()
	
	move_and_slide()

@export_range(0,1) var dead_music_volume=0.05
@export var reload_wait=4

signal died

func die(_asteroid: Node2D) -> void:
	print("You died! "+score.text)
	speed=0
	animation_player.play("Die")
	animated_sprite_2d.play("explode")
	timer.start(reload_wait+100) # Can't shoot until way after reload
	refresh_scene_timer.start(reload_wait)
	#asteroid.queue_free()
	music.volume_linear=dead_music_volume
	#take_screenshot()
	
	#buttons.visible=false
	died.emit()
	animated_sprite_2d.rotation = -rotation
	
	logic.dead()


var _mouse_pos: Vector2


func _update_with_mouse() -> void:
	if not do_mouse_rotate: 
		rotation = 0
		shot_direction = Vector2.UP
		return
	if not uses_touch:
		_mouse_pos = get_global_mouse_position()
	#print_debug(_mouse_pos)
	look_at(_mouse_pos)
	rotate(PI / 2)
	if rotation > max_rotation_angle:
		rotation = max_rotation_angle
	elif rotation < -max_rotation_angle:
		rotation = -max_rotation_angle
	shot_direction = Vector2.from_angle(rotation - PI / 2)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_mouse_pos = event.position - get_viewport_rect().size / 2
		_mouse_pos = _mouse_pos / get_viewport().get_camera_2d().zoom.x
		_update_with_mouse()
		#position = _mouse_pos
		#print_debug(_mouse_pos)
