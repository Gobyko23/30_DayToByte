extends CanvasLayer
@onready var pause: Control = %PauseGui
@onready var MenuItem: ItemList = %ItemList
@onready var Item_amount: RichTextLabel = %RichTextLabel
@onready var quest_panel: Panel = $Interact_Screen/QuestPanel
@onready var quest_text_label: RichTextLabel = $Interact_Screen/QuestPanel/QuestTextLabel
@onready var save_game_button: Button = $PauseGui/ColorRect/CenterContainer/SaveGameButton
@onready var option_button: Button = $PauseGui/ColorRect/CenterContainer/OptionButton
@onready var resume_button: Button = $PauseGui/ColorRect/CenterContainer/ResumeButton
@onready var btmbutton: Button = $PauseGui/ColorRect/CenterContainer/BTMButton
@onready var save_list_label: Label = $PauseGui/SaveListLabel
@onready var option_gui: Control = %OptionGui
@onready var back_button: Button = $OptionGui/CenterContainer2/VBoxContainer/BackButton
@onready var time_node: Node = %TimeNode

@onready var question_ui: Control = $Question_ui
@onready var text_ans: TextEdit = %TextAns

@onready var submit: Button = %Submit
@onready var cancle: Button = %Cancle
@onready var accept_btn: Button = %Accept_btn
@onready var refuse_btn: Button = %Refuse_btn
@onready var question_label: RichTextLabel = $Question_ui/ColorRect/VBoxContainer/Question_text
# UI Container สำหรับแสดงคำถาม
var question_container: Control = null

var current_npc: NPC = null  # เก็บ NPC ที่กำลังคุย

func _ready() -> void:
	Item_amount.visible = false
	MenuItem.visible = false
	quest_panel.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# ตั้งค่าปุ่ม Accept/Refuse
	
	# เชื่อม Signal กับปุ่ม
	if accept_btn:
		accept_btn.pressed.connect(_on_accept_btn_pressed)
		print("✅ Accept button signal connected")
		accept_btn.visible = false  # ซ่อนไว้เป็นค่าเริ่มต้น
	else:
		print("❌ Accept button not found!")
		
	if refuse_btn:
		refuse_btn.pressed.connect(_on_refuse_btn_pressed)
		print("✅ Refuse button signal connected")
		refuse_btn.visible = false  # ซ่อนไว้เป็นค่าเริ่มต้น
	else:
		print("❌ Refuse button not found!")
	
	# เชื่อม Signal สำหรับปุ่มคำถาม
	if submit:
		submit.pressed.connect(_on_submit_pressed)
	if cancle:
		cancle.pressed.connect(_on_cancle_pressed)
	
	# 🔥 เชื่อมต่อ NPC signals ทั้งหมด
	_connect_all_npc_signals()
	print("✅ pause.gd._ready() completed - NPC signal connections established")


# 🔥 ฟังก์ชัน Helper: เชื่อมต่อ signals จากทั้งหมด NPC
func _connect_all_npc_signals() -> void:
	var npc_nodes = get_tree().get_nodes_in_group("Npc")
	print("🔍 _connect_all_npc_signals(): Found ", npc_nodes.size(), " NPCs")
	
	for npc in npc_nodes:
		if not npc:
			print("⚠️ NPC node is null, skipping")
			continue
			
		print("  📌 Checking NPC: ", npc.name)
		
		if not npc.has_signal("request_question_buttons"):
			print("  ❌ NPC ", npc.name, " doesn't have request_question_buttons signal")
			continue
		
		# ตรวจสอบว่า signal ยังไม่เชื่อมต่อ
		if npc.request_question_buttons.is_connected(_on_npc_request_question_buttons):
			print("  ⚠️ Already connected to NPC: ", npc.name)
		else:
			# เชื่อมต่อ signal
			npc.request_question_buttons.connect(_on_npc_request_question_buttons)
			print("  ✅ Connected request_question_buttons signal from NPC: ", npc.name)




