extends Control

@export var slot_id: int = 1
@export var max_slot :int= 3
func _ready():
	_refresh_label()

func _refresh_label():
	if SaveAndLoad.slot_exists(slot_id):
		var data := SaveAndLoad.load_game(slot_id)
		$Label.text = "Slot %d | %d $" % [
			slot_id,
			data["player"]["money"]
		]
	else:
		$Label.text = "Slot %d | Empty" % slot_id

func _on_save_button_pressed() -> void: #Save
	SaveAndLoad.request_save.emit(PlayerData.GlobalSaveSlot)
	
func _on_load_button_pressed() -> void: #Load
	SaveAndLoad.request_load.emit(PlayerData.GlobalSaveSlot)
