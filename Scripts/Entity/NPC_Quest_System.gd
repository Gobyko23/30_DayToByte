extends Node
class_name NPCQuestSystem

# สถานะ NPC หลักของระบบ
enum NPC_STATE {
	NONE,              # ไม่ทำอะไร (หรือคุยเสร็จแล้ว)
	START_QUEST,       # ผู้เล่นเพิ่งเริ่มรับเควส
	COMPLETE_QUEST,    # ผู้เล่นทำเควสเสร็จแล้ว
	START_QUESTION,    # ผู้เล่นจะเริ่มตอบคำถาม (แสดง questions_dialogue + ปุ่ม accept/refuse)
	ASK                # ผู้เล่นตอบรับคำถาม (แสดง question_text)
}

# ส่วนที่เหลือใช้สำหรับ Quest Actions (ความเข้ากันได้)
enum NEXT_ACTION {
	NONE = NPC_STATE.NONE,
	START_QUEST = NPC_STATE.START_QUEST,
	COMPLETE_QUEST = NPC_STATE.COMPLETE_QUEST,
	START_QUESTION = NPC_STATE.START_QUESTION,
	ASK = NPC_STATE.ASK
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
@export var NonQuest_Dialogue: Array[String] = []

# --- ส่วนที่ 2: เพิ่มตัวแปรสำหรับตั้งค่าคำถาม ---
@export_group("Question Setup")
var question_text: String = "นี่คือคำถามของฉัน"
@export var choices: Array[String] = ["ตัวเลือก A", "ตัวเลือก B"]
@export var correct_choice_index: int = 0
@export var correct_dialogue: Array[String] = ["ถูกต้อง!"]
@export var wrong_dialogue: Array[String] = ["ผิด! ลองใหม่นะ"]

@export var reward_item_id: String = ""

# --- ส่วนที่เพิ่มเข้ามาใหม่สำหรับระบบสุ่ม ---
@export_group("Random Quest System")
@export var enable_random_quests: bool = false
@export var quest_pool: Array[QuestData] = []
@export var random_quest_amount: int = 1

# ตัวแปรสถานะ NPC (บันทึกสำคัญ)
var current_state: NPC_STATE = NPC_STATE.NONE          # สถานะปัจจุบัน
var current_processing_quest: QuestData = null          # เควสที่กำลังจัดการ
var is_question_answered: bool = false                  # ว่าผู้เล่นตอบคำถามแล้วหรือ
var player_answer: String = ""                          # คำตอบของผู้เล่น
var has_talked_to_npc: bool = false                      # เคยคุยกับ NPC นี้หรือยัง

# ตัวแปรช่วยจำ
var _is_state_restored: bool = false

# ---------------------------------------------------------
# _ready: ทำงานเมื่อเกมเริ่ม
# ---------------------------------------------------------
func _ready() -> void:
	if enable_random_quests and npc_type == NPC_TYPE.QUEST_GIVER:
		_init_random_quests()


# ---------------------------------------------------------
# ฟังก์ชัน: สุ่มเควสจาก Pool
# ---------------------------------------------------------
func _init_random_quests() -> void:
	if quest_pool.is_empty():
		return

    # 1. ลองดึงข้อมูลเก่าจาก NPCManager มาดูก่อน
	var npc_mgr = get_node_or_null("/root/NPCManager")
	if npc_mgr:
		var saved_state = npc_mgr.get_npc_action_state(npc_name)
		var saved_quest_id = saved_state.get("current_processing_quest_id", "")
        
        # ถ้าเคยมีเควสอยู่แล้ว ให้ดึงเควสนั้นมาจาก Pool แทนการสุ่มใหม่
		if saved_quest_id != "":
			for q in quest_pool:
				if q and q.quest_id == saved_quest_id:
					if not quest_list.has(q):
						quest_list.append(q)
						self.npc_type = q.npc_type as NPC_TYPE # คืนค่า Type เดิม
					print("♻️ NPC ", npc_name, " ดึงเควสเดิมคืนมา: ", q.quest_name)
					return # จบการทำงาน ไม่ต้องสุ่มใหม่

    # 2. ถ้าไม่มีข้อมูลเก่า (เป็นครั้งแรกที่เจอ NPC) ถึงจะเริ่มสุ่ม
	var available_quests: Array[QuestData] = []
	for q in quest_pool:
		if q == null: continue
		if QuestManager.is_quest_completed(q.quest_id): continue
		if QuestManager.is_quest_active(q.quest_id): continue
		available_quests.append(q)

	available_quests.shuffle()
	var count_to_add = min(random_quest_amount, available_quests.size())
    
