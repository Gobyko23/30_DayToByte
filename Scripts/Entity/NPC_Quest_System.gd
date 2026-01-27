extends Node
class_name NPCQuestSystem

# สถานะการกระทำหลังจากคุยจบ
enum NEXT_ACTION {
	NONE,           # ไม่ทำอะไร
	START_QUEST,    # เริ่มเควส
	COMPLETE_QUEST  # ส่งเควส/รับรางวัล
}

# ประเภท NPC
enum NPC_TYPE {
	DIALOGUE_ONLY,
	QUEST_GIVER
}

@export var npc_type: NPC_TYPE = NPC_TYPE.QUEST_GIVER
@export var npc_name: String = "NPC"
@export var quest_list: Array[QuestData] = [] 
@export var NonQuest_Dialogue:Array[String] =[] 

# ตัวแปรช่วยจำ
var current_processing_quest: QuestData = null # เควสที่กำลังโฟกัสอยู่
var pending_action: NEXT_ACTION = NEXT_ACTION.NONE

# ---------------------------------------------------------
# ฟังก์ชันหลัก: ดึงข้อมูลการสนทนาตามสถานะปัจจุบัน
# Return: Dictionary ที่มี { "dialogues": Array[String], "action": NEXT_ACTION }
# ---------------------------------------------------------
func get_current_interaction() -> Dictionary:
# แก้ไขบรรทัดนี้: เติม "as Array[String]" เพื่อระบุประเภทข้อมูลให้ชัดเจน
	var result = {
		"dialogues": ["..."] as Array[String], 
		"action": NEXT_ACTION.NONE
	}

	if npc_type == NPC_TYPE.DIALOGUE_ONLY:
		result.dialogues = NonQuest_Dialogue
		return result

	# 1. วนลูปหาเควสที่เหมาะสม
	current_processing_quest = _find_relevant_quest()

	if current_processing_quest == null:
		result.dialogues = ["ฉันไม่มีเควสให้คุณในตอนนี้"]
		return result

	# 2. เช็คสถานะของเควสนั้นๆ เพื่อเลือกบทพูดจาก QuestData 
	var q_id = current_processing_quest.quest_id
	
	# กรณี: ยังไม่เคยรับเควสนี้ -> เตรียม "ให้เควส"
	if not QuestManager.is_quest_active(q_id) and not QuestManager.is_quest_completed(q_id):
		result.dialogues = current_processing_quest.give_quest_dialogue
		result.action = NEXT_ACTION.START_QUEST
	
	# กรณี: รับไปแล้ว แต่ยังทำไม่เสร็จ -> "รอคอย"
	elif QuestManager.is_quest_active(q_id) and not current_processing_quest.is_completed:
		result.dialogues = ["เควส '" + current_processing_quest.quest_name + "' ยังไม่เสร็จนะ พยายามเข้าล่ะ"]
		result.action = NEXT_ACTION.NONE
		
	# กรณี: ทำเงื่อนไขเสร็จแล้ว (รอส่ง) -> "ส่งเควส"
	elif current_processing_quest.is_completed and QuestManager.is_quest_active(q_id):
		# หมายเหตุ: ใน QuestData ควรมี is_completed เป็น true เมื่อทำเงื่อนไขครบ
		# หรือคุณอาจจะเช็คเงื่อนไขจาก QuestManager แทนตรงนี้ได้
		result.dialogues = current_processing_quest.complete_quest_dialogue
		result.action = NEXT_ACTION.COMPLETE_QUEST
	
	# กรณี: ส่งเควสไปเรียบร้อยแล้ว -> "ขอบคุณ"
	elif QuestManager.is_quest_completed(q_id):
		result.dialogues = ["ขอบคุณที่ช่วยเหลือฉันเมื่อคราวก่อนนะ"]
		result.action = NEXT_ACTION.NONE

	return result

# ---------------------------------------------------------
# ฟังก์ชันภายใน: หา Quest ที่ผู้เล่นควรทำกับ NPC นี้
# ---------------------------------------------------------
func _find_relevant_quest() -> QuestData:
	# 1. หาเควสที่รับไปแล้วแต่ยังไม่ส่ง (Active)
	for quest in quest_list:
		if QuestManager.is_quest_active(quest.quest_id):
			return quest
			
	# 2. ถ้าไม่มี Active, หาเควสใหม่ที่ยังไม่เคยทำ
	for quest in quest_list:
		if not QuestManager.is_quest_completed(quest.quest_id):
			return quest
	
	# 3. ถ้าทำหมดแล้ว คืนค่า null หรือเควสสุดท้ายเพื่อคุยเล่น
	return null

# ---------------------------------------------------------
# ฟังก์ชันดำเนินการ (เรียกเมื่อคุยจบ)
# ---------------------------------------------------------
func perform_action(action: NEXT_ACTION) -> void:
	if current_processing_quest == null: return

	match action:
		NEXT_ACTION.START_QUEST:
			QuestManager.start_quest(current_processing_quest)
			print("✅ เริ่มเควส: ", current_processing_quest.quest_name)
			
		NEXT_ACTION.COMPLETE_QUEST:
			QuestManager.complete_quest(current_processing_quest.quest_id)
			print("💰 ส่งเควสและรับรางวัล: ", current_processing_quest.quest_name)
			# ตรงนี้คุณอาจเพิ่มโค้ดให้เงินหรือไอเทมผู้เล่นจริงๆ ได้