func _process(_delta: float) -> void:

	# 🔥 หาและเชื่อม NPC ที่เกิดขึ้นทีหลัง (dynamically spawned NPCs)
	# เพียงทำครั้งเดียว และตรวจสอบถ้ามี NPC ใหม่ที่ยังไม่เชื่อมต่อ
	if quest_panel.visible:
		cuurent_quest_text()
	var npc_nodes = get_tree().get_nodes_in_group("Npc")
	for npc in npc_nodes:
		if not npc:
			continue
		
		# ถ้า signal มีแต่ยังไม่เชื่อมต่อ ให้เชื่อมต่อ
		if npc.has_signal("request_question_buttons"):
			if not npc.request_question_buttons.is_connected(_on_npc_request_question_buttons):
				npc.request_question_buttons.connect(_on_npc_request_question_buttons)
				print("✅ Late-bind: Connected request_question_buttons signal from NPC: ", npc.name)

	# Debug: แสดงสถานะปุ่ม
	if Input.is_action_just_pressed("inventory_menu"):  # ทดสอบด้วยปุ่ม Home
		print("=== DEBUG STATUS ===")
		print("accept_btn: ", accept_btn, " visible: ", accept_btn.visible if accept_btn else "NULL")
		print("refuse_btn: ", refuse_btn, " visible: ", refuse_btn.visible if refuse_btn else "NULL")
		print("current_npc: ", current_npc)
		print("NPC group members: ", get_tree().get_nodes_in_group("Npc"))
		print("==================")
	
	if Input.is_action_just_pressed("inventory_menu"):
		MenuItem.visible = !MenuItem.visible
		quest_panel.visible = !quest_panel.visible
		Item_amount.visible = !Item_amount.visible

	if Input.is_action_just_pressed("Esc"):
		pause.visible = !pause.visible
		option_gui.visible = false
		save_list_label.visible = false
		
		# Pause/Resume game process
		if pause.visible:
			_on_pause()
		else:
			_on_resume()

func cuurent_quest_text() -> void:
# 1. ดึงรายการเควสที่กำลังทำทั้งหมดจาก QuestManager
	var active_quests = QuestManager.get_all_active_quests()
	
	if active_quests.size() > 0:
		var current_quest = active_quests[0]
		
		# ส่วนแสดงผลชื่อและรายละเอียดหลัก
		var display_text = "ภารกิจ: " + current_quest.quest_name + "\n"
		display_text += "รายละเอียด: " + current_quest.description + "\n"
		
		# ส่วนแสดงเงื่อนไข (Objective)
		if current_quest.required_amount > 0:
			display_text += "เป้าหมาย: เก็บ %s\n" % current_quest.target_item_id
			display_text += "ความคืบหน้า: %d / %d" % [current_quest.current_amount, current_quest.required_amount]
			
			if current_quest.current_amount >= current_quest.required_amount:
				display_text += " (สำเร็จแล้ว! กลับไปหา NPC)"
		
		quest_text_label.text = display_text
	else:
		quest_text_label.text = "ไม่มีภารกิจที่กำลังทำในขณะนี้"

func _on_pause() -> void:
	"""หยุด game process (ยกเว้น UI)"""
	get_tree().paused = true
	# หยุดนับเวลาด้วย
	time_node.stop_countdown()
	print("⏸️ Game paused")


func _on_resume() -> void:
	"""เริ่มต้น game process อีกครั้ง"""
	print("🔧 _on_resume() called - get_tree().paused = ", get_tree().paused)
	# เริ่มนับเวลาอีกครั้ง
	time_node.start_countdown()
	get_tree().paused = false
	print("▶️ Game resumed - get_tree().paused = ", get_tree().paused)


func _on_resume_button_pressed() -> void:
	pause.visible = false
	save_list_label.visible = false
	_on_resume()

