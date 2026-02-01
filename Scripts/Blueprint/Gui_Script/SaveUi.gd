extends Control

@export var slot_id: int = 1



func _on_save_button_pressed() -> void: #Save
	SaveAndLoad.request_save.emit(PlayerData.GlobalSaveSlot)
	print("Sent save request...")
	
func _on_load_button_pressed() -> void: #Load
	SaveAndLoad.request_load.emit(PlayerData.GlobalSaveSlot)
	SceneLoader.load_scene("res://Scence/Stage/MainGame_OutSide.tscn")