	for i in range(count_to_add):
		var selected_quest = available_quests[i]
		quest_list.append(selected_quest)
		self.npc_type = selected_quest.npc_type as NPC_TYPE 
        
        # บันทึกสถานะลง NPCManager ทันทีที่สุ่มได้ เพื่อให้ค้างอยู่ในระบบ Save
		_update_npc_action_state()
        
		print("🎲 NPC ", npc_name, " สุ่มเควสใหม่: ", selected_quest.quest_name)


# ---------------------------------------------------------
# ฟังก์ชันหลัก: ดึงข้อมูลการสนทนาตามสถานะปัจจุบัน
# Return: Dictionary ที่มี { "dialogues": Array[String], "state": NPC_STATE }
# ---------------------------------------------------------
func get_current_interaction() -> Dictionary:
	var result = {
		"dialogues": ["..."] as Array[String], 
		"state": NPC_STATE.NONE
	}

	if npc_type == NPC_TYPE.DIALOGUE_ONLY:
		result.dialogues = NonQuest_Dialogue
		result.state = NPC_STATE.NONE
		return result

	# หาเควสที่เหมาะสม
	current_processing_quest = _find_relevant_quest()

	# ถ้าไม่มีเควสให้ทำแล้ว
	if current_processing_quest == null:
		result.dialogues = ["ฉันไม่มีงานอะไรให้ทำในตอนนี้ ลองไปถามคนอื่นดูสิ"]
		current_state = NPC_STATE.NONE
		_update_npc_action_state()
		print("❌ No quest found for NPC: ", npc_name)
		return result

	# ========================================
	# ของ QUESTION Type
	# ========================================
	if npc_type == NPC_TYPE.QUESTION:
		if is_question_answered:
			# ถ้าตอบแล้ว → NONE state
			result.dialogues = ["คุณตอบคำถามถูกต้องไปแล้ว ขอบคุณนะ"]
			current_state = NPC_STATE.COMPLETE_QUEST
			question_text = ""  # ล้างคำถาม
		else:
			# ถ้ายังไม่ตอบ → START_QUESTION state
			question_text = current_processing_quest.question_ask
			result.dialogues = current_processing_quest.questions_dialogue.duplicate()
			current_state = NPC_STATE.START_QUESTION
		
		_update_npc_action_state()
		result.state = current_state
		return result

	# ========================================
	# ของ QUEST_GIVER Type
	# ========================================
	var q_id = current_processing_quest.quest_id
	print("🎯 Processing quest for NPC ", npc_name, ": ", current_processing_quest.quest_name, " (ID: ", q_id, ")")
	
	# กรณี: ยังไม่เคยรับเควสนี้ (ไม่ Active และไม่ Completed)
	if not QuestManager.is_quest_active(q_id) and not QuestManager.is_quest_completed(q_id):
		result.dialogues = current_processing_quest.give_quest_dialogue.duplicate()
		current_state = NPC_STATE.START_QUEST
		has_talked_to_npc = true
		print("📌 Quest status: NEW (ready to give)")
	
	# กรณี: รับไปแล้ว แต่ยังทำไม่เสร็จ
	elif QuestManager.is_quest_active(q_id) and not current_processing_quest.is_completed:
			# 🔥 เพิ่มการเช็ค: ถ้าเงื่อนไขในตัว QuestData ยังไม่ผ่าน (ของไม่ครบ)
		if not can_complete_quest():
			result.dialogues = current_processing_quest.inprocess_dialogue.duplicate()
			current_state = NPC_STATE.NONE
			print("📌 Quest status: IN PROGRESS (Items not enough: %d/%d)" % [current_processing_quest.current_amount, current_processing_quest.required_amount])
		else:
			result.dialogues = current_processing_quest.complete_quest_dialogue.duplicate()
			for reward_line in current_processing_quest.reward_dialogue:
				result.dialogues.append(reward_line)
			current_state = NPC_STATE.COMPLETE_QUEST
			print("📌 Quest status: READY TO SUBMIT (Conditions met!)")
	# กรณี: ทำเงื่อนไขเสร็จแล้ว
	elif current_processing_quest.is_completed and QuestManager.is_quest_active(q_id):
		result.dialogues = current_processing_quest.complete_quest_dialogue.duplicate()
		# เพิ่ม reward_dialogue
		for reward_line in current_processing_quest.reward_dialogue:
			result.dialogues.append(reward_line)
		current_state = NPC_STATE.COMPLETE_QUEST
		print("📌 Quest status: READY TO SUBMIT")
	
	# กรณี: ส่งเควสไปเรียบร้อยแล้ว
	elif QuestManager.is_quest_completed(q_id):
		result.dialogues = ["ขอบคุณที่ช่วยเหลือฉันเมื่อคราวก่อนนะ"]
		current_state = NPC_STATE.NONE
		print("📌 Quest status: COMPLETED")
	
