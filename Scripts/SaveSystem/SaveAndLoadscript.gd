extends Node

const SAVE_DIR := "user://saves/"
const SAVE_VERSION := 1
signal request_save(slot: int)
signal request_load(slot: int)
signal save_finished

func _ready() -> void:
	request_save.connect(_on_request_save)
	request_load.connect(_on_request_load)

func save_game(slot: int, player: Node3D, time_node: Node) -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR) 

	# ดึงข้อมูลไอเทมจาก ItemDataManager
	var saved_items = ItemDataManager.export_items_data()
	
	# ดึงข้อมูล Inventory (ไอเทมที่เก็บไว้ในเกม)
	var saved_inventory = InventorySystem.Inventory.duplicate()
	
	# ดึงข้อมูล NPC (ถ้า NPCManager ได้ load แล้ว)
	var saved_npcs = {}
	if get_node_or_null("/root/NPCManager"):
		saved_npcs = get_node("/root/NPCManager").export_npc_data()

	var data := {
		"version": SAVE_VERSION,
		"save_time": Time.get_datetime_string_from_system(), 
		"scene": get_tree().current_scene.scene_file_path, 
		"player": {
			"name": PlayerData.Name, 
			"points": PointSystem.points, 
			"position": {
				"x": player.global_position.x,
				"y": player.global_position.y,
				"z": player.global_position.z
			}
		},
		"items": saved_items,
		"inventory": saved_inventory, 
		"quests": QuestManager.export_quest_data(),
		"npcs": saved_npcs,
		"time": time_node.export_time_data(),
		"npc_question_states": _export_npc_question_states()
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

func _on_request_load(slot: int, time_node: Node) -> void:
	var data = load_game(slot)
	if data.is_empty(): 
		print("❌ No save data found for slot: ", slot)
		return

	# 0. ล้างข้อมูลเก่าทั้งหมด ก่อนโหลดใหม่
	print("🧹 Clearing old game data...")
	
	# ล้างคะแนน
	PointSystem.set_points(0)
	
	# ล้าง Inventory
	InventorySystem.Inventory.clear()
	
	# ล้าง ItemDataManager
	ItemDataManager.clear_all_items()
	
	# ล้างไอเทมเก่าในฉาก
	for old_item in get_tree().get_nodes_in_group("persist_items"):
		old_item.queue_free()
	
	# ล้าง NPC state
	if get_node_or_null("/root/NPCManager"):
		print("🧹 Clearing NPC Manager data...")
		get_node("/root/NPCManager").reset_all_npc_states()
	
	# ล้าง Quest data
	if get_node_or_null("/root/QuestManager"):
		print("🧹 Clearing Quest Manager data...")
		var quest_manager = get_node("/root/QuestManager")
		quest_manager.active_quests.clear()
		quest_manager.completed_quests.clear()
	
	await get_tree().process_frame  # รอให้ item ถูกลบจริง

	# 1. โหลดคะแนนใหม่
	if data.has("player") and data["player"].has("points"):
		PointSystem.set_points(int(data["player"]["points"]))
		print("✅ Points restored: ", PointSystem.points)
	
	# 2. อัปเดตตำแหน่ง Player
	var player = get_tree().current_scene.find_child("Player", true, false) 
	if player and data["player"].has("position"):
		var pos = data["player"]["position"] 
		player.global_position = Vector3(pos.x, pos.y, pos.z)
		print("✅ Player position restored: ", player.global_position)

	# 3. คืนค่า Inventory (ไอเทมที่เก็บไว้)
	if data.has("inventory") and data["inventory"] is Dictionary:
		for item_name in data["inventory"].keys():
			InventorySystem.Inventory[item_name] = int(data["inventory"][item_name])
		InventorySystem.emit_signal("inventory_changed")
		print("✅ Inventory restored: ", InventorySystem.Inventory)

	# 4. โหลดข้อมูลไอเทมไปยัง ItemDataManager
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
		print("✅ Scene items restored: ", items_array.size(), " items")

	# 5. โหลดข้อมูล Quest
	if data.has("quests") and data["quests"] is Dictionary:
		QuestManager.load_quest_data(data["quests"])
		print("✅ Quest data restored")
	
	# 6. โหลดข้อมูล Time จาก time_node instance
	if data.has("time") and data["time"] is Dictionary:
		time_node.load_time_data(data["time"])
		print("⏰ Time data restored")
	
	# 7. โหลดข้อมูล NPC
	if data.has("npcs") and data["npcs"] is Dictionary and get_node_or_null("/root/NPCManager"):
		print("📥 Loading NPC data...")
		get_node("/root/NPCManager").load_npc_data(data["npcs"])
		# เรียก _restore_state_from_npc_manager ให้ NPC instances restore state
		print("🔄 Restoring NPC states...")
		_restore_all_npc_states()
		print("✅ NPC states restored!")
	
	# 8. โหลดข้อมูล Question states
	if data.has("npc_question_states") and data["npc_question_states"] is Dictionary:
		print("📥 Loading NPC question states...")
		_restore_npc_question_states(data["npc_question_states"])
		print("✅ NPC question states restored!")
	
	print("✅ Game loaded from slot: ", slot)


func _restore_all_npc_states() -> void:
	# ค้นหา NPC ทั้งหมดในฉากที่มี NPCQuestSystem
	_find_and_restore_npc_states(get_tree().current_scene)


func _find_and_restore_npc_states(node: Node) -> void:
	# ตรวจสอบ node ปัจจุบัน
	if node is NPCQuestSystem:
		print("🔍 Found NPC node: ", node.name, " - restoring state")
		node._restore_state_from_npc_manager()
	
	# วนลูปค้นหาใน children
	for child in node.get_children():
		_find_and_restore_npc_states(child)

# ฟังก์ชัน: ส่งออกสถานะคำถาม NPC
func _export_npc_question_states() -> Dictionary:
	var states := {}
	var current_scene = get_tree().current_scene
	_collect_npc_question_states(current_scene, states)
	return states

func _collect_npc_question_states(node: Node, states: Dictionary) -> void:
	# ตรวจสอบว่า node นี้เป็น NPC หรือมี quest_system
	if node.has_meta("is_npc") or (node.is_in_group("NPC") if node.is_in_group("NPC") else false):
		if node.has_node("NPCQuestSystem"):
			var quest_system = node.get_node("NPCQuestSystem")
			var npc_name = quest_system.npc_name
			states[npc_name] = {
				"is_question_answered": quest_system.is_question_answered
			}
			print("💾 Saved question state for NPC: ", npc_name, " - answered: ", quest_system.is_question_answered)
	
	# วนลูปค้นหาใน children
	for child in node.get_children():
		_collect_npc_question_states(child, states)

# ฟังก์ชัน: โหลดสถานะคำถาม NPC
func _restore_npc_question_states(states: Dictionary) -> void:
	if states.is_empty(): return
	
	var current_scene = get_tree().current_scene
	_apply_npc_question_states(current_scene, states)

func _apply_npc_question_states(node: Node, states: Dictionary) -> void:
	# ตรวจสอบว่า node นี้เป็น NPC หรือมี quest_system
	if node.has_node("NPCQuestSystem"):
		var quest_system = node.get_node("NPCQuestSystem")
		var npc_name = quest_system.npc_name
		
		if states.has(npc_name):
			var state_data = states[npc_name]
			if state_data.has("is_question_answered"):
				quest_system.is_question_answered = state_data["is_question_answered"]
				print("✅ Restored question state for NPC: ", npc_name, " - answered: ", quest_system.is_question_answered)
	
	# วนลูปค้นหาใน children
	for child in node.get_children():
		_apply_npc_question_states(child, states)

func _on_request_save(slot: int) -> void:
	var player = get_tree().current_scene.find_child("Player", true, false)
	var time_node = get_tree().current_scene.find_child("TimeNode", true, false)
	if player and time_node:
		save_game(slot, player, time_node) 

func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_DIR + "slot_%d.json" % slot)
