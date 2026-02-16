extends Control

# เก็บสถานะชิ้นส่วนที่ใส่เข้าไปแล้ว { "cpu": "CPU_Intel_i5", "gpu": null, ... }
var current_build: Dictionary = {
	"MainBoard": null,
	"CPU": null,
	"RAM": null,
	"GPU": null,
	"PowerSupply": null,
	"Fan": null,    
	"Case": null    
}

# อ้างอิง Node UI (ต้องลากมาใส่เองใน Editor)
@onready var success_sfx: AudioStreamPlayer = %SuccessSFX
@onready var status_label = $StatusLabel
var current_npc: NPC = null
var slots: Dictionary = {}


func _ready():
	slots = {
		"MainBoard": %Slot_MainBoard,
		"CPU": %Slot_CPU,
		"GPU": %Slot_GPU,
		"RAM": %Slot_RAM,
		"PowerSupply": %Slot_PSU,
		"Fan": %Slot_Fan,
		"Case": %Slot_Case
	}
	print("🔍 ตรวจสอบ Slot CPU: ", %Slot_CPU)
	update_build_status()

func _process(delta):
	var npc_nodes = get_tree().get_nodes_in_group("Npc")
	for npc in npc_nodes:
		if not npc:
			continue

# 2. ฟังก์ชันตรวจสอบ Compatibility (หัวใจสำคัญ)
func check_compatibility(part_category: String, item_id: String) -> String:
	var new_part_data = HardwareSpecs.get_specs(item_id)
	
	# กฎที่ 1: ต้องใส่ Mainboard ก่อนใส่ CPU/RAM/GPU
	if part_category != "MainBoard" and part_category != "PowerSupply" and part_category != "Case":
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
# ฟังก์ชันตรวจสอบว่าประกอบครบหรือยัง
func is_build_complete() -> bool:
	for category in current_build:
		if current_build[category] == null:
			# ถ้ามีแม้แต่ชิ้นเดียวที่เป็น null แปลว่ายังไม่ครบ
			return false
	return true

# ใน NPC_Scirpt.gd (ตรงจุดที่คุณสั่งเปิดหน้าประกอบคอม)
func open_pc_builder():
	var manager = get_tree().get_first_node_in_group("PCBuilderManager")
	if manager:
		manager.current_npc = self  # ✅ ส่งตัวเองไปให้ Manager จำไว้
		manager.visible = true      # เปิดหน้าจอประกอบคอม

# ใน PCBuilderManager.gd

func _on_accept_btn_pc_pressed() -> void:
	if is_build_complete():
		# ✅ ใช้ current_npc ที่ได้มาจากการฝากไว้ตอนเปิดเครื่อง
		if current_npc and current_npc.quest_system:
			var success = current_npc.quest_system.complete_pc_build_quest()
			
			if success:
				print("✅ ประกอบคอมส่งงานสำเร็จ!")
				success_sfx.play()
				status_label.text = "[color=green]สำเร็จ![/color]"
				await get_tree().create_timer(1.0).timeout # รอเสียงเล่นจบก่อนค่อยปิด
				self.visible = false
				current_npc = null # เคลียร์ค่าออกเมื่อจบงาน
				
			else:
				print("❌ เงื่อนไขเควสไม่ถูกต้อง")
		else:
			# ถ้า current_npc เป็น null ให้ลองหาจากกลุ่ม ActiveNPC เป็นแผนสำรอง
			var active_npcs = get_tree().get_nodes_in_group("ActiveNPC")
			if active_npcs.size() > 0:
				current_npc = active_npcs[0]
				_on_accept_btn_pc_pressed() # รันฟังก์ชันซ้ำอีกรอบ
			else:
				status_label.text = "[color=red]ไม่พบข้อมูลลูกค้า![/color]"
	else:
		status_label.text = "[color=yellow]ยังติดตั้งอุปกรณ์ไม่ครบ![/color]"

# ใน PCBuilderManager.gd

# ใน PCBuiderManger.gd

func _on_cancle_btn_pc_pressed() -> void:
	print("--- เริ่มกระบวนการ Cancel ---")
	
	# 1. คืนของ (รันได้ปกติ)
	for category in current_build.keys():
		if current_build[category] != null:
			InventorySystem.update_item(current_build[category], 1)
			current_build[category] = null
			
	# 2. รีเซ็ต Slot
	for slot_name in slots.keys():
		var slot_node = slots[slot_name]
		
		# ตรวจสอบว่า slot_node ไม่ใช่ null
		if slot_node != null:
			if slot_node.has_method("reset_slot"):
				slot_node.reset_slot()
			else:
				# กรณีฉุกเฉิน: ถ้าหา func ไม่เจอแต่มี Node ให้ล้างมือเองเลย
				slot_node.texture = null
				slot_node.visible = false
		else:
			print("⚠️ คำเตือน: ระบบยังหา Node '", slot_name, "' ไม่เจอ (Null)")

	update_build_status()
	self.visible = false
