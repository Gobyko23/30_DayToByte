extends Node3D

@onready var player: Node3D = $Player
@onready var player_spawn: Marker3D = $PlayerSpawn
@onready var end_gui: CanvasLayer = %EndLayer  # เชื่อมต่อกับ endGui ด้วย unique name
@onready var time_node: Node = %TimeNode
@onready var waiting_gui: Control = $Pause/WaitingGui
@onready var end_round: Panel = %EndRound
@onready var begin: Panel = %Begin
@onready var text_begin: RichTextLabel = $Pause/WaitingGui/Begin/Text_Begin
@onready var text_end: RichTextLabel = $Pause/WaitingGui/EndRound/VBoxContainer/Text_End
@onready var typing_sfx: AudioStreamPlayer = %TypingSFX
@onready var success_sfx: AudioStreamPlayer = $Pause/SuccessSFX

var last_visible_count: int = 0

func _ready():
	# 1. หยุดทุกอย่างไว้ก่อนทันทีที่เข้าฉาก
	time_node.stop_countdown()
	player.set_physics_process(false)

	# 2. ทำการ Restore ค่าวันจาก PlayerData ก่อน (ทำก่อนเวลาจะเริ่มเดิน)
	if "current_day" in PlayerData and PlayerData.current_day > 0:
		var saved_day = PlayerData.current_day
		time_node.day = saved_day
		print("📅 Restored day value from PlayerData: %d" % saved_day)
	
	# 3. ย้ายผู้เล่นไปจุดสปอว์น
	if player and player_spawn:
		player.global_position = player_spawn.global_position
		print("📍 Player position set to spawn point")

	# 4. เชื่อมต่อ Signal ต่างๆ
	SaveAndLoad.request_load.connect(_on_request_load)
	SaveAndLoad.request_save.connect(_on_request_save)
	QuestManager.quest_completed.connect(_play_quest_success_sound)

	if not time_node.countdown_finished.is_connected(_on_countdown_finished):
		time_node.countdown_finished.connect(_on_countdown_finished)

	# 5. เริ่มเล่น Tween หน้าจอ (ระหว่างนี้เวลายังไม่เดินเพราะ set_process ยังเป็น false)
	var fade_tween = fade_in_screen()

	# 6. รอจนกว่า Fade จะเสร็จสมบูรณ์
	await fade_tween.finished
	await get_tree().create_timer(0.1).timeout
	# 7. เมื่อหน้าจอสว่างแล้วค่อยปลดล็อกให้เริ่มเล่นและเริ่มนับเวลา
	time_node.start_countdown()
	player.set_physics_process(true)
	print("🚀 Game Start - Timer running")
	

	'''
	# โหลดเกมตอนเริ่มต้น ถ้า GlobalSaveSlot ถูกตั้งค่า
	var slot_id = PlayerData.GlobalSaveSlot
	if slot_id != -1:
		print("📂 Loading save slot: ", slot_id)
		SaveAndLoad.request_load.emit(slot_id)
	else:
		print("⚠️ No save slot specified") 
	'''

func _on_countdown_finished() -> void:
	"""เรียกเมื่อเวลานับถ่อยหลังเสร็จ"""
	print("🏁 Countdown finished! Processing day completion...")
	
	# 1. ย้ายผู้เล่นไปที่ PlayerSpawn

	
	# 2. ตรวจสอบว่าครบ 3 วันหรือไม่
	if time_node.day > time_node.max_days:
		print("🎉 Day %d completed! Showing end GUI..." % time_node.max_days)
		time_node.stop_countdown()
		player.set_physics_process(false)
		_show_end_gui()
	else:
		# 3. Save day value ก่อน reload scene (TimeManager ได้เพิ่มแล้ว)
		PlayerData.current_day = time_node.day
		print("💾 Saved day value to PlayerData: %d" % time_node.day)
		
		# 4. Reset countdown state ของ TimeNode ก่อน reload scene
		print("🔄 Resetting countdown for next day...")
		
		# 5. Reload scene ถ้ายังไม่ครบวันสูงสุด
		fade_out_to_next_day()


func _show_end_gui() -> void:

	"""แสดงหน้าต่าง endGui"""
	if not end_gui:
		push_error("❌ End GUI not found! Make sure the node has unique name %EndGui")
		return
	
	end_gui.visible = true
	print("✅ End GUI shown")
	
	# อัปเดตคะแนนทั้งหมด
	var score_text = end_gui.find_child("TotalScoreText", true, false)
	if score_text:
		score_text.text = "[center][b]Game Complete![/b]\nTotal Score: %d\nDay: %d/%d[/center]" % [PointSystem.points, time_node.day -1, time_node.max_days]
		print("📊 Total Score: ", PointSystem.points)
	else:
		push_error("❌ TotalScoreText node not found in End GUI!")