	_update_npc_action_state()
	result.state = current_state
	return result


# ---------------------------------------------------------
# ฟังก์ชันภายใน: หา Quest ที่ผู้เล่นควรทำกับ NPC นี้
# ---------------------------------------------------------
func _find_relevant_quest() -> QuestData:
	# 1. หาเควสที่รับไปแล้วแต่ยังไม่ส่ง (Active) - สำคัญที่สุด
	for quest in quest_list:
		if quest and QuestManager.is_quest_active(quest.quest_id):
			return quest
			
	# 2. ถ้าไม่มี Active, หาเควสใหม่ที่ยังไม่เคยทำ
	for quest in quest_list:
		if quest and not QuestManager.is_quest_completed(quest.quest_id):
			return quest
	
	# 3. ถ้าทำหมดแล้ว คืนค่า null
	return null


# ---------------------------------------------------------
# ฟังก์ชันดำเนินการ (เรียกเมื่อ NPC_Script เสร็จสนทนา)
# ---------------------------------------------------------
func perform_action(state: NPC_STATE) -> void:
	if current_processing_quest == null: return

	var npc_mgr = get_node_or_null("/root/NPCManager")
	
	match state:
		NPC_STATE.START_QUEST:
			QuestManager.start_quest(current_processing_quest)
			if npc_mgr: npc_mgr.on_npc_interacted(npc_name)

		NPC_STATE.START_QUESTION:
            # เมื่อเริ่มถาม ไม่ต้องทำอะไร รอให้ตอบถูกก่อน (is_question_answered = true)
			print("❓ NPC รอคำตอบ...")
		NPC_STATE.COMPLETE_QUEST:
            # 🔥 จุดสำคัญ: จะยอมให้ส่งเควสได้ "เฉพาะ" เมื่อตอบถูกแล้วเท่านั้น
			if not QuestManager.is_quest_completed(current_processing_quest.quest_id):
				if npc_type == NPC_TYPE.QUESTION:
					if is_question_answered :
						QuestManager.complete_quest(current_processing_quest.quest_id)
						if npc_mgr: npc_mgr.on_npc_interacted(npc_name)
						print("💰 ตอบถูกและจบเควสเรียบร้อย")
					else:
						QuestManager.complete_quest(current_processing_quest.quest_id)
						if npc_mgr: npc_mgr.on_npc_interacted(npc_name)
						print("❌ ยังตอบไม่ถูก จะข้ามมา Complete ไม่ได้!")
				else:
                	# กรณี Quest Giver ปกติ
					QuestManager.complete_quest(current_processing_quest.quest_id)
					if npc_mgr: npc_mgr.on_npc_interacted(npc_name)
		
		NPC_STATE.ASK:
			print("❓ NPC กำลังถามคำถาม")


# ---------------------------------------------------------
# ฟังก์ชัน Helper: ส่ง action state ไป NPCManager
# ---------------------------------------------------------
func _update_npc_action_state() -> void:
	var npc_mgr = get_node_or_null("/root/NPCManager")
	if npc_mgr and current_processing_quest:
		npc_mgr.set_npc_action_state(npc_name, int(current_state), current_processing_quest.quest_id, current_processing_quest.quest_id,is_question_answered)
	elif npc_mgr:
		npc_mgr.set_npc_action_state(npc_name, int(current_state), "", "")


# ---------------------------------------------------------
# ฟังก์ชัน Helper: ดึง action state จาก NPCManager เมื่อ load เกม
# ---------------------------------------------------------
func _restore_state_from_npc_manager() -> void:
	var npc_mgr = get_node_or_null("/root/NPCManager")
	if not npc_mgr: return
	
	var saved_state = npc_mgr.get_npc_action_state(npc_name)
	if saved_state.is_empty(): return
	
	# 1. คืนค่าสถานะหลัก
	current_state = NPC_STATE.values()[saved_state["action"]]
	_is_state_restored = true
	
	# 2. คืนค่า Quest ที่กำลังทำ
	var processing_quest_id = saved_state.get("current_processing_quest_id", "")
	if processing_quest_id != "":
		for q in quest_list:
			if q and q.quest_id == processing_quest_id:
				current_processing_quest = q
				break
	
