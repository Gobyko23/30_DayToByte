extends RichTextLabel

func _process(_delta: float) -> void:
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
		# CPU สีน้ำเงิน
		"CPU_Intel_i5", "CPU_Intel_i7", "CPU_Intel_i9":
			return "#4a90e2"
		# GPU สีเขียว
		"GPU_RTX_3060", "GPU_RTX_3080", "GPU_RTX_4090":
			return "#2ecc71"
		# MainBoard สีส้ม
		"MainBoard_B550", "MainBoard_X570", "MainBoard_TRX50":
			return "#e67e22"
		# Case สีเทา
		"Case_Standard", "Case_Premium", "Case_Titan":
			return "#95a5a6"
		# RAM สีชมพู
		"RAM_8GB", "RAM_16GB", "RAM_32GB":
			return "#e91e63"
		# Fan สีแดง
		"Fan_Standard", "Fan_Premium", "Fan_Gaming":
			return "#e74c3c"
		_:
			return "white"
