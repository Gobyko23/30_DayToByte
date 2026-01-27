extends Control


# อ้างอิง OptionLabel ตามเดิม
@onready var OptionLabel := $Option
# ตัวแปรสำหรับเก็บปุ่ม (ไม่ใช้ @onready)
var start_button: Button
var option_button: Button
var quit_button: Button
var back_button: Button

# การตั้งค่าขนาดฟอนต์
var normal_font_size: int = 40
var hover_font_size: int = 60
var tween_duration: float = 0.2

# Dictionary เก็บ Tween ของแต่ละปุ่ม
var button_tweens: Dictionary = {}

func _ready() -> void:
	# กำหนดค่าปุ่มจาก node path
	start_button = $VBoxContainer/Start_Button
	option_button = $VBoxContainer/Option_Button
	quit_button = $VBoxContainer/Quit_Button
	
	# หา back button ใน Option ถ้า back button เป็น child ของ Option
	if has_node("Option/BackButton"):
		back_button = $Option/BackButton
	elif has_node("Option/Back_Button"):
		back_button = $Option/Back_Button
	
	# ตรวจสอบว่าปุ่มถูกโหลดอย่างถูกต้อง
	if start_button == null:
		push_error("Start_Button not found!")
		return
	if option_button == null:
		push_error("Option_Button not found!")
		return
	if quit_button == null:
		push_error("Quit_Button not found!")
		return

	# เชื่อมต่อสัญญาณ hover สำหรับปุ่มทั้งหมด
	start_button.mouse_entered.connect(_on_start_button_hover_enter)
	start_button.mouse_exited.connect(_on_start_button_hover_exit)
	start_button.pressed.connect(_on_start_button_pressed)

	option_button.mouse_entered.connect(_on_option_button_hover_enter)
	option_button.mouse_exited.connect(_on_option_button_hover_exit)
	option_button.pressed.connect(_on_option_button_pressed)

	quit_button.mouse_entered.connect(_on_quit_button_hover_enter)
	quit_button.mouse_exited.connect(_on_quit_button_hover_exit)
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	# เชื่อมต่อสัญญาณ back button ถ้าพบ
	if back_button != null:
		back_button.pressed.connect(_on_back_button_pressed)

func _animate_font_size(button: Button, target_size: int, button_key: String) -> void:
	# ยกเลิก Tween เดิมถ้ามี
	if button_key in button_tweens and button_tweens[button_key]:
		button_tweens[button_key].kill()
	
	# สร้าง Tween ใหม่
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	var current_size = button.get_theme_font_size("font_size")
	tween.tween_method(
		func(size: int):
			button.add_theme_font_size_override("font_size", size),
			current_size,
			target_size,
			tween_duration
	)
	
	button_tweens[button_key] = tween

func _on_start_button_hover_enter() -> void:
	_animate_font_size(start_button, hover_font_size, "start")

func _on_start_button_hover_exit() -> void:
	_animate_font_size(start_button, normal_font_size, "start")

func _on_option_button_hover_enter() -> void:
	_animate_font_size(option_button, hover_font_size, "option")

func _on_option_button_hover_exit() -> void:
	_animate_font_size(option_button, normal_font_size, "option")

func _on_quit_button_hover_enter() -> void:
	_animate_font_size(quit_button, hover_font_size, "quit")

func _on_quit_button_hover_exit() -> void:
	_animate_font_size(quit_button, normal_font_size, "quit")

func _on_quit_button_pressed() -> void:
	
	get_tree().quit()


func _on_start_button_pressed() -> void:
	SceneLoader.load_scene("res://Scence/Stage/MainGame_OutSide.tscn")


func _on_option_button_pressed() -> void:
	if OptionLabel != null:
		OptionLabel.visible = !OptionLabel.visible
	else:
		push_error("Option not found at %Option!")

func _on_back_button_pressed() -> void:
	if OptionLabel != null:
		OptionLabel.visible = !OptionLabel.visible
	else:
		push_error("OptionLabel not found!")
