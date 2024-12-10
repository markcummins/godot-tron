extends Control

@onready var button: Button = $Button

signal restartGame

func _on_button_pressed() -> void:
	restartGame.emit()
