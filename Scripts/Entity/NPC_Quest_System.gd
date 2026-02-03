extends Node
class_name NPCQuestSystem

# สถานะการกระทำหลังจากคุยจบ
enum NEXT_ACTION {
    NONE,           # ไม่ทำอะไร
    START_QUEST,    # เริ่มเควส
    COMPLETE_QUEST, # ส่งเควส/รับรางวัล
    START_QUESTION, # [ใหม่] เริ่มถามคำถาม
    ASK             # [ใหม่] ถามคำถามจริง (หลังจาก questions_dialogue)
}

# ประเภท NPC
enum NPC_TYPE {
	DIALOGUE_ONLY,
	QUEST_GIVER,
	QUESTION
}

@export var npc_type: NPC_TYPE = NPC_TYPE.QUEST_GIVER
@export var npc_name: String = "NPC"

# --- ส่วนเดิม ---
@export_group("Manual Quest Setup")
@export var quest_list: Array[QuestData] = [] 
@export var NonQuest_Dialogue:Array[String] =[] 


# --- ส่วนที่ 2: เพิ่มตัวแปรสำหรับตั้งค่าคำถาม ---
@export_group("Question Setup")
@export_multiline var question_text: String = "คำถามคืออะไร?" # ข้อความคำถาม
@export var choices: Array[String] = ["ตัวเลือก A", "ตัวเลือก B"] # ตัวเลือก
@export var correct_choice_index: int = 0 # ดัชนีของคำตอบที่ถูก (เริ่มที่ 0)
@export var correct_dialogue: Array[String] = ["ถูกต้อง!"] # บทพูดเมื่อตอบถูก
@export var wrong_dialogue: Array[String] = ["ผิด! ลองใหม่นะ"] # บทพูดเมื่อตอบผิด
@export var reward_item_id: String = "" # (เผื่อไว้) ไอเทมที่จะให้เมื่อตอบถูก

# ตัวแปรช่วยจำสถานะ (อาจจะต้องบันทึกลง SaveSystem ในอนาคต)
var is_question_answered: bool = false
var question_dialogue_shown: bool = false  # [ใหม่] ติดตามว่าแสดง questions_dialogue หมดแล้วหรือยัง
var player_answer: String = ""  # [ใหม่] เก็บคำตอบของ player



# --- ส่วนที่เพิ่มเข้ามาใหม่สำหรับระบบสุ่ม ---
@export_group("Random Quest System")
@export var enable_random_quests: bool = false    # เปิด/ปิด ระบบสุ่ม
@export var quest_pool: Array[QuestData] = []     # คลังเควสที่จะให้สุ่มเลือกมา
@export var random_quest_amount: int = 1          # จำนวนเควสที่จะสุ่มมาให้ NPC ตัวนี้

# ตัวแปรช่วยจำ
var current_processing_quest: QuestData = null
var pending_action: NEXT_ACTION = NEXT_ACTION.NONE
var _is_state_restored: bool = false 

# ---------------------------------------------------------
# _ready: ทำงานเมื่อเกมเริ่ม
# ---------------------------------------------------------
func _ready() -> void:
	# ถ้าเปิดระบบสุ่ม ให้ทำการสุ่มเควสใส่ quest_list
	if enable_random_quests and npc_type == NPC_TYPE.QUEST_GIVER:
		_init_random_quests()

# ---------------------------------------------------------
# ฟังก์ชันใหม่: สุ่มเควสจาก Pool
# ---------------------------------------------------------
func _init_random_quests() -> void:
	if quest_pool.is_empty():
		return

	# 1. สร้างรายการเควสที่ "สามารถรับได้" (ยังไม่เคยทำ และไม่อยู่ในรายการ manual)
	var available_quests: Array[QuestData] = []
	
	for q in quest_pool:
		# ข้ามเควสที่เป็น null
		if q == null: continue
		
		# เช็คว่าเควสนี้มีอยู่ใน quest_list แบบ Manual แล้วหรือยัง (กันซ้ำ)
		if quest_list.has(q): continue
		
		# เช็คกับ QuestManager ว่าเควสนี้เสร็จไปแล้วหรือยัง
		# (ถ้าต้องการให้ทำซ้ำได้ ให้ลบเงื่อนไขนี้ออก)
		if QuestManager.is_quest_completed(q.quest_id): continue
		
		# เช็คว่ากำลังทำอยู่หรือไม่ (ถ้ากำลังทำอยู่ ก็ไม่ควรสุ่มมาให้รับซ้ำ)
		if QuestManager.is_quest_active(q.quest_id): continue
		
		available_quests.append(q)

	# 2. สุ่มลำดับ (Shuffle)
	available_quests.shuffle()
	
	# 3. หยิบมาตามจำนวนที่ต้องการ
	var count_to_add = min(random_quest_amount, available_quests.size())
	
	for i in range(count_to_add):
		quest_list.append(available_quests[i])
		print("🎲 NPC ", npc_name, " สุ่มได้เควส: ", available_quests[i].quest_name)


