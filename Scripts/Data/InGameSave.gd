extends Node3D

@onready var player: Node3D = $Player

func _ready():
	SaveAndLoad.request_load.connect(_on_request_load)
	SaveAndLoad.request_save.connect(_on_request_save)
	
	# โหลดเกมตอนเริ่มต้น ถ้า GlobalSaveSlot ถูกตั้งค่า
	var slot_id = PlayerData.GlobalSaveSlot
	if slot_id != -1:
		print("📂 Loading save slot: ", slot_id)
		SaveAndLoad.request_load.emit(slot_id)
	else:
		print("⚠️ No save slot specified")


func _on_request_save(slot: int) -> void:
	print("💾 Saving to slot: ", slot)
	# SaveAndLoadscript.save_game() จะจัดการทุกอย่าง:
	# - Player position & money
	# - Items
	# - Quests
	# - NPCs state


func _on_request_load(slot: int) -> void:
	print("📥 Loading from slot: ", slot)
	# SaveAndLoadscript._on_request_load() จะจัดการทุกอย่าง:
	# - Player position & money
	# - Items restoration
	# - Quest data
	# - NPC state restoration (รวม pending_action)

