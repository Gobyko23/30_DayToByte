extends Node

var loading_screen_scene = preload("res://Scence/LoadingScreen.tscn")
var loading_screen_instance: CanvasLayer = null
var target_path: String
var progress: Array = []
var is_loading: bool = false # เพิ่มตัวแปรเช็คสถานะ

func load_scene(path: String):
	target_path = path
	is_loading = true # เริ่มสถานะโหลด
	
	if is_instance_valid(loading_screen_instance):
		loading_screen_instance.queue_free()
	
	loading_screen_instance = loading_screen_scene.instantiate()
	get_tree().root.add_child(loading_screen_instance)
	
	# รีเซ็ตหลอดเป็น 0
	var pb = loading_screen_instance.find_child("ProgressBar")
	if pb: pb.value = 0
	
	ResourceLoader.load_threaded_request(target_path)
	set_process(true)

func _process(_delta):
	if not is_loading or not is_instance_valid(loading_screen_instance):
		return

	var status = ResourceLoader.load_threaded_get_status(target_path, progress)
	print("Loading status: ", status, " for path: ", target_path)
	var pb = loading_screen_instance.find_child("ProgressBar")
	
	if pb:
		var target_progress = progress[0] * 100
		# สร้าง Tween แบบชั่วคราวเพื่อเลื่อนค่าให้สมูท
		var tween = create_tween()
		tween.tween_property(pb, "value", target_progress, 0.5)
	
	# เมื่อโหลดเสร็จในหน่วยความจำ
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		is_loading = false # หยุดการอัปเดตใน _process
		_finish_loading_sequence()
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		print("ERROR: Failed to load scene: ", target_path)
		is_loading = false
		if is_instance_valid(loading_screen_instance):
			loading_screen_instance.queue_free()
			loading_screen_instance = null

func _finish_loading_sequence():
	var pb = loading_screen_instance.find_child("ProgressBar")
	
	# --- จุดสำคัญ: สั่งให้หลอดวิ่งไปที่ 100% และ "รอ" จนกว่าจะเต็มจริง ---
	if pb:
		var final_tween = create_tween()
		# วิ่งไป 100 ในเวลา 0.3 วินาที (ปรับความเร็วได้ที่นี่)
		final_tween.tween_property(pb, "value", 100.0, 0.5)
		# ใช้ await รอจนกว่า Tween นี้จะทำงานเสร็จ
		await final_tween.finished
	
	# เปลี่ยนฉากจริง
	_complete_transition()

signal scene_loaded_successfully # เพิ่ม Signal ใหม่

func _complete_transition():
	set_process(false)
	var new_scene = ResourceLoader.load_threaded_get(target_path)
	if new_scene:
		get_tree().change_scene_to_packed(new_scene)
        
        # --- จุดสำคัญ ---
        # รอ 1 Frame เพื่อให้โหนดในฉากใหม่ถูกสร้าง (Ready) จนครบ
		await get_tree().process_frame 
		scene_loaded_successfully.emit() # บอกว่าฉากใหม่พร้อมรับข้อมูลแล้ว
    
	if is_instance_valid(loading_screen_instance):
		loading_screen_instance.queue_free()
		loading_screen_instance = null