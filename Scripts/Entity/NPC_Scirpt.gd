extends Obj_Main
class_name NPC

# Signal: ส่งเมื่อ NPC ต้องการปุ่ม Accept/Refuse
signal request_question_buttons(npc: NPC)

@onready var Dialogue_sprite :Sprite3D = $NPC_Dialog
@onready var Dialogue_text :RichTextLabel = %ask_text
@onready var Anotation :Sprite3D = $NPC_UnknowTation
@onready var world_camera = get_tree().get_first_node_in_group("WorldCamera")
@onready var focus_marker: Marker3D = $NPC_Sprite/NpcPivot
# ระบบ Quest
@export var quest_system: NPCQuestSystem
# ตัวแปรจัดการบทพูด
var current_dialogue_queue: Array[String] = [] # เก็บข้อความที่จะพูด
var current_line_index: int = 0              # บรรทัดปัจจุบัน
var pending_quest_action = NPCQuestSystem.NEXT_ACTION.NONE # สิ่งที่ต้องทำหลังคุยจบ
var is_talking: bool = false
# ระบบสำหรับคำถาม
var is_question_phase: bool = false # เก็บว่ากำลังแสดงคำถาม "จะรับภารกิจหรือไม่"
var question_accept_btn: Button  # อ้างอิงปุ่ม Accept จาก pause.gd
var question_refuse_btn: Button  # อ้างอิงปุ่ม Refuse จาก pause.gd

func _ready() -> void:
	# Setup UI
	if Dialogue_text: Dialogue_text.text = ""
	if Dialogue_sprite: Dialogue_sprite.visible = false
	
	# Setup System
	print("DEBUG NPC._ready(): NPC name = ", name, " quest_system = ", quest_system)
	if quest_system:
		add_child(quest_system)
		quest_system.npc_name = String(name)
		print("✅ quest_system initialized for NPC: ", name)
	else:
		print("❌ quest_system is NULL for NPC: ", name)
	
	# ตรวจสอบ group
	print("DEBUG: NPC ", name, " groups = ", get_groups())

func _input(event: InputEvent) -> void:
	# ถ้ากำลังคุยกับ NPC และกดปุ่ม interact ให้ไปบรรทัดถัดไป
	if is_talking and event is InputEventAction:
		if event.is_action_pressed("interact"):
			if not is_question_phase:
				next_dialogue()
				get_tree().root.set_input_as_handled()

# ฟังก์ชัน: ตั้งค่าปุ่ม Accept/Refuse จาก pause.gd
func set_question_buttons(accept_btn: Button, refuse_btn: Button) -> void:
	# เก็บอ้างอิงปุ่มไว้ใช้ในภายหลัง (pause.gd จะเชื่อม signal)
	question_accept_btn = accept_btn
	question_refuse_btn = refuse_btn
	
	if question_accept_btn:
		print("🔗 Accept button assigned to NPC")
	if question_refuse_btn:
		print("🔗 Refuse button assigned to NPC")

func interacting():
	# เริ่มต้นการคุย
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.is_talking = true
		player.talking_npc = self 
		if Anotation: Anotation.visible = false
		if Dialogue_sprite: Dialogue_sprite.visible = true
	
	is_talking = true
	
	print("\n=== NPC.interacting() START ===")
	print("NPC name: ", name)
	print("quest_system: ", quest_system)
	if quest_system:
		print("quest_system.npc_type: ", quest_system.npc_type)
		print("quest_system.quest_list.size(): ", quest_system.quest_list.size())
		for q in quest_system.quest_list:
			print("  - Quest: ", q.quest_name if q else "null")
	
	# 1. ขอข้อมูลจาก Quest System
	var interaction_data = quest_system.get_current_interaction()
	
	print("interaction_data[action]: ", interaction_data["action"])
	print("interaction_data[dialogues].size(): ", interaction_data["dialogues"].size())
	for i in range(min(3, interaction_data["dialogues"].size())):
		print("  - Dialog[", i, "]: ", interaction_data["dialogues"][i])
	print("============================\n")
	
	# 2. ตั้งค่าตัวแปร
	# -----------------
	current_dialogue_queue.assign(interaction_data["dialogues"])
	
	pending_quest_action = interaction_data["action"]
	current_line_index = 0
	
	# 🔥 รีเซ็ต question_dialogue_shown เมื่อเริ่มสนทนาครั้งใหม่
	if quest_system:
		quest_system.question_dialogue_shown = false
	
	# 3. เริ่มแสดงผล
	show_dialogue()

