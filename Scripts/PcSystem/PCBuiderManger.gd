extends Control

# เก็บสถานะชิ้นส่วนที่ใส่เข้าไปแล้ว { "cpu": "CPU_Intel_i5", "gpu": null, ... }
var current_build: Dictionary = {
	"MainBoard": null,
	"CPU": null,
	"RAM": null,
	"GPU": null,
	"PowerSupply": null
}

# อ้างอิง Node UI (ต้องลากมาใส่เองใน Editor)
@onready var inventory_container = $HBoxContainer/InventoryPanel/GridContainer
@onready var status_label = $StatusLabel
@onready var slots = {
	"MainBoard": $CaseArea/Slot_MainBoard,
	"CPU": $CaseArea/Slot_CPU,
	"GPU": $CaseArea/Slot_GPU,
	"RAM": $CaseArea/Slot_RAM,
	"PowerSupply": $CaseArea/Slot_PSU
}

func _ready():
	refresh_inventory_ui()
	update_build_status()

# 1. โหลดของจาก Inventory_System มาแสดง
func refresh_inventory_ui():
	# เคลียร์ของเก่าใน UI
	for child in inventory_container.get_children():
		child.queue_free()
	
	# วนลูปของในกระเป๋า
	for item_id in InventorySystem.Inventory.keys():
		var amount = InventorySystem.Inventory[item_id]
		if amount > 0:
			create_inventory_slot(item_id, amount)

func create_inventory_slot(item_id: String, amount: int):
	# สร้างปุ่มหรือไอคอนสำหรับลาก (Drag Source)
	var btn = Button.new()
	btn.text = item_id + " (x" + str(amount) + ")"
	# ตรงนี้ต้องเขียน script ย่อยให้ปุ่มเพื่อรองรับ get_drag_data()
	btn.set_script(load("res://Scripts/DraggableItem.gd")) 
	btn.set_meta("item_id", item_id)
	inventory_container.add_child(btn)

# 2. ฟังก์ชันตรวจสอบ Compatibility (หัวใจสำคัญ)
func check_compatibility(part_category: String, item_id: String) -> String:
	var new_part_data = HardwareSpecs.get_specs(item_id)
	
	# กฎที่ 1: ต้องใส่ Mainboard ก่อนใส่ CPU/RAM/GPU
	if part_category != "MainBoard" and part_category != "PowerSupply":
		if current_build["MainBoard"] == null:
			return "ต้องติดตั้ง Mainboard ก่อน!"
			
	# กฎที่ 2: CPU Socket ต้องตรงกับ Mainboard
	if part_category == "CPU":
		var mobo_id = current_build["MainBoard"]
		var mobo_data = HardwareSpecs.get_specs(mobo_id)
		if new_part_data.get("socket") != mobo_data.get("socket"):
			return "Socket ไม่ตรงกัน! (" + str(new_part_data.get("socket")) + " vs " + str(mobo_data.get("socket")) + ")"

	return "OK"

# 3. ฟังก์ชันติดตั้งอุปกรณ์ (เรียกเมื่อ Drop สำเร็จ)
func install_part(category: String, item_id: String):
	# เช็คความเข้ากันได้
	var check_result = check_compatibility(category, item_id)
	if check_result != "OK":
		print("Error: ", check_result)
		# อาจจะเด้ง Popup แจ้งเตือนผู้เล่นตรงนี้
		return

	# คืนของเก่าเข้ากระเป๋า (ถ้ามีใส่คาไว้อยู่)
	if current_build[category] != null:
		InventorySystem.update_item(current_build[category], 1)
	
	# ตัดของใหม่ออกจากกระเป๋า
	InventorySystem.update_item(item_id, -1)
	
	# อัปเดต Build
	current_build[category] = item_id
	
	# อัปเดต UI Slot ให้เปลี่ยนรูป
	# slots[category].texture = load("res://Path/To/Icon.png") 
	
	refresh_inventory_ui()
	update_build_status()

# 4. คำนวณ Wattage รวม
func update_build_status():
	var total_tdp = 0
	var psu_wattage = 0
	
	if current_build["CPU"]: 
		total_tdp += HardwareSpecs.get_specs(current_build["CPU"]).get("tdp", 0)
	if current_build["GPU"]:
		total_tdp += HardwareSpecs.get_specs(current_build["GPU"]).get("tdp", 0)
		
	if current_build["PowerSupply"]:
		psu_wattage = HardwareSpecs.get_specs(current_build["PowerSupply"]).get("wattage", 0)
		
	status_label.text = "Power Usage: " + str(total_tdp) + "W / " + str(psu_wattage) + "W"
	
	if total_tdp > psu_wattage:
		status_label.modulate = Color.RED # ไฟไม่พอ!
	else:
		status_label.modulate = Color.GREEN