func _on_save_game_button_pressed() -> void:
	save_list_label.visible = true
	
	# 1. ทำการ Duplicate (Instance) ปุ่มต้นแบบออกมา
	var new_back_btn = back_button.duplicate()

	# 2. ตั้งค่าชื่อและข้อความใหม่ (ถ้าต้องการให้ต่างจากปุ่มเดิม)
	new_back_btn.name = "DynamicBackButton"
	new_back_btn.text = "Back"
	new_back_btn.add_theme_font_size_override("font_size", 26)
	new_back_btn.custom_minimum_size = Vector2(0, 50)
	new_back_btn.visible = true # มั่นใจว่าปุ่มใหม่จะแสดงผล
	
	# 3. นำไปใส่ในที่ที่ต้องการ (เช่น ใส่ไว้ใน PauseGui)
	# สมมติว่าต้องการใส่ไว้ใต้ save_list_label
	%SaveLoadVbox.add_child(new_back_btn)
	
	# 4. เชื่อม Signal ให้ทำงาน (เพราะการ duplicate ไม่ได้เอา signal เดิมมาด้วยในบางกรณี)
	new_back_btn.pressed.connect(_on_dynamic_back_pressed.bind(new_back_btn))

# ฟังก์ชันสำหรับปุ่มที่สร้างขึ้นมาใหม่
func _on_dynamic_back_pressed(btn: Button) -> void:
	save_list_label.visible = false
	# คุยจบแล้ว หรือกดถอยหลังแล้ว ให้ลบปุ่มที่สร้างมาทิ้ง
	btn.queue_free()

func _on_option_button_pressed() -> void:
	option_gui.visible = true


func _on_btm_button_pressed() -> void:
	print("🔙 Back to menu: Resetting all game data...")
    
    # 1. รีเซ็ตทุกระบบที่เป็น Autoload
	if PointSystem.has_method("reset_system"):
		PointSystem.reset_system()
        
	if QuestManager.has_method("reset_system"):
		QuestManager.reset_system()
        
	if PlayerData.has_method("reset_system"):
		PlayerData.reset_system()
	
	if NPCManager.has_method("reset_all_npc_states"):
		NPCManager.reset_all_npc_states()
    
    # 2. ปลดล็อก Pause (ถ้าเกมค้าง Pause อยู่)
	get_tree().paused = false
    
    # 3. กลับหน้าเมนู
	SceneLoader.load_scene("res://Menu_scence/Menu3D.tscn")


func _on_back_button_pressed() -> void:
	option_gui.visible = false


func _on_submit_pressed() -> void:
	if not question_ui.visible:
		return
    
	var player_answer = text_ans.text.strip_edges()
    
	if current_npc and current_npc.quest_system:
		var system = current_npc.quest_system
        
        # 🔥 ใช้ฟังก์ชันของระบบเควสเช็คคำตอบ (ที่เราแก้เรื่องเงินไว้ในไฟล์ NPC_Quest_System.gd)
		var is_correct = system.check_text_answer(player_answer)
        
		if is_correct:
			print("✅ UI: Answer Correct - Money should be added via NPCQuestSystem")
            # เปลี่ยนบทพูดเป็นบทตอบถูก
			current_npc.current_dialogue_queue.assign(system.correct_dialogue)
		else:
			print("❌ UI: Answer Wrong")
            # เปลี่ยนบทพูดเป็นบทตอบผิด
			current_npc.current_dialogue_queue.assign(system.wrong_dialogue)
            
		current_npc.current_line_index = 0
	# ปิด UI และแสดงบทพูดสรุปผลจาก NPC
	text_ans.text = ""
	question_ui.visible = false
	
	if current_npc:
		current_npc.show_dialogue()
		await get_tree().create_timer(1.5).timeout
		current_npc.end_dialogue()
	
	_on_resume()


