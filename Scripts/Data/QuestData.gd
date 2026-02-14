extends Resource
class_name QuestData

# ประเภท NPC
enum NPC_TYPE {
	DIALOGUE_ONLY,
	QUEST_GIVER,
	QUESTION,
	CUSTOMER
}

# ข้อมูลพื้นฐาน Quest
@export var quest_id: String = "quest_001"
@export var quest_name: String = "ทดสอบ Quest"
@export var description: String = "คำบรรยายของ Quest"
@export var reward_money: int = 100
@export var reward_items: Array[String] = []
@export_group("Quest Conditions")
@export var target_item_id: String = ""      # ID ของสิ่งที่ต้องทำ เช่น "apple" หรือ "cat"
@export var required_amount: int = 0         # จำนวนที่ต้องการ เช่น 5 หรือ 4
@export var current_amount: int = 0

# ตั้งค่า NPC
@export_group("NPC Settings")
@export var npc_type: NPC_TYPE = NPC_TYPE.QUEST_GIVER
@export_group("Question Dialogues")
# Dialogue arrays
@export var give_quest_dialogue: Array[String] = ["คุณต้องการเควสหรือไม่?"]
@export var inprocess_dialogue: Array[String] = ["คุณกำลังทำเควสนี้อยู่แล้ว"]
@export var complete_quest_dialogue: Array[String] = ["ขอบคุณที่ทำให้เสร็จ!"]
@export var reward_dialogue: Array[String] = ["นี่คือรางวัล!"]
@export var answer_text: String	 = "คำตอบที่ถูกต้อง"  # คำตอบที่ถูกต้องสำหรับคำถาม
# Questions & Answers (สำหรับ NPC ที่มี npc_type = QUESTION)
@export var questions_dialogue: Array[String] = ["คุณพร้อมตอบคำถามหรือไม่?"]  # บทพูดก่อนถามคำถาม
@export var question_text: String = "คำถามคืออะไร?"  # ข้อความคำถาม
@export_multiline var question_ask: String = "001 + 101 = ?"  # รายการคำถาม
@export var accept_question_dialogue: Array[String] = ["ดีเลย! นี่คือคำถามของฉัน"]  # บทพูดหลังรับเควส/คำถาม



# ข้อมูลสถานะ
var is_completed: bool = false
var is_active: bool = false
var progress: int = 0

# การสร้าง Quest ใหม่
func _init(p_id: String = "", p_name: String = "", p_desc: String = "", p_reward: int = 0, p_npc_type: NPC_TYPE = NPC_TYPE.QUEST_GIVER) -> void:
	quest_id = p_id
	quest_name = p_name
	description = p_desc
	reward_money = p_reward
	npc_type = p_npc_type

# ตรวจสอบว่า Quest เสร็จสิ้นหรือไม่
func is_quest_complete() -> bool:
	return is_completed

# ทำเครื่องหมายว่า Quest เสร็จสิ้น
func complete_quest() -> void:
	is_completed = true
	is_active = false

# เปิดใช้งาน Quest
func activate_quest() -> void:
	is_active = true
	is_completed = false

# ยกเลิก Quest
func cancel_quest() -> void:
	is_active = false
	is_completed = false

# ฟังก์ชันเช็คว่าเงื่อนไขครบหรือยัง
func is_goal_reached() -> bool:
	if required_amount <= 0: return true # ถ้าไม่กำหนดจำนวน ถือว่าผ่านเลย (เช่นเควสคุยอย่างเดียว)
	return current_amount >= required_amount


# เพิ่มฟังก์ชันนี้ใน QuestData.gd
func reset_quest_data() -> void:
	current_amount = 0
	is_completed = false
	is_active = false
	progress = 0


# ดึงข้อมูล Quest
func get_quest_info() -> Dictionary:
	return {
		"id": quest_id,
		"name": quest_name,
		"description": description,
		"reward_money": reward_money,
		"reward_items": reward_items,
		"is_completed": is_completed,
		"is_active": is_active,
	}		
# ฟังก์ชัน: ดึงคำตอบที่ถูกต้อง(แบบข้อความ)
func get_correct_answer_chat() -> String:
	return answer_text

# ฟังก์ชัน: Debug - แสดงข้อมูล Quest ทั้งหมด
func debug_print_quest_info() -> void:
	print("\n" + "=".repeat(50))
	print("📋 QUEST DEBUG INFO")
	print("=".repeat(50))
	print("ID: ", quest_id)
	print("Name: ", quest_name)
	print("Description: ", description)
	print("Reward Money: ", reward_money)
	print("NPC Type: ", NPC_TYPE.keys()[npc_type])
	print("Status: ", "✅ Completed" if is_completed else "⏳ Active" if is_active else "⭕ Inactive")
	print("Progress: ", progress)
	print("=".repeat(50) + "\n")

# ฟังก์ชัน: Debug - แสดง Dialogue ทั้งหมด
func debug_print_dialogues() -> void:
	print("\n" + "=".repeat(50))
	print("💬 QUEST DIALOGUES")
	print("=".repeat(50))
	print("Give Quest Dialogue:")
	for i in range(give_quest_dialogue.size()):
		print("  [" + str(i) + "] " + give_quest_dialogue[i])
	print("\nComplete Quest Dialogue:")
	for i in range(complete_quest_dialogue.size()):
		print("  [" + str(i) + "] " + complete_quest_dialogue[i])
	print("\nReward Dialogue:")
	for i in range(reward_dialogue.size()):
		print("  [" + str(i) + "] " + reward_dialogue[i])
	print("=".repeat(50) + "\n")

# ฟังก์ชัน: Debug - แสดงทุกอย่าง
func debug_print_all() -> void:
	debug_print_quest_info()
	debug_print_dialogues()

# ฟังก์ชัน: เปลี่ยน NPC Type
func set_npc_type(new_type: NPC_TYPE) -> void:
	npc_type = new_type
	print("🔄 NPC Type changed to: ", NPC_TYPE.keys()[npc_type], " progress: ", progress)
