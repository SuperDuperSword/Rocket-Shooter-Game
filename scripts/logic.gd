class_name Logic extends Node

@export var waveInterval := 1.5
@export var minimumAsteroidCount := 4
@export var maximumAsteroidCount := 12
@export var score := 0
@export var asteroidIncreaseWait := 12.0
@export var is_dead := false

@onready var timer: Timer = $Timer
@onready var music: AudioStreamPlayer2D = %Music
@onready var asteroids: Node2D = %Asteroids
@onready var asteroid_increase_timer: Timer = $"Asteroid Increase Timer"
@onready var retry_wait_timer: Timer = $WaitToRetry

@onready var reload_bar: ProgressBar = %ReloadBar
@onready var progress_label: Label = %ProgressLabel

@onready var timeLabel: Label = %Time
@onready var scoreLabel: Label = %Score
@onready var death_screen: Control = %"Death Screen"
@onready var you_scored: Label = %"You scored"
@onready var highscore_label: Label = %Highscore

#@onready var cfg_options:ConfigFile = ConfigFile.new()
const settings_location := "user://options.cfg"
var difficulty:int = normal_index

const ASTEROID := preload("res://scenes/asteroid.tscn")
const SETTINGS := preload("res://scenes/settings_screen.tscn")

@onready var player := get_tree().get_first_node_in_group("player")

var start_time_msec := 0
var time_msec := 0

#region Option Indexes
const score_index := 0
const timed_index := 1

const very_easy_index := 0
const easy_index := 1
const normal_index := 2
const hard_index := 3

const auto_touch_index := 0
const touch_index := 1
const keyboard_index := 2
const legacy_touch_index := 3

const default_wait_to_retry := 0.6
#endregion

var has_items := false

func add_score(add: int=1):
	if is_dead:
		return
	score+=add
	scoreLabel.text="Score: "+str(score)

func wave() -> void:
	timer.start(waveInterval)
	var asteroidCount=randi_range(minimumAsteroidCount,maximumAsteroidCount)
	for i in range(asteroidCount):
		var asteroid=ASTEROID.instantiate()
		set_asteroid_skin(GameManager.get_skin(),asteroid.sprite_2d)
		asteroids.add_child(asteroid,true)

@export var legacy_controller: CanvasItem
@export var modern_controller: CanvasItem


func _ready() -> void:
	music.volume_linear=1
	var cfg := ConfigFile.new()
	var err = cfg.load(settings_location)
	if not err and cfg.has_section_key("Options", "Options"): 
		# This means there are settings.
		GameManager.options = cfg.get_value("Options", "Options")
	
	# If there are no settings the GameManager.options will be empty 
	# but the GameManager.get_option() method will not break.
	
	GameManager.skin = GameManager.get_option(GameManager.OPTION_NAME_SKIN)
	
	set_player_skin(GameManager.get_skin(),player.sprite_2d)
	set_bg_skin(GameManager.get_skin(),bg)
	set_hud_skin(GameManager.get_skin())
	
	if GameManager.get_option(GameManager.OPTION_NAME_GAMEMODE)==timed_index: # Survival/Timed Mode
		scoreLabel.visible=false
		timeLabel.visible=true
	else:
		scoreLabel.visible=true
		timeLabel.visible=false
	difficulty=GameManager.get_option(GameManager.OPTION_NAME_DIFFICULTY)
	
	start_time_msec=Time.get_ticks_msec()
	match difficulty:
		easy_index:
			minimumAsteroidCount-=2
			maximumAsteroidCount-=3
			
			asteroidIncreaseWait+=0.7
			
			player.reload-=0.13
			player.speed+=50
			
			reload_bar.visible=true
		
		hard_index:
			minimumAsteroidCount+=3
			maximumAsteroidCount+=2
			
			asteroidIncreaseWait-=0.9
			
			player.reload+=0.3
			player.speed-=85
		
		very_easy_index:
			minimumAsteroidCount -= 3
			maximumAsteroidCount -= 5
			
			asteroidIncreaseWait += 1.5
			
			player.reload -= 0.29
			player.speed += 120
			
			timer.wait_time += 0.25
			
			reload_bar.visible = true
	
	asteroid_increase_timer.start(asteroidIncreaseWait)
	
	update_hs_sect_key()
	
	#print("Game Mode: %s | Difficulty: %s" \
	#	%[GameManager.get_option(GameManager.OPTION_NAME_GAMEMODE),difficulty])
	
	print(GameManager.options.merged(GameManager.DEFAULT_OPTIONS))
	
	match GameManager.get_option(GameManager.OPTION_NAME_CONTROL_MODE):
		auto_touch_index: 
			player.uses_touch = DisplayServer.is_touchscreen_available()
			#player.controller = modern_controller
			#modern_controller.visible = player.uses_touch
			#legacy_controller.hide()
		touch_index, legacy_touch_index: # This just in case
			player.uses_touch = true
			#player.controller = modern_controller
			#modern_controller.show()
			#legacy_controller.hide()
		keyboard_index: 
			player.uses_touch = false
			legacy_controller.hide()
			modern_controller.hide()
	player.controller = adaptive_controller
	adaptive_controller.position_move_controls.call_deferred(SIDE_RIGHT if (GameManager.get_option\
			(GameManager.OPTION_NAME_TOUCH_ORIENTATION) == 0) else SIDE_LEFT)
	#print(cfg_options.get_value("Misc."))
	
	player.do_mouse_rotate = GameManager.get_option(GameManager.OPTION_NAME_MOUSE_AIM)

@onready var adaptive_controller: Node = $AdaptiveController

