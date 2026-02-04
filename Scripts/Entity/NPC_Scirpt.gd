extends Obj_Main
class_name NPC

# Signal: ส่งเมื่อ NPC ต้องการปุ่ม Accept/Refuse
signal request_question_buttons(npc: NPC)

@onready var Dialogue_sprite: Sprite3D = $NPC_Dialog
@onready var Dialogue_text: RichTextLabel = %ask_text
@onready var Anotation: Sprite3D = $NPC_UnknowTation
@onready var world_camera = get_tree().get_first_node_in_group("WorldCamera")
@onready var focus_marker: Marker3D = $NPC_Sprite/NpcPivot

# ระบบ Quest
@export var quest_system: NPCQuestSystem

# ตัวแปรจัดการบทพูด
var current_dialogue_queue: Array[String] = []
var current_line_index: int = 0
var current_npc_state: NPCQuestSystem.NPC_STATE = NPCQuestSystem.NPC_STATE.NONE
var is_talking: bool = false
var is_question_phase: bool = false  # ตัวแปรอ้างอิง: กำลังแสดงปุ่ม accept/refuse หรือไม่
var pending_quest_action: String = ""

# ปุ่ม UI
var question_accept_btn: Button
var question_refuse_btn: Button


func _ready() -> void:
	# 🔥 เพิ่ม NPC ไปยัง "Npc" group เพื่อให้ pause.gd หา ได้
	add_to_group("Npc")
	print("👥 NPC added to 'Npc' group: ", name)
	
	if Dialogue_text: 
		Dialogue_text.text = ""
	if Dialogue_sprite: 
		Dialogue_sprite.visible = false
	
	if quest_system:
		add_child(quest_system)
		quest_system.npc_name = String(name)
		print("✅ quest_system initialized for NPC: ", name)
	else:
		print("❌ quest_system is NULL for NPC: ", name)


func _input(event: InputEvent) -> void:
	# ถ้ากำลังคุยกับ NPC และกดปุ่ม interact
	if is_talking and event is InputEventAction:
		if event.is_action_pressed("interact"):
			# ❌ ถ้าอยู่ในสถานะ ASK หรือ START_QUESTION และแสดงปุ่ม ห้ามข้ามไป
			if (current_npc_state == NPCQuestSystem.NPC_STATE.ASK or current_npc_state == NPCQuestSystem.NPC_STATE.START_QUESTION) and is_question_phase:
				# ❌ ปิดกั้นการข้าม - ผู้เล่นต้องกดปุ่ม Accept/Refuse
				get_tree().root.set_input_as_handled()
				print("🚫 Cannot skip during question phase!")
				return
			
			# ✅ สถานะอื่นสามารถข้ามได้ปกติ
			next_dialogue()
			get_tree().root.set_input_as_handled()


func set_question_buttons(accept_btn: Button, refuse_btn: Button) -> void:
	question_accept_btn = accept_btn
	question_refuse_btn = refuse_btn
	if question_accept_btn:
		print("🔗 Accept button assigned to NPC")
	if question_refuse_btn:
		print("🔗 Refuse button assigned to NPC")


func interacting():
	"""เริ่มต้นการคุยกับ NPC"""
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.is_talking = true
		player.talking_npc = self
		if Anotation: 
			Anotation.visible = false
		if Dialogue_sprite: 
			Dialogue_sprite.visible = true
	
	is_talking = true
	print("\n" + "=".repeat(50))
	print("=== NPC.interacting() START ===")
	print("NPC name: ", name)
	print("NPC type: ", NPCQuestSystem.NPC_TYPE.keys()[quest_system.npc_type] if quest_system else "UNKNOWN")
	
	# ตรวจสอบว่า NPC อยู่ใน group ไหม
	print("Is in 'Npc' group? ", is_in_group("Npc"))
	print("Has signal 'request_question_buttons'? ", has_signal("request_question_buttons"))
	
	# ดึงข้อมูลจาก Quest System
	var interaction_data = quest_system.get_current_interaction()
	
	print("Current State: ", NPCQuestSystem.NPC_STATE.keys()[interaction_data["state"]])
	print("Dialogues count: ", interaction_data["dialogues"].size())
	print("=".repeat(50) + "\n")
	
	# ตั้งค่า
	current_dialogue_queue.assign(interaction_data["dialogues"])
	current_npc_state = interaction_data["state"]
	current_line_index = 0
	is_question_phase = false
	
	show_dialogue()