# ---------------------------------------------------------
# ฟังก์ชันหลัก: ดึงข้อมูลการสนทนาตามสถานะปัจจุบัน
# Return: Dictionary ที่มี { "dialogues": Array[String], "action": NEXT_ACTION }
# ---------------------------------------------------------
func get_current_interaction() -> Dictionary:
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
		# ถ้าไม่มีเควสให้ทำแล้ว (หรือสุ่มแล้วไม่มีเควสเหลือ)
		result.dialogues = ["ฉันไม่มีงานอะไรให้ทำในตอนนี้ ลองไปถามคนอื่นดูสิ"]
		pending_action = NEXT_ACTION.NONE
		_update_npc_action_state()
		print("❌ No quest found for NPC: ", npc_name)
		return result
	if npc_type == NPC_TYPE.QUESTION:
		if is_question_answered:
            # ถ้าตอบถูกไปแล้ว
			result.dialogues = ["คุณตอบคำถามถูกต้องไปแล้ว ขอบคุณนะ"]
			result.action = NEXT_ACTION.NONE
		else:
            # ถ้ายังไม่ตอบ ให้เริ่มถาม
            # ส่งบทพูดนำเข้า + คำถาม (ไม่รวม "จะรับหรือไม่" เพราะจะแสดงเป็น UI)
			result.dialogues = current_processing_quest.questions_dialogue.duplicate()
			result.dialogues.append(current_processing_quest.question_text)
			# ลบบรรทัด: result.dialogues.append("จะรับภารกิจหรือไม่?")
			result.action = NEXT_ACTION.START_QUESTION  # ← ให้ emit signal ขอปุ่ม
            
		_update_npc_action_state() # อัปเดตสถานะ (ถ้าจำเป็น)
		return result
	# 2. เช็คสถานะของเควสนั้นๆ เพื่อเลือกบทพูดจาก QuestData 
	var q_id = current_processing_quest.quest_id
	print("🎯 Processing quest for NPC ", npc_name, ": ", current_processing_quest.quest_name, " (ID: ", q_id, ")")
	
	# กรณี: ยังไม่เคยรับเควสนี้ -> เตรียม "ให้เควส"
	if not QuestManager.is_quest_active(q_id) and not QuestManager.is_quest_completed(q_id):
		result.dialogues = current_processing_quest.give_quest_dialogue.duplicate()
		# เพิ่มคำถาม "จะรับภารกิจหรือไม่?" สำหรับ QUEST_GIVER และ QUESTION types
		result.dialogues.append("จะรับภารกิจหรือไม่?")
		result.action = NEXT_ACTION.START_QUEST
		if not _is_state_restored:
			pending_action = NEXT_ACTION.START_QUEST
		print("📌 Quest status: NEW (ready to give)")
	
	# กรณี: รับไปแล้ว แต่ยังทำไม่เสร็จ -> "รอคอย"
	elif QuestManager.is_quest_active(q_id) and not current_processing_quest.is_completed:
		result.dialogues = current_processing_quest.inprocess_dialogue
		result.action = NEXT_ACTION.NONE
		if not _is_state_restored:
			pending_action = NEXT_ACTION.NONE
		print("📌 Quest status: IN PROGRESS (waiting for completion)")
		
	# กรณี: ทำเงื่อนไขเสร็จแล้ว (รอส่ง) -> "ส่งเควส"
	elif current_processing_quest.is_completed and QuestManager.is_quest_active(q_id):
		result.dialogues = current_processing_quest.complete_quest_dialogue
		result.action = NEXT_ACTION.COMPLETE_QUEST
		if not _is_state_restored:
			pending_action = NEXT_ACTION.COMPLETE_QUEST
		print("📌 Quest status: READY TO SUBMIT")
	
	# กรณี: ส่งเควสไปเรียบร้อยแล้ว -> "ขอบคุณ"
	elif QuestManager.is_quest_completed(q_id):
		# ส่วนนี้อาจจะไม่ค่อยเข้าเงื่อนไขเพราะ _find_relevant_quest มักจะข้ามเควสที่เสร็จแล้ว
		result.dialogues = ["ขอบคุณที่ช่วยเหลือฉันเมื่อคราวก่อนนะ"]
		result.action = NEXT_ACTION.NONE
		if not _is_state_restored:
			pending_action = NEXT_ACTION.NONE
		print("📌 Quest status: COMPLETED")

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
	# 1. หาเควสที่รับไปแล้วแต่ยังไม่ส่ง (Active) - สำคัญที่สุด
	for quest in quest_list:
		if QuestManager.is_quest_active(quest.quest_id):
			return quest
			
	# 2. ถ้าไม่มี Active, หาเควสใหม่ที่ยังไม่เคยทำ
	for quest in quest_list:
		if not QuestManager.is_quest_completed(quest.quest_id):
			return quest
	
	# 3. ถ้าทำหมดแล้ว คืนค่า null
	return null

