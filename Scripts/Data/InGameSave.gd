extends Node3D

@onready var player: Node3D = $Player

func _ready():
	SaveAndLoad.request_load.connect(_on_request_load)
	SaveAndLoad.request_save.connect(_on_request_save)
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
