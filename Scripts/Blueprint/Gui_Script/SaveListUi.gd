extends Control

@export var slot_button_scene: PackedScene
@onready var slot_list: VBoxContainer = $VBoxContainer


func _ready() -> void:
	# ตรวจว่าตั้งค่า scene หรือยัง
	if slot_button_scene == null:
		push_error("❌ slot_button_scene is NULL (assign SlotButton.tscn in Inspector)")
		return

	if slot_list == null:
		push_error("❌ VBoxContainer not found")
		return

	refresh_slot_list()

func refresh_slot_list() -> void:
	if slot_list == null: return

	# ลบปุ่มเก่าออกให้หมดก่อน
	for c in slot_list.get_children():
		c.queue_free()

	# ดึงรายการ ID ทั้งหมดที่มีไฟล์เซฟจริง
	var slots: Array[int] = SaveAndLoad.get_all_slots()

	# แสดงผลเซฟที่มีอยู่
	for id in slots:
		var preview: Dictionary = SaveAndLoad.load_game(id)
		var btn = slot_button_scene.instantiate()
		
		slot_list.add_child(btn) # Add child ก่อนเรียก setup เพื่อให้ @onready ทำงาน
		
		if btn.has_method("setup"):
			btn.setup(id, preview)

		# เมื่อกดปุ่มนี้
		btn.pressed.connect(func():
			PlayerData.GlobalSaveSlot = id # บันทึกไว้ว่ากำลังใช้ Slot ไหน
			get_tree().change_scene_to_file("res://Scence/Main_Game.tscn")
		)