# ---------------------------------------------------------
# ฟังก์ชันดำเนินการ (เรียกเมื่อคุยจบ)
# ---------------------------------------------------------
func perform_action(action: NEXT_ACTION) -> void:
	if current_processing_quest == null: return

	var npc_mgr = get_node_or_null("/root/NPCManager")
	
	match action:
		NEXT_ACTION.START_QUEST:
			if npc_type == NPC_TYPE.QUESTION:
				# ถ้าเป็น NPC ที่ถามคำถาม ให้บันทึกว่ารับแล้ว (แต่ยังไม่ได้ตอบ)
				is_question_answered = false
				print("❓ NPC กำลังเริ่มถามคำถาม: ", current_processing_quest.question_text)
			else:
				# ถ้าเป็น Quest ปกติ ให้เริ่มเควส
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

		# [ใหม่] จัดการเมื่อต้องเริ่มถามคำถาม
		NEXT_ACTION.START_QUESTION:
			print("❓ NPC กำลังเริ่มถามคำถาม: ", question_text)
            # ตรงนี้คุณต้องเชื่อมต่อกับระบบ UI ของคุณ
            # ตัวอย่าง:
            # var ui = get_tree().root.get_node("UIManager")
            # ui.show_question_dialog(question_text, choices, self) 
			pass

# ---------------------------------------------------------
# ฟังก์ชัน Helper: ส่ง action state ไป NPCManager
# ---------------------------------------------------------
func _update_npc_action_state() -> void:
	var npc_mgr = get_node_or_null("/root/NPCManager")
	if npc_mgr and current_processing_quest:
		npc_mgr.set_npc_action_state(npc_name, pending_action, current_processing_quest.quest_id, current_processing_quest.quest_id)
	elif npc_mgr:
		npc_mgr.set_npc_action_state(npc_name, pending_action, "", "")

# ---------------------------------------------------------
# ฟังก์ชัน Helper: ดึง action state จาก NPCManager เมื่อ load เกม
# ---------------------------------------------------------
func _restore_state_from_npc_manager() -> void:
	var npc_mgr = get_node_or_null("/root/NPCManager")
	if not npc_mgr: return
	
	var saved_state = npc_mgr.get_npc_action_state(npc_name)
	if saved_state.is_empty(): return
	
	pending_action = saved_state["action"]
	_is_state_restored = true
	
	# restore current_processing_quest จาก current_processing_quest_id
	var processing_quest_id = saved_state.get("current_processing_quest_id", "")
	if processing_quest_id != "":
		# ลองหาใน quest_list ปัจจุบัน
		for quest in quest_list:
			if quest.quest_id == processing_quest_id:
				current_processing_quest = quest
				break
		
		# ถ้าไม่เจอในรายการปัจจุบัน ลองหาใน Pool
		if current_processing_quest == null:
			for quest in quest_pool:
				if quest.quest_id == processing_quest_id:
					current_processing_quest = quest
					# แอบใส่กลับเข้าไปใน list ชั่วคราวเพื่อให้ logic อื่นทำงานได้
					quest_list.append(quest)
					print("🔄 Restored processing quest from pool: ", quest.quest_name)
					break
		
		if current_processing_quest != null:
			print("✅ Restored current_processing_quest: ", current_processing_quest.quest_name)
	
	# restore quest_id (quest ที่ active)
	var active_quest_id = saved_state.get("quest_id", "")
	if active_quest_id != "":
		print("📌 NPC had active quest: ", active_quest_id)

# ฟังก์ชันนี้ให้ UI เรียกใช้เมื่อผู้เล่นกดเลือกคำตอบ
func on_question_answered(choice_index: int) -> void:
	if choice_index == correct_choice_index:
		print("✅ ตอบถูกต้อง!")
		is_question_answered = true
        # เพิ่มโค้ดให้รางวัลตรงนี้ หรือเรียก Dialogue "correct_dialogue"
	else:
		print("❌ ตอบผิด!")
        # เรียก Dialogue "wrong_dialogue"



# ---------------------------------------------------------
# ฟังก์ชัน Debug: แสดงสถานะปัจจุบันของ NPC
# ---------------------------------------------------------
func debug_npc_state() -> void:
	var npc_mgr = get_node_or_null("/root/NPCManager")
	var state = npc_mgr.get_npc_state(npc_name) if npc_mgr else {}
	
	print("\n" + "=".repeat(60))
	print("🔍 DEBUG NPC STATE: ", npc_name)
	print("=".repeat(60))
	print("Current Processing Quest: ", current_processing_quest.quest_name if current_processing_quest else "None")
	print("Pending Action: ", NEXT_ACTION.keys()[pending_action] if pending_action < NEXT_ACTION.size() else "UNKNOWN")
	print("Is State Restored: ", _is_state_restored)
	print("\nSaved NPC Manager State:")
	print("  - visited: ", state.get("visited", false))
	print("  - greeted: ", state.get("greeted", false))
	print("  - interaction_count: ", state.get("interaction_count", 0))
	print("  - pending_action: ", state.get("pending_action", NEXT_ACTION.NONE))
	print("  - current_quest_id: ", state.get("current_quest_id", ""))
	print("  - current_processing_quest_id: ", state.get("current_processing_quest_id", ""))
	print("=".repeat(60) + "\n")