func _on_cancle_pressed() -> void:
	if not question_ui.visible:
		return
	
	print("❌ Question cancelled")
	text_ans.text = ""
	question_ui.visible = false
	# จบบทสนทนา
	if current_npc:
		current_npc.on_question_cancle()
		print("Pending Quest Action: ", current_npc.pending_quest_action)
	else:
		print("❌ current_npc is null!")
	_on_resume()

# Signal handlers for Accept/Refuse buttons
func _on_accept_btn_pressed() -> void:
	print("\n=== ACCEPT BUTTON PRESSED ===")
	print("✅ Player accepted - current_npc = ", current_npc)
	if current_npc:

		print("DEBUG BEFORE: is_talking = ", current_npc.is_talking)
		print("DEBUG BEFORE: is_question_phase = ", current_npc.is_question_phase)
		print("DEBUG BEFORE: pending_quest_action = ", current_npc.pending_quest_action)
		print("DEBUG BEFORE: NPC type = ", current_npc.quest_system.npc_type if current_npc.quest_system else "null")
	
	# ⚠️ ไม่เรียก _on_resume() ก่อน! ให้ NPC จัดการ
	if current_npc:
		current_npc._on_question_accept_pressed()
		print("✅ Called NPC._on_question_accept_pressed()")
	else:
		print("❌ current_npc is null!")
	
	print("DEBUG AFTER: is_talking = ", current_npc.is_talking if current_npc else "null")
	print("DEBUG AFTER: is_question_phase = ", current_npc.is_question_phase if current_npc else "null")
	print("===========================\n")

func _on_refuse_btn_pressed() -> void:
	print("❌ Player refused the quest - current_npc = ", current_npc)
	_on_resume()
	if current_npc:
		current_npc._on_question_refuse_pressed()
		print("❌ Called NPC._on_question_refuse_pressed()")
	else:
		print("❌ current_npc is null!")

func _on_exit_btn_pressed() -> void:
	quest_panel.visible = false


# 🔥 Callback เมื่อ NPC ส่ง request_question_buttons signal
func _on_npc_request_question_buttons(npc: NPC) -> void:
	print("\n" + "=".repeat(60))
	print("📡 === SIGNAL RECEIVED in pause.gd ===")
	print("📡 pause.gd: Received request_question_buttons signal from NPC: ", npc.name)
	print("  📌 NPC state: ", NPCQuestSystem.NPC_STATE.keys()[npc.current_npc_state])
	print("  📌 is_question_phase: ", npc.is_question_phase)
	
	# Failsafe: ตรวจสอบ button references
	print("  🔍 Button check BEFORE setup:")
	print("    - accept_btn exists? ", accept_btn != null, " (visible: ", accept_btn.visible if accept_btn else "N/A", ")")
	print("    - refuse_btn exists? ", refuse_btn != null, " (visible: ", refuse_btn.visible if refuse_btn else "N/A", ")")
	
	# ถ้า buttons เป็น null ให้ค้นหาใหม่
	if not accept_btn or accept_btn == null:
		print("  ⚠️ accept_btn is null - finding again...")
		accept_btn = get_tree().root.find_child("Accept_btn", true, false)
		if accept_btn:
			print("  ✅ Found accept_btn")
		else:
			print("  ❌ CRITICAL: accept_btn not found in tree!")
			
	if not refuse_btn or refuse_btn == null:
		print("  ⚠️ refuse_btn is null - finding again...")
		refuse_btn = get_tree().root.find_child("Refuse_btn", true, false)
		if refuse_btn:
			print("  ✅ Found refuse_btn")
		else:
			print("  ❌ CRITICAL: refuse_btn not found in tree!")
	
	# เรียก setup function
	print("📡 === CALLING setup_npc_question_buttons() ===")
	setup_npc_question_buttons(npc)
	print("📡 === SIGNAL CALLBACK COMPLETED ===")
	print("=".repeat(60) + "\n")


