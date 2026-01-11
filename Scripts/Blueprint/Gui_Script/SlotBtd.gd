# SlotButton.gd
extends Button

# ลาก Label ที่อยู่ในปุ่มมาวางที่นี่
@onready var info_label: Label = $Label 

func setup(id: int, data: Dictionary) -> void:
	if data.is_empty():
		info_label.text = "Slot %d: Empty" % id
		return
	
	# ดึงค่าเงินและข้อมูลอื่นๆ จาก Dictionary (ตามโครงสร้างใน SaveManager)
	var money = data.get("player", {}).get("money", 0)
	var day = data.get("time", {}).get("day", 1)
	
	# แสดงผลบนปุ่ม
	info_label.text = "Slot %d | Day: %d | Money: %d $" % [id, day, money]
