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
var _is_state_restored: bool = false # flag เพื่อหลีกเลี่ยง override pending_action หลัง restore


# ---------------------------------------------------------
# _ready: ไม่ต้องเรียก restore ที่นี่
# (SaveAndLoadscript จะเรียกหลังจาก load_npc_data)
# ---------------------------------------------------------
func _ready() -> void:
	pass


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
		pending_action = NEXT_ACTION.NONE
		_update_npc_action_state()
		return result

	# 2. เช็คสถานะของเควสนั้นๆ เพื่อเลือกบทพูดจาก QuestData 
	var q_id = current_processing_quest.quest_id
	
	# กรณี: ยังไม่เคยรับเควสนี้ -> เตรียม "ให้เควส"
	if not QuestManager.is_quest_active(q_id) and not QuestManager.is_quest_completed(q_id):
		result.dialogues = current_processing_quest.give_quest_dialogue
		result.action = NEXT_ACTION.START_QUEST
		if not _is_state_restored:
			pending_action = NEXT_ACTION.START_QUEST
	
	# กรณี: รับไปแล้ว แต่ยังทำไม่เสร็จ -> "รอคอย"
	elif QuestManager.is_quest_active(q_id) and not current_processing_quest.is_completed:
		result.dialogues = ["เควส '" + current_processing_quest.quest_name + "' ยังไม่เสร็จนะ พยายามเข้าล่ะ"]
		result.action = NEXT_ACTION.NONE
		if not _is_state_restored:
			pending_action = NEXT_ACTION.NONE
		
	# กรณี: ทำเงื่อนไขเสร็จแล้ว (รอส่ง) -> "ส่งเควส"
	elif current_processing_quest.is_completed and QuestManager.is_quest_active(q_id):
		# หมายเหตุ: ใน QuestData ควรมี is_completed เป็น true เมื่อทำเงื่อนไขครบ
		# หรือคุณอาจจะเช็คเงื่อนไขจาก QuestManager แทนตรงนี้ได้
		result.dialogues = current_processing_quest.complete_quest_dialogue
		result.action = NEXT_ACTION.COMPLETE_QUEST
		if not _is_state_restored:
			pending_action = NEXT_ACTION.COMPLETE_QUEST
	
	# กรณี: ส่งเควสไปเรียบร้อยแล้ว -> "ขอบคุณ"
	elif QuestManager.is_quest_completed(q_id):
		result.dialogues = ["ขอบคุณที่ช่วยเหลือฉันเมื่อคราวก่อนนะ"]
		result.action = NEXT_ACTION.NONE
		if not _is_state_restored:
			pending_action = NEXT_ACTION.NONE

	# ใช้ pending_action เป็น result action ถ้าได้รับการ restore
	if _is_state_restored:
		result.action = pending_action
		_is_state_restored = false  # reset flag หลัง use
	
	_update_npc_action_state()
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

	var npc_mgr = get_node_or_null("/root/NPCManager")
	
	match action:
		NEXT_ACTION.START_QUEST:
			QuestManager.start_quest(current_processing_quest)
			if npc_mgr:
				npc_mgr.on_npc_interacted(npc_name)
				npc_mgr.record_quest_given(npc_name, current_processing_quest.quest_id)
				npc_mgr.set_npc_action_state(npc_name, NEXT_ACTION.NONE, "")
			print("✅ เริ่มเควส: ", current_processing_quest.quest_name)
			
		NEXT_ACTION.COMPLETE_QUEST:
			QuestManager.complete_quest(current_processing_quest.quest_id)
			if npc_mgr:
				npc_mgr.on_npc_interacted(npc_name)
				npc_mgr.set_npc_action_state(npc_name, NEXT_ACTION.NONE, "")
			print("💰 ส่งเควสและรับรางวัล: ", current_processing_quest.quest_name)
			# ตรงนี้คุณอาจเพิ่มโค้ดให้เงินหรือไอเทมผู้เล่นจริงๆ ได้


# ---------------------------------------------------------
# ฟังก์ชัน Helper: ส่ง action state ไป NPCManager
# ---------------------------------------------------------
func _update_npc_action_state() -> void:
	var npc_mgr = get_node_or_null("/root/NPCManager")
	if npc_mgr and current_processing_quest:
		npc_mgr.set_npc_action_state(npc_name, pending_action, current_processing_quest.quest_id)
	elif npc_mgr:
		npc_mgr.set_npc_action_state(npc_name, pending_action, "")


# ---------------------------------------------------------
# ฟังก์ชัน Helper: ดึง action state จาก NPCManager เมื่อ load เกม
# ---------------------------------------------------------
func _restore_state_from_npc_manager() -> void:
	print("🔍 _restore_state_from_npc_manager called for: ", npc_name)
	var npc_mgr = get_node_or_null("/root/NPCManager")
	if not npc_mgr:
		print("❌ NPCManager not found!")
		return
	
	var saved_state = npc_mgr.get_npc_action_state(npc_name)
	print("📋 Saved state: ", saved_state)
	if saved_state.is_empty():
		print("⚠️ No saved state found!")
		return
	
	# restore pending_action
	var old_action = pending_action
	pending_action = saved_state["action"]
	_is_state_restored = true  # set flag เพื่อบอก get_current_interaction() ว่า state มี restoration
	print("✏️ pending_action: ", old_action, " -> ", pending_action)
	
	# restore current_processing_quest ถ้ามี quest_id
	if saved_state["quest_id"] != "":
		for quest in quest_list:
			if quest.quest_id == saved_state["quest_id"]:
				current_processing_quest = quest
				print("✏️ current_processing_quest restored: ", quest.quest_name)
				break
	
	print("🔄 NPC state restored: ", npc_name, " -> action: ", pending_action, ", quest: ", saved_state["quest_id"])

