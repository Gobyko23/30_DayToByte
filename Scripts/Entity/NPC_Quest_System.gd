extends Node
class_name NPCQuestSystem

# ประเภท NPC
enum NPC_TYPE {
	DIALOGUE_ONLY,     # NPC แบบคุยอย่างเดียว
	QUEST_GIVER        # NPC ให้เควส
}

# ตัวแปรทั่วไป
@export var npc_type: NPC_TYPE = NPC_TYPE.DIALOGUE_ONLY
@export var npc_name: String = "NPC"

# สำหรับ Quest Giver
@export var quest_list: Array[QuestData] = []  # รายการ Quest ที่ NPC ให้ได้
@export var give_quest_dialogue: Array[String] = ["คุณต้องการเควสหรือไม่?"]
@export var complete_quest_dialogue: Array[String] = ["ขอบคุณที่ทำให้เสร็จ!"]
@export var reward_dialogue: Array[String] = ["นี่คือรางวัล!"]

var current_quest: QuestData = null
var dialogue_index: int = 0


func _ready() -> void:
	pass


# ฟังก์ชัน: ตรวจสอบประเภท NPC
func is_quest_giver() -> bool:
	return npc_type == NPC_TYPE.QUEST_GIVER


# ฟังก์ชัน: ตรวจสอบว่าเป็น Dialogue Only
func is_dialogue_only() -> bool:
	return npc_type == NPC_TYPE.DIALOGUE_ONLY


# ฟังก์ชัน: เปลี่ยนประเภท NPC
func change_npc_type(new_type: NPC_TYPE) -> void:
	npc_type = new_type
	print("🔄 NPC type changed to: ", NPC_TYPE.keys()[npc_type])


# ฟังก์ชัน: เปิดไดอะล็อกของ NPC
func get_dialogue() -> String:
	if is_quest_giver():
		return get_quest_dialogue()
	else:
		return "Dialog Only"


# ============= ส่วน Quest System =============

# ฟังก์ชัน: ดึงไดอะล็อกตามสถานะ Quest
func get_quest_dialogue() -> String:
	# ถ้าไม่มี quest ให้บอกให้เลือก
	if quest_list.is_empty():
		return "ผมไม่มีเควสให้ในตอนนี้"
	
	# ถ้ากำลังรับ quest
	if current_quest == null:
		if give_quest_dialogue.size() > 0:
			return give_quest_dialogue[0]
		return "ฉันมีเควสสำหรับคุณ"
	
	# ถ้า quest ยังไม่เสร็จ
	if not current_quest.is_completed:
		return "คุณยังไม่เสร็จเควสของฉัน"
	
	# ถ้า quest เสร็จแล้ว
	if complete_quest_dialogue.size() > 0:
		return complete_quest_dialogue[0]
	return "ขอบคุณที่ทำให้เสร็จ!"


# ฟังก์ชัน: ให้ quest แก่ผู้เล่น
func give_quest() -> QuestData:
	if not is_quest_giver():
		print("❌ NPC นี้ไม่ใช่ Quest Giver")
		return null
	
	# ดึง quest แรก หรือ quest ที่ยังไม่ได้รับ
	for quest in quest_list:
		if not QuestManager.is_quest_completed(quest.quest_id) and not QuestManager.is_quest_active(quest.quest_id):
			current_quest = quest
			QuestManager.start_quest(quest)
			print("✅ Quest given: ", quest.quest_name)
			return quest
	
	return null


# ฟังก์ชัน: ตรวจสอบว่าผู้เล่นทำ quest เสร็จแล้วหรือไม่
func check_quest_completion() -> bool:
	if current_quest == null:
		return false
	
	if QuestManager.is_quest_completed(current_quest.quest_id):
		return true
	
	return false


# ฟังก์ชัน: เสร็จสิ้น quest
func complete_quest_reward() -> void:
	if current_quest == null:
		return
	
	QuestManager.complete_quest(current_quest.quest_id)
	current_quest = null
	print("✅ Quest reward given")


# ฟังก์ชัน: เพิ่ม Quest ให้ NPC
func add_quest(quest: QuestData) -> void:
	if not quest_list.has(quest):
		quest_list.append(quest)
		print("✅ Quest added to NPC: ", quest.quest_name)


# ฟังก์ชัน: ลบ Quest ออกจาก NPC
func remove_quest(quest_id: String) -> void:
	for i in range(quest_list.size()):
		if quest_list[i].quest_id == quest_id:
			quest_list.remove_at(i)
			print("🗑️ Quest removed: ", quest_id)
			return


# ฟังก์ชัน: ดึง Quest ทั้งหมด
func get_all_quests() -> Array[QuestData]:
	return quest_list


# ฟังก์ชัน: ดึงจำนวน Quest
func get_quest_count() -> int:
	return quest_list.size()


# ฟังก์ชัน: ดึง Quest ตาม ID
func get_quest_by_id(quest_id: String) -> QuestData:
	for quest in quest_list:
		if quest.quest_id == quest_id:
			return quest
	return null
