extends Node

const SAVE_DIR := "user://saves/"
const SAVE_VERSION := 1
signal request_save(slot: int)
signal request_load(slot: int)
signal save_finished

func _ready() -> void:
	request_save.connect(_on_request_save)
	request_load.connect(_on_request_load)

func save_game(slot: int, player: Node3D) -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR) 

	# ดึงข้อมูลไอเทมจาก ItemDataManager
	var saved_items = ItemDataManager.export_items_data()

	var data := {
		"version": SAVE_VERSION,
		"save_time": Time.get_datetime_string_from_system(), 
		"scene": get_tree().current_scene.scene_file_path, 
		"player": {
			"name": PlayerData.Name, 
			"money": CashSystem.money, 
			"position": {
				"x": player.global_position.x,
				"y": player.global_position.y,
				"z": player.global_position.z
			}
		},
		"items": saved_items, 
		"quests": QuestManager.export_quest_data(),
		"time": {
			"day": TimeManager.day, 
			"hour": TimeManager.hour, 
			"minute": TimeManager.minute 
		}
	}

	var path := SAVE_DIR + "slot_%d.json" % slot
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t")) 
		file.close()
		save_finished.emit()
		print("✅ Saved slot ", slot)
	else:
		push_error("❌ Cannot write file to: " + path)

func load_game(slot: int) -> Dictionary:
	var path := SAVE_DIR + "slot_%d.json" % slot
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ) 
	var json_string = file.get_as_text() 
	file.close()

	var data = JSON.parse_string(json_string) 
	if data == null or typeof(data) != TYPE_DICTIONARY:
		push_error("❌ Failed to parse JSON")
		return {}

	return data

func _on_request_load(slot: int) -> void:
	var data = load_game(slot)
	if data.is_empty(): return

	# 1. อัปเดตเงิน
	if data.has("player") and data["player"].has("money"):
		CashSystem.set_money(int(data["player"]["money"])) 
	
	# 2. อัปเดตตำแหน่ง Player
	var player = get_tree().current_scene.find_child("Player", true, false) 
	if player and data["player"].has("position"):
		var pos = data["player"]["position"] 
		player.global_position = Vector3(pos.x, pos.y, pos.z) 

	# 3. คืนค่าสถานะไอเทม
	# ลบไอเทมเก่าในฉากออกก่อน
	for old_item in get_tree().get_nodes_in_group("persist_items"):
		old_item.queue_free()

	# โหลดข้อมูลไอเทมไปยัง ItemDataManager
	if data.has("items") and data["items"] is Array:
		var items_array: Array = data["items"]
		ItemDataManager.load_items_data(items_array)
		
		# สร้างไอเทมใหม่ตามรายการในไฟล์เซฟ
		for item_info in items_array:
			if item_info is Dictionary:
				var item_scene = load(item_info["scene_path"])
				if item_scene:
					var inst = item_scene.instantiate()
					inst.name = item_info["name"]
					inst.global_position = Vector3(item_info["pos_x"], item_info["pos_y"], item_info["pos_z"])
					inst.add_to_group("persist_items")
					get_tree().current_scene.add_child(inst)

	# 4. โหลดข้อมูล Quest
	if data.has("quests") and data["quests"] is Dictionary:
		QuestManager.load_quest_data(data["quests"])

func _on_request_save(slot: int) -> void:
	var player = get_tree().current_scene.find_child("Player", true, false) 
	if player:
		save_game(slot, player) 

func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_DIR + "slot_%d.json" % slot)