	# 3. จุดสำคัญ: ต้องดึงค่า is_question_answered มาด้วย
	# เนื่องจาก NPCManager เดิมของคุณไม่ได้เก็บ เราจะลองหาจาก npc_states (ถ้าคุณเพิ่ม key นี้เข้าไป)
	if saved_state.has("is_question_answered"):
		is_question_answered = saved_state["is_question_answered"]


# ---------------------------------------------------------
# ฟังก์ชัน: บันทึกคำตอบของผู้เล่น
# ---------------------------------------------------------
func on_question_answered(choice_index: int) -> void:
	if choice_index == correct_choice_index:
		is_question_answered = true
		print("✅ คำตอบถูกต้อง!")
	else:
		is_question_answered = false
		print("❌ คำตอบผิด!")




func check_text_answer(answer: String) -> bool:

	if current_processing_quest and current_processing_quest.has_method("get_correct_answer_chat"):
        # 1. เช็คว่าเคยตอบถูกไปแล้วหรือยัง (ถ้าตอบแล้ว return เลย ไม่จ่ายซ้ำ)
		if is_question_answered: 
			return true

		var correct = current_processing_quest.get_correct_answer_chat()
        
        # 2. เช็คคำตอบ
		if answer.to_lower() == correct.to_lower():
			print("✅ NPC: ตอบถูกแล้ว! กำลังจ่ายรางวัล...")
            
            # =======================================================
            # 💰 ส่วนที่แก้: จ่ายเงินทันทีตรงนี้! (Direct Payment)
            # =======================================================
			var reward = current_processing_quest.reward_money
			if reward > 0:
                # เรียก PointSystem โดยตรง
				PointSystem.add(reward) 
				print("💰 NPC: จ่ายสดให้ผู้เล่นแล้ว %d แต้ม" % reward)
            
            # =======================================================
            # 📝 ส่วนจัดการสถานะ (Manager)
            # =======================================================
			is_question_answered = true
			current_state = NPC_STATE.COMPLETE_QUEST
            
            # แจ้ง QuestManager ว่าจบแล้วนะ (เพื่อบันทึกว่าทำแล้ว)
            # แต่เราจะไม่หวังพึ่งให้ Manager จ่ายเงินแล้ว เพราะเราจ่ายไปแล้วด้านบน
			var q_id = current_processing_quest.quest_id
            
            # ถ้าเควสยังไม่จบในระบบ Manager ให้ยัดเข้า list completed ไปเลย
			if not QuestManager.completed_quests.has(q_id):
				QuestManager.completed_quests.append(q_id)
                # ลบออกจาก active ถ้ามี
				if QuestManager.active_quests.has(q_id):
					QuestManager.active_quests.erase(q_id)
            
            # อัปเดต NPC Manager (ถ้ามี)
			if get_node_or_null("/root/NPCManager"):
				var npc_mgr = get_node("/root/NPCManager")
				npc_mgr.on_npc_interacted(npc_name)
                # บันทึกสถานะลงไฟล์ด้วย
				_update_npc_action_state()

			return true
            
	return false
# ฟังก์ชันรีเซ็ตสถานะกรณีผู้เล่นกด Cancel ในหน้า UI
func reset_from_cancel():
	print("🔄 NPCQuestSystem: Resetting from cancel...")
    # หากยังไม่ตอบถูก ให้คงสถานะเดิมไว้ (เช่น กลับไปที่ START_QUESTION หรือ ASK)
	if not is_question_answered:
		if npc_type == NPC_TYPE.QUESTION:
			current_state = NPC_STATE.START_QUESTION
		_update_npc_action_state()


func can_complete_quest() -> bool:
	if current_processing_quest:
        # เช็คว่าจำนวนปัจจุบัน >= จำนวนที่ต้องการ
		return current_processing_quest.current_amount >= current_processing_quest.required_amount
	return false



# ---------------------------------------------------------
# ฟังก์ชัน Debug
# ---------------------------------------------------------
func debug_npc_state() -> void:
	var npc_mgr = get_node_or_null("/root/NPCManager")
	var state = npc_mgr.get_npc_state(npc_name) if npc_mgr else {}
	
	print("\n" + "=".repeat(60))
	print("🔍 DEBUG NPC STATE: ", npc_name)
	print("=".repeat(60))
	print("Current State: ", NPC_STATE.keys()[current_state])
	print("Current Processing Quest: ", current_processing_quest.quest_name if current_processing_quest else "None")
	print("Is Question Answered: ", is_question_answered)
	print("Has Talked to NPC: ", has_talked_to_npc)
	print("\nSaved NPC Manager State:")
	print("  - visited: ", state.get("visited", false))
	print("  - greeted: ", state.get("greeted", false))
	print("  - interaction_count: ", state.get("interaction_count", 0))
	print("  - current_state: ", state.get("pending_action", NPC_STATE.NONE))
	print("  - current_quest_id: ", state.get("current_quest_id", ""))
	print("=".repeat(60) + "\n")
