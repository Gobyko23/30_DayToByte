extends Node3D
func _ready():
	var save := SaveAndLoad.load_game(1)
	if save.is_empty():
		return

	# เวลา
	TimeManager.day = save["time"]["day"]
	TimeManager.hour = save["time"]["hour"]
	TimeManager.minute = save["time"]["minute"]

	# เงิน
	PlayerData.money = save["player"]["money"]

	# ตำแหน่งผู้เล่น
	$Player.global_position = Vector3(
		save["player"]["position"]["x"],
		save["player"]["position"]["y"],
		save["player"]["position"]["z"]
	)
