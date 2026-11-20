class_name GameSkin
extends Resource

#@export var name:String = ""

@export var is_pixelart:=false

@export var font: Font

@export_category("Player")
@export var player_skin: Texture2D# = preload("uid://b7rih1r8srr4n")
@export var player_scale: Vector2 = Vector2(1,1)
@export var player_pos: = Vector2()
@export var player_rotation: = 0.0

@export_category("Bullets")
@export var bullet_skin: Texture2D# = preload("uid://cqf25tw0ndxjq")
@export var bullet_scale: Vector2 = Vector2(1,1)
@export var bullet_pos := Vector2 (0, 0)
@export var bullet_rotation := 0.0

@export_category("Asteroids")
@export var asteroid_skin: Texture2D# = preload("uid://bkj6xw64tbjpf")
@export var asteroid_scale := Vector2(1, 1)
@export var asteroid_pos := Vector2()

@export_category("Background")
@export var bg_image: Texture2D
@export var bg_scale:=Vector2()

#func _init(n:="",psk:= preload("uid://b7rih1r8srr4n"),ps:= Vector2(1,1),pp:= Vector2()\
	#,bsk:= preload("uid://cqf25tw0ndxjq"),bs:= Vector2(1,1),bp:= Vector2()\
	#,ask:= preload("uid://bkj6xw64tbjpf"),asc:= Vector2(1, 1),ap:= Vector2()):
	#
	##self.name = n
	#player_skin = psk
	#player_scale = ps
	#player_pos = pp
	#bullet_skin= bsk
	#bullet_scale = bs
	#bullet_pos = bp
	#asteroid_skin = ask
	#asteroid_scale = asc
	#asteroid_pos = ap
