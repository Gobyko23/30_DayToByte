extends Node

# ข้อมูลไอเทมที่อยู่ในเกม (ใช้สำหรับเก็บข้อมูลไอเทมในฉาก)
var item_data: Dictionary = {}

# สัญญาณส่งออกข้อมูล
signal item_data_changed
signal item_added(item_name: String, item_info: Dictionary)
signal item_removed(item_name: String)


func _ready() -> void:
	# ถ้าต้องการการเชื่อมต่ออื่น ๆ
	pass


# ฟังก์ชัน: เพิ่มไอเทมใหม่ลงในระบบ
func add_item(item_name: String, scene_path: String, position: Vector3) -> void:
	var item_info := {
		"name": item_name,
		"scene_path": scene_path,
		"pos_x": position.x,
		"pos_y": position.y,
		"pos_z": position.z,
		"added_time": Time.get_datetime_string_from_system()
	}
	
	item_data[item_name] = item_info
	item_added.emit(item_name, item_info)
	item_data_changed.emit()
	print("✅ Item added: ", item_name)


# ฟังก์ชัน: ลบไอเทม
func remove_item(item_name: String) -> void:
	if item_data.has(item_name):
		item_data.erase(item_name)
		item_removed.emit(item_name)
		item_data_changed.emit()
		print("🗑️ Item removed: ", item_name)


# ฟังก์ชัน: อัปเดตตำแหน่งไอเทม
func update_item_position(item_name: String, position: Vector3) -> void:
	if item_data.has(item_name):
		item_data[item_name]["pos_x"] = position.x
		item_data[item_name]["pos_y"] = position.y
		item_data[item_name]["pos_z"] = position.z
		item_data_changed.emit()


# ฟังก์ชัน: ดึงข้อมูลไอเทมทั้งหมด
func get_all_items() -> Array:
	var items_array: Array = []
	for item_name in item_data.keys():
		items_array.append(item_data[item_name])
	return items_array


# ฟังก์ชัน: ดึงข้อมูลไอเทมเดี่ยว
func get_item(item_name: String) -> Dictionary:
	if item_data.has(item_name):
		return item_data[item_name]
	return {}


# ฟังก์ชัน: ล้างข้อมูลไอเทมทั้งหมด
func clear_all_items() -> void:
	item_data.clear()
	item_data_changed.emit()
	print("🧹 All items cleared")


# ฟังก์ชัน: นำเข้าข้อมูลไอเทม (สำหรับระบบโหลด)
func load_items_data(items_array: Array) -> void:
	item_data.clear()
	if items_array is Array:
		for item_info in items_array:
			if item_info is Dictionary:
				if item_info.has("name") and item_info.has("scene_path"):
					item_data[item_info["name"]] = item_info
	item_data_changed.emit()
	print("📥 Items data loaded: ", item_data.size(), " items")


# ฟังก์ชัน: ส่งออกข้อมูลไอเทม (สำหรับระบบเซฟ)
func export_items_data() -> Array:
	return get_all_items()


# ฟังก์ชัน: ตรวจสอบว่ามีไอเทมอยู่หรือไม่
func has_item(item_name: String) -> bool:
	return item_data.has(item_name)


# ฟังก์ชัน: นับจำนวนไอเทม
func get_item_count() -> int:
	return item_data.size()


# ฟังก์ชัน: เก็บข้อมูลไอเทมจากกลุ่ม "persist_items" ในฉากปัจจุบัน
func sync_items_from_scene() -> void:
	item_data.clear()
	for item in get_tree().get_nodes_in_group("persist_items"):
		var item_info := {
			"name": item.name,
			"scene_path": item.scene_file_path,
			"pos_x": item.global_position.x,
			"pos_y": item.global_position.y,
			"pos_z": item.global_position.z
		}
		item_data[item.name] = item_info
	item_data_changed.emit()
	print("🔄 Scene items synchronized: ", item_data.size(), " items")