func show_dialogue():
	"""แสดงบทสนทนาหรือจัดการปุ่ม"""
	print("\n>>> NPC.show_dialogue() - State: ", NPCQuestSystem.NPC_STATE.keys()[current_npc_state])
	
	# จัดการกล้อง
	if not world_camera: 
		world_camera = get_tree().get_first_node_in_group("WorldCamera")
	if not focus_marker: 
		focus_marker = get_node_or_null("NPC_Sprite/NpcPivot")
	if world_camera and focus_marker: 
		world_camera.focus_on(focus_marker)
	
	# ========================================
	# สถานะ START_QUEST: ให้เควส
	# ========================================
	if current_npc_state == NPCQuestSystem.NPC_STATE.START_QUEST:
		pending_quest_action = str(NPCQuestSystem.NPC_STATE.START_QUEST)
		if current_line_index >= current_dialogue_queue.size():
			# จบบทสนทนาแล้ว ลองแสดงปุ่ม
			if not is_question_phase:
				is_question_phase = true
				print("🔄 NPC: Setting is_question_phase = true (START_QUEST)")
				
				if Dialogue_text:
					Dialogue_text.text = "จะรับภารกิจหรือไม่?"
					print("❓ Showing quest offer for QUEST_GIVER")
				
				# 🔍 Debug: ก่อน emit signal
				print("\n📡 === BEFORE EMIT ===")
				print("  self = ", self)
				print("  self.name = ", self.name)
				print("  is_in_group('Npc') = ", is_in_group("Npc"))
				print("  has_signal('request_question_buttons') = ", has_signal("request_question_buttons"))
				
				# ✅ Emit signal ทันทีเพื่อให้ pause.gd แสดงปุ่ม
				request_question_buttons.emit(self)
				print("📡 NPC: Emitted request_question_buttons signal (START_QUEST)")
				print("✅ Waiting for player to click Accept or Refuse...")
			return
		
		# แสดงบรรทัดถัดไป
		if current_line_index < current_dialogue_queue.size():
			if Dialogue_text:
				Dialogue_text.text = current_dialogue_queue[current_line_index]
			print("NPC Says: ", current_dialogue_queue[current_line_index])
		return
	
	# ========================================
	# สถานะ START_QUESTION: ถามคำถาม
	# ========================================
	if current_npc_state == NPCQuestSystem.NPC_STATE.START_QUESTION:
		pending_quest_action = str(NPCQuestSystem.NPC_STATE.START_QUESTION)
		# 🔥 ตรวจสอบว่าจบบทสนทนาแนะนำแล้วหรือยัง
		if current_line_index >= current_dialogue_queue.size():
			# จบบทสนทนาแล้ว → ต้อง emit signal เพื่อแสดงปุ่ม
			if not is_question_phase:
				is_question_phase = true
				print("🔄 NPC: Setting is_question_phase = true (START_QUESTION)")
				
				# ดึง question_text จาก current_processing_quest
				if quest_system and quest_system.current_processing_quest:
					var q_text = quest_system.current_processing_quest.question_text
					if Dialogue_text:
						Dialogue_text.text = q_text
					print("❓ Showing question for QUESTION type: ", q_text)
				
				# 🔍 Debug: ก่อน emit signal
				print("\n📡 === BEFORE EMIT (START_QUESTION) ===")
				print("  self = ", self)
				print("  self.name = ", self.name)
				print("  is_in_group('Npc') = ", is_in_group("Npc"))
				
				# ✅ Emit signal ทันทีเพื่อให้ pause.gd แสดงปุ่ม
				request_question_buttons.emit(self)
				print("📡 NPC: Emitted request_question_buttons signal (START_QUESTION)")
				print("✅ Waiting for player to click Accept or Refuse...")
			return
		
		# ยังไม่จบบทสนทนาแนะนำ → แสดงบรรทัดถัดไป
		if current_line_index < current_dialogue_queue.size():
			if Dialogue_text:
				Dialogue_text.text = current_dialogue_queue[current_line_index]
			print("NPC Says: ", current_dialogue_queue[current_line_index])
		
		return
	
	# ========================================
	# สถานะ ASK: กำลังถามจริง
	# ========================================
	if current_npc_state == NPCQuestSystem.NPC_STATE.ASK:
		pending_quest_action = str(NPCQuestSystem.NPC_STATE.ASK)
		if not is_question_phase:
			is_question_phase = true
			print("🔄 NPC: Setting is_question_phase = true (ASK)")
			
			if Dialogue_text and quest_system and quest_system.current_processing_quest:
				Dialogue_text.text = quest_system.current_processing_quest.question_text
				print("❓ Showing question_text for ASK state")
			
			# ✅ Emit signal ทันทีเพื่อให้ pause.gd แสดงปุ่ม
			request_question_buttons.emit(self)
			print("📡 NPC: Emitted request_question_buttons signal (ASK)")
			print("✅ Waiting for player to click Accept or Refuse...")
		return
	
	# ========================================
	# สถานะอื่นๆ: NONE, COMPLETE_QUEST
	# ========================================
	if current_line_index < current_dialogue_queue.size():
		if Dialogue_text:
			Dialogue_text.text = current_dialogue_queue[current_line_index]
		print("NPC Says: ", current_dialogue_queue[current_line_index])
	else:
		# บทสนทนาหมดแล้ว
		end_dialogue()


