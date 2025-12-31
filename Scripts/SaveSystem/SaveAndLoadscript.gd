extends Node

const SAVE_PATH := "user://savegame.json"

var Save_Content :Dictionary= {
	"money": 0
}


func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("❌ Save failed")
		return
		
	file.store_var(Save_Content.duplicate())
	file.close()
	print("✅ Game Saved")


func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("⚠️ No save file")
		return {}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = file.get_var()
	file.close()
	var save_curren_data = data.duplicate()
	Save_Content.money = save_curren_data.money
