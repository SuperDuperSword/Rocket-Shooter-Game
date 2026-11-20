extends Node

const GAME = preload("uid://blo18phx783jr")


func play():
	print("Starting game...")
	get_tree().change_scene_to_packed(GAME)
	
func open_settings():
	print("Entering Settings...")
	get_tree().change_scene_to_file("res://scenes/settings_screen.tscn")
