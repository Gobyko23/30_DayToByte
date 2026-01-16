extends Control

@export var slot_button_scene: PackedScene
@onready var slot_list: VBoxContainer = %VBox


# ใน SaveListUi.gd
func _ready():
	# ทันทีที่หน้าจอนี้ปรากฏขึ้น ให้วาดปุ่มใหม่พร้อมข้อมูลล่าสุดจากไฟล์
	SaveAndLoad.save_finished.connect(refresh_slot_list)
	refresh_slot_list()

func refresh_slot_list() -> void:
	print("🔄 กำลังรีเฟรชรายการ Slot...") 
	if slot_list == null: return
	
	# ลบปุ่มเก่าออกแบบเด็ดขาด
	for c in slot_list.get_children():
		slot_list.remove_child(c)
		c.queue_free()

	# วนลูปสร้างปุ่มใหม่ 1-3
	for id in range(1, 4):
		var preview = SaveAndLoad.load_game(id) # โหลดจากไฟล์ .json ล่าสุด
		var btn = slot_button_scene.instantiate()
		slot_list.add_child(btn)
		
		# ส่งข้อมูลเข้าปุ่ม (เช็คว่า preview มีข้อมูลไหม)
		if btn.has_method("setup"):
			btn.setup(id, preview)
		
		btn.pressed.connect(func():
			PlayerData.GlobalSaveSlot = id
			get_tree().change_scene_to_file("res://Scence/Main_Game.tscn")
		)
