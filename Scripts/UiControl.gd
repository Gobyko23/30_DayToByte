extends Control



func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_option_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scence/Option.tscn")

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scence/Main_Game.tscn")


func _on_save_button_pressed() -> void:
	SaveAndLoad.Save_Content["money"] = CashSystem.money
	SaveAndLoad.save_game()
	print("Save!")


func _on_load_button_pressed() -> void:
	SaveAndLoad.load_game()
	CashSystem.money = SaveAndLoad.Save_Content["money"]
	$Cash_Label.text = "%d $" % (SaveAndLoad.Save_Content["money"]) 
