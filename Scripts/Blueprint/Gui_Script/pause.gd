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

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
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
	# เริ่มนับเวลาอีกครั้ง
	time_node.start_countdown()
	print("▶️ Game resumed")


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
