@tool
extends Control

@onready var name_label: Label = %Name

@export var ship : Sprite2D
@export var asteroids: Array[Sprite2D]
@export var bullets: Array[Sprite2D]
@export var skin_bg: Sprite2D

#@onready var skin_collection:SkinCollection = preload("uid://bcsqd2nmbllp")
const skin_uid := "uid://bcsqd2nmbllp"

@export var skin_index := 0:
	set(val):
		var skin_collection := preload(skin_uid)
		skin_index = val
		if val >= skin_collection.skins.size():
			skin_index = 0
		elif val <= -1:
			skin_index = skin_collection.skins.size()-1
		show_skin_preview(skin_collection.skins[skin_index])
		#print("Skin changed to %s" %[skin_index])

func show_skin_preview(skin: GameSkin):
	name_label.text = skin.resource_name
	if name_label.has_theme_font_override("font"):
		name_label.remove_theme_font_override("font")
	name_label.add_theme_font_override("font", skin.font)
	
	Logic.set_player_skin(skin, ship)
	for asteroid in asteroids:
		Logic.set_asteroid_skin(skin, asteroid)
	for bullet in bullets:
		Logic.set_bullet_skin(skin,bullet)
	
	Logic.set_bg_skin(skin,skin_bg)

func next():
	skin_index+=1
func prev():
	skin_index-=1