func show_dialogue():
	print("\n>>> NPC.show_dialogue() called")
	print("  pending_quest_action: ", pending_quest_action)
	print("  is_question_phase: ", is_question_phase)
	print("  quest_system: ", quest_system)
	if quest_system:
		print("  quest_system.npc_type: ", quest_system.npc_type)
		print("  quest_system.question_text: ", quest_system.question_text)
	print()
	
	# 🔥 ซ่อนปุ่มเมื่อ state เป็น NONE
	if pending_quest_action == NPCQuestSystem.NEXT_ACTION.NONE:
		if question_accept_btn:
			question_accept_btn.visible = false
			question_accept_btn.disabled = true
		if question_refuse_btn:
			question_refuse_btn.visible = false
			question_refuse_btn.disabled = true
		print("✅ NPC: Hidden question buttons (NONE state)")
	
	# จัดการกล้อง
	if not world_camera: world_camera = get_tree().get_first_node_in_group("WorldCamera")
	if not focus_marker: focus_marker = get_node_or_null("NPC_Sprite/NpcPivot")
	if world_camera and focus_marker: world_camera.focus_on(focus_marker)
	
	# 🔥 ตรวจสอบ state ASK - emit signal ตรงนี้
	print(">>> Checking ASK condition: pending_quest_action == ASK(4)? ", pending_quest_action == NPCQuestSystem.NEXT_ACTION.ASK, " START_QUESTION(3)? ", pending_quest_action == NPCQuestSystem.NEXT_ACTION.START_QUESTION, " not is_question_phase? ", not is_question_phase)
	if (pending_quest_action == NPCQuestSystem.NEXT_ACTION.ASK or pending_quest_action == NPCQuestSystem.NEXT_ACTION.START_QUESTION) and not is_question_phase:
		print("\n=== ASK STATE DETECTED ===")
		print("NPC: ", name)
		print("is_question_phase: ", is_question_phase)
		print("quest_system: ", quest_system)
		print("quest_system.question_text: ", quest_system.question_text if quest_system else "NONE")
		print("Signal has connections: ", request_question_buttons.get_connections().size() > 0)
		print("=========================\n")
		
		is_question_phase = true
		print("🔄 NPC: Setting is_question_phase = true (ASK state)")
		
		if Dialogue_text:
			Dialogue_text.text = quest_system.question_text if quest_system else "No question text"
			print("❓ Showing question_text for ASK state")
		
		# 🔥 Emit signal เพื่อขอปุ่มจาก pause.gd
		print("📡 NPC: About to emit request_question_buttons signal")
		print("DEBUG: Signal connected listeners = ", request_question_buttons.get_connections())
		request_question_buttons.emit(self)
		print("📡 NPC: Emitted request_question_buttons signal (ASK)")
		return
	
	# แสดงข้อความ
	print("DEBUG show_dialogue: current_line_index=", current_line_index, " queue.size=", current_dialogue_queue.size())
	if current_line_index < current_dialogue_queue.size():
		var text_to_show = current_dialogue_queue[current_line_index]
		if Dialogue_text:
			Dialogue_text.text = text_to_show
		print("NPC Says: ", text_to_show)
	else:
		# current_line_index >= size → dialogues หมดแล้ว
		# ตรวจสอบว่าต้องเลื่อนไปขั้นต่อหรือจบ
		
		print("\n>>> DIALOGUES FINISHED - Checking NEXT STATE")
		var npc_type_str = str(quest_system.npc_type) if quest_system else "null"
		print("📋 Debug: pending_quest_action=", pending_quest_action, " npc_type=", npc_type_str)
		
		# 🔥 ตรวจสอบว่าต้องเลื่อนไปขั้นต่อ (QUESTION type เท่านั้น)
		if pending_quest_action == NPCQuestSystem.NEXT_ACTION.NONE and quest_system and quest_system.npc_type == NPCQuestSystem.NPC_TYPE.QUESTION:
			# questions_dialogue หมดแล้ว → เรียก get_current_interaction() ใหม่
			print("📋 Questions dialogue finished - requesting next interaction...")
			var new_interaction_data = quest_system.get_current_interaction()
			
			# อัปเดต pending_quest_action จากการเรียกใหม่
			pending_quest_action = new_interaction_data["action"]
			print("🔄 Updated pending_quest_action to: ", pending_quest_action)
			
			# แสดง question_text พร้อมปุ่ม
			if pending_quest_action == NPCQuestSystem.NEXT_ACTION.ASK or pending_quest_action == NPCQuestSystem.NEXT_ACTION.START_QUESTION:
				is_question_phase = true
				print("🔄 NPC: Setting is_question_phase = true")
					
					# แสดง question_text
				if Dialogue_text:
					Dialogue_text.text = quest_system.question_text
					print("❓ Showing question_text for QUESTION type")
					
					# 🔥 Emit signal เพื่อขอปุ่มจาก pause.gd
				request_question_buttons.emit(self)
				print("📡 NPC: Emitted request_question_buttons signal")
					
				print("❓ Question UI activated - Waiting for button press...")
				print("🎯 Current is_question_phase = ", is_question_phase)
			return
		
		# สำหรับ QUEST_GIVER (pending_quest_action = START_QUEST) 
		# หรือกรณีอื่นๆ → แสดง UI Accept/Refuse
		if pending_quest_action == NPCQuestSystem.NEXT_ACTION.START_QUEST and quest_system:
			# QUEST_GIVER: แสดง "จะรับภารกิจหรือไม่?"
			if quest_system.npc_type == NPCQuestSystem.NPC_TYPE.QUEST_GIVER:
				if not is_question_phase:
					is_question_phase = true
					print("🔄 NPC: Setting is_question_phase = true")
					
					if Dialogue_text:
						Dialogue_text.text = "จะรับภารกิจหรือไม่?"
						print("❓ Showing quest offer for QUEST_GIVER")
					
					# 🔥 Emit signal เพื่อขอปุ่มจาก pause.gd
					request_question_buttons.emit(self)
					print("📡 NPC: Emitted request_question_buttons signal")
					
					print("❓ Question UI activated - Waiting for button press...")
					print("🎯 Current is_question_phase = ", is_question_phase)
				return
		
		# ถ้า Index เกินขนาด Array แปลว่าคุยจบแล้ว
		end_dialogue()

