extends Control

@export var slot_id: int = 1



func _on_save_button_pressed() -> void: #Save
	SaveAndLoad.request_save.emit(PlayerData.GlobalSaveSlot)
	print("Sent save request...")
	
# ในสคริปต์หน้าเมนู/ปุ่มโหลด
func _on_load_button_pressed() -> void:
    # 1. ดึงชื่อฉากจากไฟล์เซฟก่อน (เพื่อจะได้รู้ว่าต้องโหลดไปฉากไหน)
	var saved_data = SaveAndLoad.load_game(PlayerData.GlobalSaveSlot)
	if saved_data.is_empty():
		print("No save found!")
		return
	get_tree().paused = false  # ป้องกันปัญหาจากการโหลดขณะเกมหยุดชั่วคราว
	var target_scene = saved_data.get("scene", "res://Scence/Stage/MainGame_OutSide.tscn")
    
    # 2. สั่งเปลี่ยนฉาก
	SceneLoader.load_scene(target_scene)
    
    # 3. รอสัญญาณจาก SceneLoader ว่าฉากใหม่พร้อมแล้ว ค่อยสั่งใส่ข้อมูล (Restore Data)
	if not SceneLoader.scene_loaded_successfully.is_connected(_on_target_scene_ready):
		SceneLoader.scene_loaded_successfully.connect(_on_target_scene_ready, CONNECT_ONE_SHOT)

func _on_target_scene_ready():
    # สั่ง Load ข้อมูลลงในโหนดของฉากใหม่
	SaveAndLoad.request_load.emit(PlayerData.GlobalSaveSlot)
	print("Scene Ready: Data restored into new scene nodes.")

