extends Control

var maxSlot :int= 3
var currentSlot :int= 0

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_option_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scence/Option.tscn")

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scence/Main_Game.tscn")


func _on_save_button_pressed() -> void:
	if currentSlot < maxSlot:
		SaveAndLoad.GlobalCurrentSlot += 1
		print("Save!")
	else:
		print("Slot is Max")

func _on_load_button_pressed() -> void:
	SaveAndLoad.load_game(1)