#region skin setters
static func set_player_skin(skin:GameSkin, ps:Sprite2D):
	ps.texture = skin.player_skin
	ps.position = skin.player_pos
	ps.scale = skin.player_scale
	ps.rotation = deg_to_rad(skin.player_rotation)
	ps.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if skin.is_pixelart \
			else CanvasItem.TEXTURE_FILTER_LINEAR

static func set_asteroid_skin(skin: GameSkin, asp: Sprite2D):
	asp.texture = skin.asteroid_skin
	asp.position = skin.asteroid_pos
	asp.scale = skin.asteroid_scale
	asp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if skin.is_pixelart \
			else CanvasItem.TEXTURE_FILTER_LINEAR

static func set_bullet_skin(skin: GameSkin, bsp: Sprite2D):
	bsp.texture = skin.bullet_skin
	bsp.position = skin.bullet_pos
	bsp.scale = skin.bullet_scale
	bsp.rotation = deg_to_rad(skin.bullet_rotation)
	bsp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if skin.is_pixelart \
			else CanvasItem.TEXTURE_FILTER_LINEAR

@onready var bg: Sprite2D = $"../Space"
@warning_ignore("shadowed_variable")
static func set_bg_skin(skin: GameSkin, bg:Sprite2D):
	bg.texture = skin.bg_image
	bg.scale = skin.bg_scale
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if skin.is_pixelart \
			else CanvasItem.TEXTURE_FILTER_LINEAR

@onready var death_labels: VBoxContainer = %VBoxContainer
func set_hud_skin(skin:GameSkin):
	scoreLabel.add_theme_font_override("font", skin.font)
	timeLabel.add_theme_font_override("font", skin.font)
	progress_label.add_theme_font_override("font", skin.font)
	
	for label:Label in death_labels.get_children():
		label.add_theme_font_override("font", skin.font)
	for child in death_screen.get_children():
		if not child is Button:
			continue
		var button := child as Button
		button.add_theme_font_override("font", skin.font)
#endregion

func dead():
	is_dead=true
	death_screen.visible=true
	scoreLabel.visible=false
	timeLabel.visible=false
	reload_bar.visible=false
	
	you_scored.text=scoreLabel.text if !GameManager.get_option(GameManager.OPTION_NAME_GAMEMODE)\
		else timeLabel.text
	
	asteroid_increase_timer.stop()
	
	var time=GameManager.get_option(GameManager.OPTION_NAME_RETRY_TIME)
	if not time==0:
		#print(time)
		retry_wait_timer.wait_time=time
		retry_wait_timer.start(time)
	else :
		#print("Time is zero")
		pass
	
	print("Time: "+ mm_ss(time_msec))
	
	var hs=read_hScore()
	if GameManager.get_option(GameManager.OPTION_NAME_GAMEMODE)==1:
		score=time_msec # A lazy solution to the problem of two gamemodes...
	
	if score>hs:
		highscore_label.text="High Score!"
		set_hScore(score)
	else:
		highscore_label.text="High Score: "+(str(roundi(hs)) if \
				GameManager.get_option(GameManager.OPTION_NAME_GAMEMODE)==0 else mm_ss(hs))

func _process(_delta:float):
	#print(retry_wait_timer.time_left)
	if(Input.is_physical_key_pressed(KEY_SPACE) and is_dead and retry_wait_timer.is_stopped()):
		refresh_scene()
	
	#region Time
	time_msec=Time.get_ticks_msec()-start_time_msec
	var t := mm_ss(time_msec)
	timeLabel.text="Time: " + t
	#endregion
	
	var percent=((player.timer.wait_time-player.timer.time_left)/\
		player.timer.wait_time)*100
	reload_bar.value=percent
	progress_label.text=str(roundi(percent))+"%" if percent != 100 else "Ready"

func mm_ss(msecs) -> String:
	var mins=floori(msecs/60_000)
	var sec=msecs-mins*60_000
	sec/=100
	sec=roundi(sec)
	sec/=10.0
	return str(mins) + ":" + str(sec)

const hsPath := "user://Highscore.cfg" 
var hs_section: String
var hs_key: String

func read_hScore():
	var cfg= ConfigFile.new()
	var err: Error=cfg.load(hsPath)
	if err:
		print(err)
		return 0
	
	var hs := 0
	
	if cfg.has_section_key(hs_section,hs_key):
		hs=cfg.get_value(hs_section,hs_key) 

	return hs

func set_hScore(hs:float) -> void:
	var cfg = ConfigFile.new()
	if cfg.load(hsPath): # It returns an error, this means "if there's no file:"
		cfg = ConfigFile.new() # Empty file ONLY if there is no file to be read
	cfg.set_value(hs_section,hs_key, hs)
	print(cfg.save(hsPath))

func quit():
	get_tree().quit()

func refresh_scene() -> void:
	print("")
	print_rich("[b]Reloading! //////////////////////////////////[/b]")
	get_tree().reload_current_scene()

func asteroid_increase() -> void:
	asteroid_increase_timer.start(asteroidIncreaseWait)
	minimumAsteroidCount+=1
	maximumAsteroidCount+=1
	print("---------------------------")
	print("Minimum Asteroid Count: "+str(minimumAsteroidCount))
	print("Maximum Asteroid Count: "+str(maximumAsteroidCount))


func to_settings():
	get_tree().change_scene_to_file("res://scenes/settings_screen.tscn")


func update_hs_sect_key() -> void:
	hs_section = "High Score"
	var dict := GameManager.DEFAULT_OPTIONS.merged(GameManager.options, true)
	for option in GameManager.NON_GAMEPLAY_SETTINGS:
		dict.erase(option)
	dict.sort()
	hs_key = str(dict)