func next_dialogue():
	"""ไปบรรทัดถัดไป"""
	if not is_talking: 
		return
	
	print("\n>>> NPC.next_dialogue() - current_line: ", current_line_index, " -> ", current_line_index + 1)
	
	current_line_index += 1
	
	# 🔥 เรียก show_dialogue() เสมอ เพื่อให้ show_dialogue() ตัดสินใจว่า:
	# - แสดงบรรทัดถัดไป
	# - emit signal (ถ้าจบแล้ว)
	# - end dialogue (ถ้าจบจริงๆ)
	print("✅ Calling show_dialogue() to check state...")
	show_dialogue()


func end_dialogue():
	"""จบการสนทนา"""
	print("\n>>> NPC.end_dialogue()")
	print("  current_npc_state: ", NPCQuestSystem.NPC_STATE.keys()[current_npc_state])
	print("  is_question_phase: ", is_question_phase)
	print()
	
	is_talking = false
	is_question_phase = false
	
	# ทำ Action ตามสถานะ
	if current_npc_state != NPCQuestSystem.NPC_STATE.NONE:
		quest_system.perform_action(current_npc_state)
		current_npc_state = NPCQuestSystem.NPC_STATE.NONE
	
	# ปิดปุ่ม
	if question_accept_btn:
		question_accept_btn.visible = false
		question_accept_btn.disabled = true
	if question_refuse_btn:
		question_refuse_btn.visible = false
		question_refuse_btn.disabled = true
	print("✅ NPC: Hidden question buttons")
	
	# คืนค่า Player และ UI
	if Dialogue_sprite: 
		Dialogue_sprite.visible = false
	if Anotation: 
		Anotation.visible = true
	if world_camera: 
		world_camera.release_focus()
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.is_talking = false
		player.showbar()
	
	# ล้างค่า
	current_dialogue_queue.clear()
	current_line_index = 0


# Override ฟังก์ชัน interact
func interact_event_in():
	if Anotation: 
		Anotation.visible = true

func interact_event_out():
	if Anotation: 
		Anotation.visible = false


