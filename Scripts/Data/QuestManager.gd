extends Node

# ระบบจัดการ Quest ทั้งหมด
var active_quests: Dictionary = {}  # quest_id -> QuestData
var completed_quests: Array[String] = []

# สัญญาณ
signal quest_started(quest_id: String)
signal quest_completed(quest_id: String, reward_money: int)
signal quest_cancelled(quest_id: String)
signal quest_updated

func _ready() -> void:
	add_to_group("Autoload")


# ฟังก์ชัน: เริ่ม Quest
func start_quest(quest: QuestData) -> void:
	if not active_quests.has(quest.quest_id):
		quest.reset_quest_data()
		quest.activate_quest()
		active_quests[quest.quest_id] = quest
		quest_started.emit(quest.quest_id)
		print("✅ Quest started: ", quest.quest_name)
		quest_updated.emit()


# ฟังก์ชัน: สำเร็จ Quest
func complete_quest(quest_id: String) -> void:
	if completed_quests.has(quest_id):
		print("ℹ️ Quest %s is already completed. Skipping reward." % quest_id)
		return

	if active_quests.has(quest_id):
		var quest = active_quests[quest_id]
		quest.complete_quest()
        
        # จ่ายรางวัล (จะทำงานแค่ครั้งเดียวแน่นอนเพราะมีเช็คด้านบน)
		if quest.reward_money > 0:
			PointSystem.add(quest.reward_money)
			print("💰 Received: ", quest.reward_money, " points")
        
		completed_quests.append(quest_id)
		active_quests.erase(quest_id)
		quest_completed.emit(quest_id, quest.reward_money)
		quest_updated.emit()


# ฟังก์ชัน: ยกเลิก Quest
func cancel_quest(quest_id: String) -> void:
	if active_quests.has(quest_id):
		var quest = active_quests[quest_id]
		quest.cancel_quest()
		active_quests.erase(quest_id)
		
		quest_cancelled.emit(quest_id)
		print("❌ Quest cancelled: ", quest.quest_name)
		quest_updated.emit()


# ฟังก์ชัน: ดึง Quest ที่กำลังทำ
func get_active_quest(quest_id: String) -> QuestData:
	if active_quests.has(quest_id):
		return active_quests[quest_id]
	return null


# ฟังก์ชัน: ดึง Quest ทั้งหมดที่กำลังทำ
func get_all_active_quests() -> Array[QuestData]:
	var quests: Array[QuestData] = []
	for quest in active_quests.values():
		quests.append(quest)
	return quests


# ฟังก์ชัน: ตรวจสอบว่า Quest เสร็จสิ้นแล้วหรือไม่
func is_quest_completed(quest_id: String) -> bool:
	return quest_id in completed_quests


# ฟังก์ชัน: ตรวจสอบว่า Quest กำลังทำหรือไม่
func is_quest_active(quest_id: String) -> bool:
	return active_quests.has(quest_id)


# ฟังก์ชัน: อัปเดตความคืบหน้า Quest
func update_quest_progress(quest_id: String, progress: int) -> void:
	if active_quests.has(quest_id):
		active_quests[quest_id].progress = progress
		quest_updated.emit()
		print("🔄 Quest progress updated: ", quest_id, " -> ", progress)


# ฟังก์ชัน: ดึงข้อมูล Quest ทั้งหมด
func export_quest_data() -> Dictionary:
	var data := {
		"active_quests": [],
		"completed_quests": completed_quests
	}
	
	for quest in active_quests.values():
		data["active_quests"].append(quest.get_quest_info())
	
	return data


# ฟังก์ชัน: โหลดข้อมูล Quest จากไฟล์บันทึก
func load_quest_data(data: Dictionary) -> void:
	if data.has("completed_quests"):
		var loaded_quests = data["completed_quests"]
		if loaded_quests is Array:
			completed_quests = []
			for quest_id in loaded_quests:
				completed_quests.append(str(quest_id))
	print("📥 Quest data loaded")

func add_progress(target_id: String, amount: int = 1) -> void:
	for quest_id in active_quests:
		var quest = active_quests[quest_id]
		# ตรวจสอบว่าเควสที่ผู้เล่นถืออยู่ ต้องการ target_id นี้หรือไม่
		if quest.target_item_id == target_id:
			quest.current_amount += amount
			print("📈 Progress: ", quest.quest_name, " (", quest.current_amount, "/", quest.required_amount, ")")
			
			# แจ้งเตือน UI ให้รู้ว่ามีการเปลี่ยนแปลง (เช่นไปอัปเดต Label ใน pause.gd)
			quest_updated.emit()

func reset_system() -> void:
	# 1. รีเซ็ตค่าใน QuestData ของทุกเควสที่กำลังทำอยู่ (Active)
	for quest_id in active_quests:
		active_quests[quest_id].reset_quest_data()

	active_quests.clear()
	completed_quests.clear()
	quest_updated.emit()
	print("🔄 QuestManager has been reset")

