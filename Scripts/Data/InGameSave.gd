extends Node3D

@onready var player: Node3D = $Player

func _ready():
	SaveAndLoad.request_load.connect(_on_request_load)
	SaveAndLoad.request_save.connect(_on_request_save)
	
	var slot_id = PlayerData.GlobalSaveSlot
	if slot_id != -1:
		var data = SaveAndLoad.load_game(slot_id)
		
		if not data.is_empty():
			# 1. โหลดตำแหน่ง (ที่คุณทำได้แล้ว)
			var pos = data["player"]["position"]
			player.global_position = Vector3(pos.x, pos.y, pos.z)
			
			# 2. โหลดเงิน (จุดที่หายไป!)
			if data["player"].has("money"):
				var saved_money = data["player"]["money"]
				# ใช้ฟังก์ชัน set_money ที่คุณเขียนไว้ เพื่อให้ Signal ทำงาน
				CashSystem.set_money(int(saved_money)) 
				print("💰 Loaded Money: ", saved_money)
	var save: Dictionary = SaveAndLoad.load_game(PlayerData.GlobalSaveSlot)
	if save.is_empty():
		return

	apply_save(save)




func apply_save(save: Dictionary) -> void:
	PlayerData.money = save["player"]["money"]

	player.global_position = Vector3(
		save["player"]["position"]["x"],
		save["player"]["position"]["y"],
		save["player"]["position"]["z"]
	)

func _on_request_save(slot: int):
	SaveAndLoad.save_game(slot, $Player)
	
func _on_request_load(slot: int) -> void:
	var data := SaveAndLoad.load_game(slot)
	if data.is_empty():
		print("❌ No save in slot", slot)
		return

	apply_save(data)
