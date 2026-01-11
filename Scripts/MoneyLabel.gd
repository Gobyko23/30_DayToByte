extends Node

@onready var money_label : Label = $"."

func _ready():
	# 1. เชื่อมต่อ Signal เพื่อรอรับการอัปเดตระหว่างเล่น
	CashSystem.money_changed.connect(_update_money)
	
	# 2. อัปเดตตัวเลขทันทีที่เริ่มเกม (ดึงค่าปัจจุบันจาก CashSystem มาโชว์เลย)
	_update_money(CashSystem.money)

func _update_money(amount:int):
	money_label.text = "%d $" % amount
