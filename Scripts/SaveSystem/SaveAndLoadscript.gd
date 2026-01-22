extends Node


const SAVE_DIR := "user://saves/"
const SAVE_VERSION := 1
signal request_save(slot: int)
signal request_load(slot: int)
signal save_finished
# -------------------------
func _ready() -> void:
	# เชื่อมต่อ Signal เข้ากับฟังก์ชันในตัวเอง
	request_save.connect(_on_request_save)
	request_load.connect(_on_request_load)
# ... signals ...

func save_game(slot: int, player: Node3D) -> void:
	# ตรวจสอบและสร้างโฟลเดอร์ถ้ายังไม่มี
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

	var data := {
		"version": SAVE_VERSION,
		"save_time": Time.get_datetime_string_from_system(), # เพิ่มเวลาที่เซฟจริงเข้าไปด้วย
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
		push_error("❌ Failed to parse JSON or data is not a Dictionary")
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

#----------------------------------------------------------------
func get_all_slots() -> Array[int]:
	var result: Array[int] = []

	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		return result

	var dir := DirAccess.open(SAVE_DIR)
	dir.list_dir_begin()

	var file := dir.get_next()
	while file != "":
		if file.begins_with("slot_") and file.ends_with(".json"):
			var id := file.replace("slot_", "").replace(".json", "").to_int()
			result.append(id)
		file = dir.get_next()

	dir.list_dir_end()
	result.sort()
	return result

func _on_request_save(slot: int) -> void:
	# ต้องหาตัวละคร Player ในฉากเพื่อเอาตำแหน่ง (สมมติว่าชื่อ Player)
	var player = get_tree().current_scene.find_child("Player", true, false)
	if player:
		save_game(slot, player)

func _on_request_load(slot: int) -> void:
	var data = load_game(slot)
	if not data.is_empty():
		# --- จุดสำคัญ: อัปเดตเงินเข้าสู่ระบบ ---
		if data.has("player") and data["player"].has("money"):
			CashSystem.set_money(int(data["player"]["money"]))
			print("💰 Signal Load: Money updated to ", data["player"]["money"])
		
		# --- อัปเดตตำแหน่ง Player ---
		var player = get_tree().current_scene.find_child("Player", true, false)
		if player and data["player"].has("position"):
			var pos = data["player"]["position"]
			player.global_position = Vector3(pos.x, pos.y, pos.z)
	
