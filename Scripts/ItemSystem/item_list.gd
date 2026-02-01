extends ItemList
var icon :Array = [preload("res://Assets/Gui/Tote.jpg"),
				   preload("res://Assets/Gui/CEO.jpg"),
				   preload("res://Assets/Models/Teto.png"),
				   preload("res://Assets/Gui/donoo.jpg"),
				   preload("res://Assets/Gui/ish.webp")
					]


func _ready():
	InventorySystem.inventory_changed.connect(update_inventory)
	update_inventory()


func update_inventory():
	clear()  # ล้างรายการเก่า
	
	for item in InventorySystem.Inventory.keys():
		var amount = int(InventorySystem.Inventory[item])  # แปลงเป็น int
		var data = get_item_data(item)
		var color :Color= data[0] 
		var icon_change = icon
		
		# เพิ่มแถวใหม่ใน ItemList
		var index = add_item(item + " : " + str(amount), icon_change[data[1]])
		

		# กำหนดสีสำหรับแต่ละแถว
		set_item_custom_fg_color(index, color)


func get_item_data(item: String) -> Array:
	match item:

		# CPU - สีน้ำเงิน
		"CPU_Intel_i5", "CPU_Intel_i7", "CPU_Intel_i9":
			return [Color(0.29, 0.56, 0.89), 0]  # สีน้ำเงิน
		# GPU - สีเขียว
		"GPU_RTX_3060", "GPU_RTX_3080", "GPU_RTX_4090":
			return [Color(0.18, 0.8, 0.44), 1]  # สีเขียว
		# MainBoard - สีส้ม
		"MainBoard_B550", "MainBoard_X570", "MainBoard_TRX50":
			return [Color(0.9, 0.49, 0.13), 2]  # สีส้ม
		# Case - สีเทา
		"Case_Standard", "Case_Premium", "Case_Titan":
			return [Color(0.58, 0.65, 0.65), 3]  # สีเทา
		# RAM - สีชมพู
		"RAM_8GB", "RAM_16GB", "RAM_32GB":
			return [Color(0.91, 0.12, 0.39), 4]  # สีชมพู
		# Fan - สีแดง
		"Fan_Standard", "Fan_Premium", "Fan_Gaming":
			return [Color(0.91, 0.3, 0.24), 0]  # สีแดง
		# PowerSupply - สีม่วง
		"PowerSupply_550W", "PowerSupply_850W", "PowerSupply_1600W":
			return [Color(0.61, 0.35, 0.71), 1]  # สีม่วง
		_:
			return [Color.WHITE, 0]  # ค่า default ที่ปลอดภัย
