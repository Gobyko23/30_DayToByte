extends Node
class_name SaveManager

const SAVE_DIR := "user://saves/"
const SAVE_VERSION := 1
signal request_save(slot: int)
signal request_load(slot: int)
# -------------------------
func save_game(slot: int, player: Node3D) -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

	var data := {
		"version": SAVE_VERSION,
		"scene": get_tree().current_scene.scene_file_path,

		"player": {
			"money": PlayerData.money,
			"position": {
				"x": player.global_position.x,
				"y": player.global_position.y,
				"z": player.global_position.z
			}
		},

		"time": {
			"day": TimeManager.day,
			"hour": TimeManager.hour,
			"minute": TimeManager.minute
		}
	}

	var path := SAVE_DIR + "slot_%d.json" % slot
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

	print("✅ Saved slot", slot)

# -------------------------
func load_game(slot: int) -> Dictionary:
	if not slot_exists(slot):
		return {}

	var file := FileAccess.open(SAVE_DIR + "slot_%d.json" % slot, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(data) != TYPE_DICTIONARY:
		return {}

	return data

#------------------------------------------------------------
func slot_exists(slot: int) -> bool:
	var path := SAVE_DIR + "slot_%d.json" % slot
	return FileAccess.file_exists(path)
#----------------------------------------------------------
func save_selected_slot(slot: int, player: Node3D) -> void:
	save_game(slot, player)
#----------------------------------------------------------------
func get_all_slots() -> Array[int]:
	var slots: Array[int] = []
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		return slots

	var dir := DirAccess.open(SAVE_DIR)
	dir.list_dir_begin()

	var file := dir.get_next()
	while file != "":
		if file.begins_with("slot_") and file.ends_with(".json"):
			var id := file.replace("slot_", "").replace(".json", "").to_int()
			slots.append(id)
		file = dir.get_next()

	dir.list_dir_end()
	slots.sort()
	return slots
