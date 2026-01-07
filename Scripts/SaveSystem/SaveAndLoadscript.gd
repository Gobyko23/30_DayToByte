extends Node
class_name SaveManager

const SAVE_DIR := "user://saves/"
const SAVE_VERSION := 1
var GlobalCurrentSlot :int= 0
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
	var path := SAVE_DIR + "slot_%d.json" % slot
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()

	return data
