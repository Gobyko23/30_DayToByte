extends Control


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_option_button_pressed() -> void:
	pass

func _on_start_button_pressed() -> void:
	SceneLoader.load_scene("res://Scence/MainGame_OutSide.tscn")
