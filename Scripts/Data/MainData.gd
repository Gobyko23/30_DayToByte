extends Node3D
@onready var player :Node3D= $Player

func _ready():
	
	var save := SaveAndLoad.load_game(PlayerData.GlobalSaveSlot)
	if save.is_empty():
		return

	# เวลา
	TimeManager.day = save["time"]["day"]
	TimeManager.hour = save["time"]["hour"]
	TimeManager.minute = save["time"]["minute"]

	# คะแนน
	if save.has("player") and save["player"].has("points"):
		PointSystem.set_points(int(save["player"]["points"]))

	# ตำแหน่งผู้เล่น
	$Player.global_position = Vector3(
		save["player"]["position"]["x"],
		save["player"]["position"]["y"],
		save["player"]["position"]["z"]
	)
