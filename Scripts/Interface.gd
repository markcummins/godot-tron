extends Control

@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var enemies = get_tree().get_nodes_in_group("LightcycleBot").size()
	
	label.text = "FPS: " + str(Engine.get_frames_per_second())
	label.text += " Enemys: " + str(enemies)
