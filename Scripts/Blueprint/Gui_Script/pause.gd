extends CanvasLayer
@onready var pause: Control = %PauseGui
@onready var MenuItem: ItemList = %ItemList
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

# UI Container สำหรับแสดงคำถาม
var question_container: Control = null

var current_npc: NPC = null  # เก็บ NPC ที่กำลังคุย

func _ready() -> void:
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
	
	# 🔥 ค้นหา NPC และเชื่อม signal ไป
	var npc_nodes = get_tree().get_nodes_in_group("Npc")
	if npc_nodes.is_empty():
		print("⚠️ No NPCs found in 'Npc' group yet - will try in _process")
	else:
		print("✅ Found ", npc_nodes.size(), " NPCs in group")
	
	for npc in npc_nodes:
		print("DEBUG: Checking NPC: ", npc.name, " has signal? ", npc.has_signal("request_question_buttons"))
		if npc.has_signal("request_question_buttons"):
			if not npc.request_question_buttons.is_connected(_on_npc_request_question_buttons):
				npc.request_question_buttons.connect(_on_npc_request_question_buttons)
				print("✅ Connected to NPC: ", npc.name)
			else:
				print("⚠️ Already connected to NPC: ", npc.name)
		else:
			print("❌ NPC ", npc.name, " doesn't have request_question_buttons signal")




func _process(_delta: float) -> void:
	# 🔥 หาและเชื่อม NPC ที่พลาดไปใน _ready
	var npc_nodes = get_tree().get_nodes_in_group("Npc")
	for npc in npc_nodes:
		if npc.has_signal("request_question_buttons"):
			if not npc.request_question_buttons.is_connected(_on_npc_request_question_buttons):
				npc.request_question_buttons.connect(_on_npc_request_question_buttons)
				print("✅ Late Connection to NPC: ", npc.name)
	
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

	if Input.is_action_just_pressed("Esc"):
		pause.visible = !pause.visible
		option_gui.visible = false
		save_list_label.visible = false
		
		# Pause/Resume game process
		if pause.visible:
			_on_pause()
		else:
			_on_resume()
	
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
	get_tree().paused = false
	SceneLoader.load_scene("res://Menu_scence/Menu3D.tscn")


func _on_back_button_pressed() -> void:
	option_gui.visible = false


func _on_submit_pressed() -> void:
	if not question_ui.visible:
		return
	
	print("✅ Question submitted")
	var player_answer = text_ans.text
	print("User answered: ", player_answer)
	
	# 1. บันทึกคำตอบไปให้ NPC
	if current_npc and current_npc.quest_system:
		current_npc.quest_system.player_answer = player_answer
		print("💾 Saved player answer to NPC: ", player_answer)
	
	# 2. ล้างคำตอบและปิด UI
	text_ans.text = ""
	question_ui.visible = false
	
	# 3. จบบทสนทนา
	if current_npc:
		current_npc.end_dialogue()
		print("✅ NPC dialogue ended")
	
	# 4. Resume game
	_on_resume()


func _on_cancle_pressed() -> void:
	if not question_ui.visible:
		return
	
	print("❌ Question cancelled")
	text_ans.text = ""
	question_ui.visible = false
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

# 🔥 Callback เมื่อ NPC ส่ง request_question_buttons signal
func _on_npc_request_question_buttons(npc: NPC) -> void:
	print("📡 pause.gd: Received request_question_buttons signal from NPC: ", npc.name)
	print("DEBUG: accept_btn = ", accept_btn, " refuse_btn = ", refuse_btn)
	print("DEBUG: accept_btn is null? = ", accept_btn == null)
	print("DEBUG: refuse_btn is null? = ", refuse_btn == null)
	if accept_btn:
		print("DEBUG: accept_btn.visible before = ", accept_btn.visible)
	setup_npc_question_buttons(npc)


# เมธอดสำหรับตั้งค่าปุ่ม Accept/Refuse จาก NPC
func setup_npc_question_buttons(npc: NPC) -> void:
	current_npc = npc
	
	# ตรวจสอบว่าปุ่มมีอยู่และตั้งค่าให้ visible
	if accept_btn:
		accept_btn.visible = true
		accept_btn.disabled = false
		accept_btn.grab_focus()  # ให้ focus ไปที่ปุ่ม
		print("✅ Accept button visible, focused and enabled")
	else:
		print("⚠️ Accept button not found - trying to find it again")
		var root = get_tree().root
		accept_btn = root.find_child("Accept_btn", true, false)
		if accept_btn:
			accept_btn.visible = true
			accept_btn.disabled = false
			accept_btn.grab_focus()
			accept_btn.pressed.connect(_on_accept_btn_pressed)
			print("✅ Found, shown and focused Accept button")
	
	if refuse_btn:
		refuse_btn.visible = true
		refuse_btn.disabled = false
		print("✅ Refuse button visible and enabled")
	else:
		print("⚠️ Refuse button not found - trying to find it again")
		var root = get_tree().root
		refuse_btn = root.find_child("Refuse_btn", true, false)
		if refuse_btn:
			refuse_btn.visible = true
			refuse_btn.disabled = false
			refuse_btn.pressed.connect(_on_refuse_btn_pressed)
			print("✅ Found and shown Refuse button")
	
	# 🔥 ส่งปุ่มไปให้ NPC เพื่อใช้ในภายหลัง
	if npc:
		npc.set_question_buttons(accept_btn, refuse_btn)
		print("🔗 Buttons linked to NPC: ", npc.name)
	
	# Pause เกม เฉพาะเมื่อ QUEST_GIVER (ไม่ pause สำหรับ QUESTION type)
	if npc and npc.quest_system and npc.quest_system.npc_type != NPCQuestSystem.NPC_TYPE.QUESTION:
		_on_pause()
		print("⏸️ Game paused while showing question UI")
	else:
		print("⏭️ Game NOT paused for QUESTION type NPC")


# 🔥 ฟังก์ชันแสดง question_ui เมื่อ Player ตอบคำถาม
func show_question_ui_for_answer(question_text: String) -> void:
	print("📝 Showing question_ui for answer input")
	print("   Question: ", question_text)
	question_ui.visible = true
	text_ans.clear()
	text_ans.placeholder_text = question_text
	text_ans.grab_focus()
	_on_pause()  # pause game เมื่อแสดง question_ui