func next_dialogue():
	if not is_talking: return
	
	print("\n>>> NPC.next_dialogue() called")
	print("  current_line_index: ", current_line_index, " → ", current_line_index + 1)
	print("  queue.size: ", current_dialogue_queue.size())
	
	# ขยับไปบรรทัดถัดไป
	current_line_index += 1
	
	print("  After increment: current_line_index=", current_line_index)
	
	if current_line_index < current_dialogue_queue.size():
		print("  ✅ Still have dialogues, showing next...")
		show_dialogue()
	else:
		print("  ✅ Dialogues finished, calling end_dialogue()")
		# ✅ ตรวจสอบ Logic การเปลี่ยน State (Transition) ก่อนปิด
		
		# ดึงค่า NPC Type และ Action ล่าสุด
		var current_npc_type = quest_system.npc_type if quest_system else null
		
		# เงื่อนไข: เป็น NPC ถามตอบ + เพิ่งจบช่วง Intro (Action ยังเป็น NONE)
		if current_npc_type == NPCQuestSystem.NPC_TYPE.QUESTION and pending_quest_action == NPCQuestSystem.NEXT_ACTION.NONE:
			print("🔄 Transitioning: Intro -> Question Phase")
			
			# 1. เปลี่ยน Action เป็น ASK เพื่อให้รู้ว่าเข้าสู่โหมดถามแล้ว
			pending_quest_action = NPCQuestSystem.NEXT_ACTION.ASK
			
			# 2. โหลดคำถาม (question_text) มาใส่ในคิวบทพูดใหม่
			# หมายเหตุ: ใส่เป็น Array เพราะ dialog_queue รับ Array
			current_dialogue_queue = [quest_system.question_text] 
			
			# 3. รีเซ็ต Index เพื่อเริ่มพูดบรรทัดแรก (ซึ่งก็คือคำถาม)
			current_line_index = 0
			
			# 4. เรียกแสดงผลทันที (ห้าม end_dialogue)
			show_dialogue()
			return