func fade_out_to_next_day() -> Tween:
	time_node.stop_countdown()
	player.set_physics_process(false)
	"""ฟังก์ชันสำหรับทำหน้าจอค่อยๆ มืดลงเมื่อจบวัน"""
	end_round.visible = true
	begin.visible = false
	end_round.modulate.a = 0.0
	text_end.visible_ratio = 0.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(end_round, "modulate:a", 1.0, 1.0) # จอค่อยๆ มืด
	tween.tween_method(_update_typing_ui, 0.0, 1.0, 2.0)
	return tween

func fade_in_screen() -> Tween:
	"""ฟังก์ชันสำหรับทำหน้าจอค่อยๆ สว่างขึ้นเมื่อเริ่มเกม"""
# เตรียมหน้าจอให้ดำก่อนในเฟรมแรก
	waiting_gui.visible = true
	end_round.visible = false
	begin.visible = true
	begin.modulate.a = 1.0
	text_begin.text = "DAY " + str(time_node.day)
	text_begin.visible_ratio = 0.0
	last_visible_count = 0 # รีเซ็ตตัวนับ
	
	# สร้าง Tween สำหรับ Fade In (สว่างขึ้น)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(begin, "modulate:a", 0.0, 3.0) # จอค่อยๆ สว่าง
	tween.tween_method(_update_typing_ui, 0.0, 1.0, 1.0)
	return tween

# ฟังก์ชันที่จะถูก Tween เรียกซ้ำๆ
func _update_typing_ui(ratio: float):
	var current_count: int = 0
	
	# เช็คว่าตอนนี้หน้าไหนกำลังแสดงอยู่ เพื่อเลือก Label และนับตัวอักษรให้ถูกตัว
	if begin.visible:
		text_begin.visible_ratio = ratio
		current_count = int(ratio * text_begin.get_total_character_count())
	elif end_round.visible:
		text_end.visible_ratio = ratio
		current_count = int(ratio * text_end.get_total_character_count())
	
	# 🎹 ถ้าจำนวนตัวอักษรเพิ่มขึ้น ให้เล่นเสียง
	if current_count > last_visible_count:
		if typing_sfx:
			# สุ่ม Pitch เพื่อความสมจริง
			typing_sfx.pitch_scale = randf_range(0.8, 1.2)
			typing_sfx.play()
		last_visible_count = current_count

func _on_request_save(slot: int) -> void:
	print("💾 Saving to slot: ", slot)
	# ส่ง time_node ไปให้ SaveAndLoadscript เพื่อจัดการเวลา
	SaveAndLoad.save_game(slot, player, time_node)


func _on_request_load(slot: int) -> void:
	print("📥 Loading from slot: ", slot)
	# ส่ง time_node ไปให้ SaveAndLoadscript เพื่อคืนค่าข้อมูลเวลา
	SaveAndLoad._on_request_load(slot)


func _on_back_pressed() -> void:
	PlayerData.current_day = 0
	SceneLoader.load_scene("res://Menu_scence/Menu3D.tscn")


func _on_next_pressed() -> void:
	"""เรียกเมื่อกดปุ่ม Next Day ใน endGui"""
	print("➡️ Next Day button pressed.")
	    
    # 1. รีเซ็ตทุกระบบที่เป็น Autoload
        
	if QuestManager.has_method("reset_system"):
		QuestManager.reset_system()
	
	if NPCManager.has_method("reset_all_npc_states"):
		NPCManager.reset_all_npc_states()

	# 1. ย้ายตำแหน่งผู้เล่น (เผื่อไว้)
	if player and player_spawn:
		player.global_position = player_spawn.global_position
	
	# 2. บันทึกค่าวันที่ "ล่าสุด" ที่ TimeNode ถืออยู่ลงใน PlayerData
	# (ปกติ TimeManager จะบวกวันเพิ่มให้แล้วเมื่อจบ Countdown)
	PlayerData.current_day = time_node.day
	print("💾 Saving Day %d to PlayerData before reload" % PlayerData.current_day)
	
	# 3. รีเซ็ตสถานะตัวนับเวลา (ให้กลับไปเต็มหลอดเหมือนเดิม)
	time_node.reset_countdown()
	
	# 4. โหลดฉากใหม่
	get_tree().reload_current_scene()

func _play_quest_success_sound(quest_id: String, reward_money: int):
	if success_sfx:
		success_sfx.play()