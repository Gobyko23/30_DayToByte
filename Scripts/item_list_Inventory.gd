extends RichTextLabel

func _process(delta: float) -> void:
	var statement := ""

	for item in InventorySystem.Inventory.keys():
		var amount = InventorySystem.Inventory[item]
		var color = get_color_by_item(item)

		# ใช้ BBCode ใส่สี
		statement += "[color=" + color + "]" + item + "[/color]"
		statement += " : " + str(amount) + "\n"
	
	self.text = statement



func get_color_by_item(item: String) -> String:
	match item:
		"White":
			return "white"
		"Red":
			return "red"
		"Yellow":
			return "yellow"
		"Green":
			return "green"
		"RainBow":
			return "#ff00ff"   # ม่วง
		_:
			return "white"