func end_dialogue():
	print("\n>>> NPC.end_dialogue() called")
	print("  is_talking: ", is_talking)
	print("  is_question_phase: ", is_question_phase)
	print("  pending_quest_action: ", pending_quest_action)
	print()
	
	is_talking = false
	is_question_phase = false  # รีเซ็ต flag
	
	# 1. ทำ Action ของ Quest (เช่น รับเควส / รับรางวัล)
	if pending_quest_action != NPCQuestSystem.NEXT_ACTION.NONE:
		quest_system.perform_action(pending_quest_action)
		pending_quest_action = NPCQuestSystem.NEXT_ACTION.NONE
	
	# 2. ปิดปุ่มคำถาม (โดยการตั้งค่า current_npc เป็น null ใน pause.gd)
	if question_accept_btn:
		question_accept_btn.visible = false
		question_accept_btn.disabled = true
	if question_refuse_btn:
		question_refuse_btn.visible = false
		question_refuse_btn.disabled = true
	print("✅ NPC: Hidden question buttons")
	
	# 3. คืนค่า Player และ UI
	if Dialogue_sprite: Dialogue_sprite.visible = false
	if Anotation: Anotation.visible = true
	if world_camera: world_camera.release_focus()
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.is_talking = false
		player.showbar()
		
	# ล้างค่า
	current_dialogue_queue.clear()
	current_line_index = 0

# Override ฟังก์ชัน interact_event (ตามเดิมของคุณ)
func interact_event_in():
	if Anotation: Anotation.visible = true
func interact_event_out():
	if Anotation: Anotation.visible = false

# ฟังก์ชันจัดการปุ่ม Accept (รับภารกิจ)
func _on_question_accept_pressed() -> void:
	if not is_question_phase: return
	
	print("✅ NPC: Player accepted")
	
	# 🔥 จัดการตามประเภท action:
	if pending_quest_action == NPCQuestSystem.NEXT_ACTION.NONE:
		# ไม่ควรเข้าที่นี่ เพราะ NONE ไม่ emit signal
		print("⚠️ Accept pressed during NONE action - should not happen")
		return
	
	elif pending_quest_action == NPCQuestSystem.NEXT_ACTION.ASK or pending_quest_action == NPCQuestSystem.NEXT_ACTION.START_QUESTION:
		# QUESTION type: Player ตอบคำถาม
		if quest_system and quest_system.npc_type == NPCQuestSystem.NPC_TYPE.QUESTION:
			quest_system.is_question_answered = true
			print("💾 Set is_question_answered = true for NPC: ", quest_system.npc_name)
			
			# 🔥 แสดง accept_question_dialogue + question_text + question_ui
			is_talking = true
			is_question_phase = false
			
			# 1. แสดง accept_question_dialogue
			if quest_system.current_processing_quest:
				current_dialogue_queue.assign(quest_system.current_processing_quest.accept_question_dialogue)
			else:
				current_dialogue_queue = ["ขอบคุณ"]
			
			current_line_index = 0
			show_dialogue()
			
			# 2. emit signal ให้ pause.gd แสดง question_ui
			var pause_node = get_tree().root.find_child("pause", true, false)
			if pause_node:
				pause_node.show_question_ui_for_answer(quest_system.current_processing_quest.question_text if quest_system.current_processing_quest else "ตอบคำถาม")
				print("📢 Requesting question_ui from pause.gd")
			
			print("📢 Showing accept_question_dialogue + question_ui")
			# ❌ ไม่เรียก end_dialogue() - ให้ pause.gd จัดการเมื่อ player กด Submit
			return
		
		pending_quest_action = NPCQuestSystem.NEXT_ACTION.START_QUEST
		end_dialogue()
	
	elif pending_quest_action == NPCQuestSystem.NEXT_ACTION.START_QUEST:
		# QUEST_GIVER: ตอบ "จะรับหรือไม่"
		pending_quest_action = NPCQuestSystem.NEXT_ACTION.START_QUEST
		end_dialogue()

# ฟังก์ชันจัดการปุ่ม Refuse (ปฏิเสธภารกิจ)
func _on_question_refuse_pressed() -> void:
	if not is_question_phase: return
	
	print("❌ NPC: Player refused")
	
	# 🔥 จัดการตามประเภท action:
	if pending_quest_action == NPCQuestSystem.NEXT_ACTION.NONE:
		# ไม่ควรเข้าที่นี่ เพราะ NONE ไม่ emit signal
		print("⚠️ Refuse pressed during NONE action - should not happen")
		return
	
	elif pending_quest_action == NPCQuestSystem.NEXT_ACTION.ASK or pending_quest_action == NPCQuestSystem.NEXT_ACTION.START_QUESTION:
		# QUESTION type: Player ปฏิเสธตอบคำถาม
		pending_quest_action = NPCQuestSystem.NEXT_ACTION.NONE
		end_dialogue()
	
	elif pending_quest_action == NPCQuestSystem.NEXT_ACTION.START_QUEST:
		# QUEST_GIVER: ปฏิเสธรับเควส
		pending_quest_action = NPCQuestSystem.NEXT_ACTION.NONE
		end_dialogue()
