extends Node

@onready var points_label : Label = $"."

func _ready():
	# 1. เชื่อมต่อ Signal เพื่อรอรับการอัปเดตระหว่างเล่น
	if PointSystem != null:
		PointSystem.points_changed.connect(_update_points)
		# 2. อัปเดตตัวเลขทันทีที่เริ่มเกม (ดึงค่าปัจจุบันจาก PointSystem มาโชว์เลย)
		_update_points(PointSystem.points)

func _update_points(amount: int):
	points_label.text = "%d Point" % amount