# ========================================
# ฟังก์ชันจัดการปุ่ม Accept
# ========================================
func _on_question_accept_pressed() -> void:
	if not is_question_phase: 
		return
	
	if question_accept_btn:
		question_accept_btn.visible = false
	if question_refuse_btn:
		question_refuse_btn.visible = false
	
	
	print("✅ NPC: Player accepted")
	
	# ========================================
	# START_QUEST: ผู้เล่นตกลงรับเควส
	# ========================================
	if current_npc_state == NPCQuestSystem.NPC_STATE.START_QUEST:
		print("📋 QUEST_GIVER: Player accepted quest")
		is_question_phase = false
		end_dialogue()
		return
	
	# ========================================
	# START_QUESTION: ผู้เล่นตกลงตอบคำถาม
	# ========================================
	if current_npc_state == NPCQuestSystem.NPC_STATE.START_QUESTION:
		print("❓ QUESTION: Player accepted to answer")
		quest_system.is_question_answered = true
		
		# แสดง accept_question_dialogue
		is_talking = true
		is_question_phase = false
		
		if quest_system.current_processing_quest:
			current_dialogue_queue.assign(quest_system.current_processing_quest.accept_question_dialogue)
		else:
			current_dialogue_queue = ["ขอบคุณ"]
		
		current_line_index = 0
		print("📢 Showing accept_question_dialogue before question_ui")
		
		show_dialogue()
		
		# รอ 1 วินาที แล้วแสดง question_ui
		await get_tree().create_timer(1.0).timeout
		
		var pause_node = get_tree().root.find_child("Pause", true, false)
		if pause_node and quest_system and quest_system.current_processing_quest:
			pause_node.show_question_ui_for_answer(quest_system.current_processing_quest.question_text)
			print("📢 Showing question_ui for player to input answer")

		return
	
	# ========================================
	# ASK: ผู้เล่นกำลังตอบคำถาม
	# ========================================
	if current_npc_state == NPCQuestSystem.NPC_STATE.ASK:
		print("❓ ASK: Player accepted - showing question_ui")
		is_question_phase = false
		
		var pause_node = get_tree().root.find_child("Pause", true, false)
		if pause_node and quest_system and quest_system.current_processing_quest:
			pause_node.show_question_ui_for_answer(quest_system.current_processing_quest.question_text)
			print("📢 Showing question_ui")
		
		return


# ========================================
# ฟังก์ชันจัดการปุ่ม Refuse
# ========================================
func _on_question_refuse_pressed() -> void:
	if not is_question_phase: 
		return
	
	print("❌ NPC: Player refused")
	
	# ========================================
	# START_QUEST: ผู้เล่นปฏิเสธเควส
	# ========================================
	if current_npc_state == NPCQuestSystem.NPC_STATE.START_QUEST:
		print("📋 QUEST_GIVER: Player refused quest")
		is_question_phase = false
		end_dialogue()
		return
	
	# ========================================
	# START_QUESTION: ผู้เล่นปฏิเสธตอบคำถาม
	# ========================================
	if current_npc_state == NPCQuestSystem.NPC_STATE.START_QUESTION:
		print("❓ QUESTION: Player refused to answer")
		is_question_phase = false
		end_dialogue()
		return
	
	# ========================================
	# ASK: ผู้เล่นปฏิเสธตอบคำถาม
	# ========================================
	if current_npc_state == NPCQuestSystem.NPC_STATE.ASK:
		print("❓ ASK: Player refused to answer")
		is_question_phase = false
		end_dialogue()
		return

func on_question_cancle() -> void:
# ลบหรือคอมเมนต์บรรทัดตรวจสอบ is_question_phase ออก 
	# หรือตรวจสอบว่ากำลังคุยอยู่หรือไม่แทน
	if not is_talking: 
		return
	
	print("❌ NPC: Player cancelled from Question UI")
	
	# บังคับจบการสนทนาทันที
	is_question_phase = false
	end_dialogue()