# เมธอดสำหรับตั้งค่าปุ่ม Accept/Refuse จาก NPC
func setup_npc_question_buttons(npc: NPC) -> void:
	print("\n>>> setup_npc_question_buttons() START")
	current_npc = npc
	
	# ตรวจสอบว่าปุ่มมีอยู่และตั้งค่าให้ visible
	print("  🔍 accept_btn check:")
	print("    - accept_btn = ", accept_btn)
	print("    - accept_btn is null? = ", accept_btn == null)
	if accept_btn:
		print("    - accept_btn.visible BEFORE = ", accept_btn.visible)
		print("    - accept_btn.disabled BEFORE = ", accept_btn.disabled)
	
	if accept_btn:
		print("  ✅ Setting accept_btn.visible = true")
		accept_btn.visible = true
		accept_btn.disabled = false
		accept_btn.grab_focus()  # ให้ focus ไปที่ปุ่ม
		print("    - accept_btn.visible AFTER = ", accept_btn.visible)
		print("    - accept_btn.disabled AFTER = ", accept_btn.disabled)
		print("✅ Accept button visible, focused and enabled")
	else:
		print("⚠️ Accept button not found - trying to find it again")
		var root = get_tree().root
		accept_btn = root.find_child("Accept_btn", true, false)
		if accept_btn:
			print("  ✅ Found accept_btn, setting visible")
			accept_btn.visible = true
			accept_btn.disabled = false
			accept_btn.grab_focus()
			accept_btn.pressed.connect(_on_accept_btn_pressed)
			print("✅ Found, shown and focused Accept button")
		else:
			print("  ❌ CRITICAL: accept_btn still not found!")
	
	print("  🔍 refuse_btn check:")
	print("    - refuse_btn = ", refuse_btn)
	print("    - refuse_btn is null? = ", refuse_btn == null)
	if refuse_btn:
		print("    - refuse_btn.visible BEFORE = ", refuse_btn.visible)
		print("    - refuse_btn.disabled BEFORE = ", refuse_btn.disabled)
	
	if refuse_btn:
		print("  ✅ Setting refuse_btn.visible = true")
		refuse_btn.visible = true
		refuse_btn.disabled = false
		print("    - refuse_btn.visible AFTER = ", refuse_btn.visible)
		print("    - refuse_btn.disabled AFTER = ", refuse_btn.disabled)
		print("✅ Refuse button visible and enabled")
	else:
		print("⚠️ Refuse button not found - trying to find it again")
		var root = get_tree().root
		refuse_btn = root.find_child("Refuse_btn", true, false)
		if refuse_btn:
			print("  ✅ Found refuse_btn, setting visible")
			refuse_btn.visible = true
			refuse_btn.disabled = false
			refuse_btn.pressed.connect(_on_refuse_btn_pressed)
			print("✅ Found and shown Refuse button")
		else:
			print("  ❌ CRITICAL: refuse_btn still not found!")
	
	# 🔥 ส่งปุ่มไปให้ NPC เพื่อใช้ในภายหลัง
	if npc:
		npc.set_question_buttons(accept_btn, refuse_btn)
		print("🔗 Buttons linked to NPC: ", npc.name)
	
	# Pause เกม เฉพาะเมื่อ QUEST_GIVER (ไม่ pause สำหรับ QUESTION type)
	if npc and npc.quest_system and npc.quest_system.npc_type != NPCQuestSystem.NPC_TYPE.QUESTION:
		print("⏸️ Game paused while showing question UI")
	else:
		print("⏭️ Game NOT paused for QUESTION type NPC")
	
	print(">>> setup_npc_question_buttons() END\n")


# 🔥 ฟังก์ชันแสดง question_ui เมื่อ Player ตอบคำถาม
func show_question_ui_for_answer(question_text: String) -> void:
	print("📝 Showing question_ui for answer input")
	print("   Question: ", question_text)
	question_ui.visible = true
	text_ans.clear()
	text_ans.placeholder_text = question_text
	question_label.text = str(current_npc.quest_system.question_text)
	text_ans.grab_focus()
