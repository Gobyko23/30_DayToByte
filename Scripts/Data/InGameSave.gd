extends Node3D

@onready var player: Node3D = $Player
@onready var player_spawn: Marker3D = $PlayerSpawn
@onready var end_gui: CanvasLayer = %EndLayer  # เชื่อมต่อกับ endGui ด้วย unique name
@onready var time_node: Node = %TimeNode
func _ready():
	SaveAndLoad.request_load.connect(_on_request_load)
	SaveAndLoad.request_save.connect(_on_request_save)
	
	# เชื่อมต่อกับสัญญาณ countdown_finished จาก TimeNode
	time_node.countdown_finished.connect(_on_countdown_finished)
	
	# ตรวจสอบว่าฉากปัจจุบันคือ Tutorial Scene หรือไม่
	var current_scene_path = get_tree().current_scene.scene_file_path
	if current_scene_path == "res://Scence/Stage/TutorialScene.tscn":
		print("🎓 Tutorial Scene detected - skipping load and resetting points to 0")
		PointSystem.set_points(0)
		return
	
	# Restore day value จาก PlayerData ถ้ามีการบันทึกไว้
	if "current_day" in PlayerData and PlayerData.current_day > 0:
		var saved_day = PlayerData.current_day
		time_node.day = saved_day
		print("📅 Restored day value from PlayerData: %d" % saved_day)
		# ไม่ลบค่า เพราะถ้าโหลดเกมใหม่ต้องใช้มันอีก
		return  # ไม่ต้อง load save file เมื่อ reload scene
	
	# โหลดเกมตอนเริ่มต้น ถ้า GlobalSaveSlot ถูกตั้งค่า
	var slot_id = PlayerData.GlobalSaveSlot
	if slot_id != -1:
		print("📂 Loading save slot: ", slot_id)
		SaveAndLoad.request_load.emit(slot_id)
	else:
		print("⚠️ No save slot specified")


func _on_countdown_finished() -> void:
	"""เรียกเมื่อเวลานับถ่อยหลังเสร็จ"""
	print("🏁 Countdown finished! Processing day completion...")
	
	# 1. ย้ายผู้เล่นไปที่ PlayerSpawn
	if player and player_spawn:
		player.global_position = player_spawn.global_position
		print("📍 Player moved to spawn point: ", player.global_position)
	
	# 2. ตรวจสอบว่าครบ 3 วันหรือไม่
	if time_node.day > time_node.max_days:
		print("🎉 Day 3 completed! Showing end GUI...")
		time_node.stop_countdown()
		_show_end_gui()
	else:
		# 3. Save day value ก่อน reload scene (TimeManager ได้เพิ่มแล้ว)
		PlayerData.current_day = time_node.day
		print("💾 Saved day value to PlayerData: %d" % time_node.day)
		
		# 4. Reset countdown state ของ TimeNode ก่อน reload scene
		print("🔄 Resetting countdown for next day...")
		time_node.reset_countdown()
		
		# 5. Reload scene ถ้ายังไม่ครบวันสูงสุด
		print("🔄 Reloading scene... (Day: %d/%d)" % [time_node.day, time_node.max_days])
		await get_tree().process_frame
		get_tree().reload_current_scene()


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


func _on_request_save(slot: int) -> void:
	print("💾 Saving to slot: ", slot)
	# ส่ง time_node ไปให้ SaveAndLoadscript เพื่อจัดการเวลา
	SaveAndLoad.save_game(slot, player, time_node)


func _on_request_load(slot: int) -> void:
	print("📥 Loading from slot: ", slot)
	# ส่ง time_node ไปให้ SaveAndLoadscript เพื่อคืนค่าข้อมูลเวลา
	SaveAndLoad._on_request_load(slot, time_node)
