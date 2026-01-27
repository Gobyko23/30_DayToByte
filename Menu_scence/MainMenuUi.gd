extends Control

@onready var OptionLabel := $".."

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_start_button_pressed() -> void:
	SceneLoader.load_scene("res://Scence/Stage/MainGame_OutSide.tscn")


func _on_option_button_pressed() -> void:
	$Option.visible = !$Option.visible

func _on_back_button_pressed() -> void:
	OptionLabel.visible = !OptionLabel.visible
