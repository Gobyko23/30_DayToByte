extends Node

# โหลด Scene หน้าจอ Loading ที่เราเตรียมไว้
var loading_screen_scene = preload("res://Scence/LoadingScreen.tscn")
var loading_screen_instance: CanvasLayer
var target_path: String
var progress: Array = []

func load_scene(path: String):
	target_path = path
	
	# 1. สร้างหน้าจอ Loading ขึ้นมาแสดงผล
	loading_screen_instance = loading_screen_scene.instantiate()
	get_tree().root.add_child(loading_screen_instance)
	
	# 2. เริ่มต้นการโหลดใน Background
	ResourceLoader.load_threaded_request(target_path)
	
	# 3. เปิดการทำงานของ _process เพื่อเช็คความคืบหน้า
	set_process(true)

func _ready():
	# ปิด process ไว้ก่อนจนกว่าจะมีการเรียกใช้
	set_process(false)

func _process(_delta):
	var status = ResourceLoader.load_threaded_get_status(target_path, progress)
	
	# อัปเดต ProgressBar ใน Scene (สมมติว่าชื่อ ProgressBar)
	var pb = loading_screen_instance.find_child("ProgressBar")
	if pb:
		pb.value = progress[0] * 100
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false)
		_complete_loading()

func _complete_loading():
	var new_scene = ResourceLoader.load_threaded_get(target_path)
	
	# เปลี่ยน Scene
	get_tree().change_scene_to_packed(new_scene)
	
	# ลบหน้าจอ Loading ออก
	loading_screen_instance.queue_free()
