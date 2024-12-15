extends Node

class_name GameManager

@onready var game: Node3D = $"../../Game"

@onready var game_start_screen: Control = $"../../GameStart/GameStartScreen"
@onready var light_cycle_scene_player: Node3D = $"../../Game/LightCycleScenePlayer/LightCyclePlayer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_start_screen.visible = false
	
	Engine.time_scale = 1
	if(light_cycle_scene_player):
		light_cycle_scene_player.on_player_died.connect(player_died)
		game_start_screen.restartGame.connect(restart)

func restart():
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func player_died():
	game_start_screen.visible = true
	get_tree().paused = true	
