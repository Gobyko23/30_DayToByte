extends Control


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_option_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scence/Option.tscn")

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scence/Main_Game.tscn")
