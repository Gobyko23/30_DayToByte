extends ItemList
var icon :Array = [preload("res://Assets/Gui/Tote.jpg")]


func _ready():
	InventorySystem.inventory_changed.connect(update_inventory)
	update_inventory()


func update_inventory():
	clear()  # ล้างรายการเก่า
	
	for item in InventorySystem.Inventory.keys():
		var amount = InventorySystem.Inventory[item]
		var data = get_item_data(item)
		var color :Color= data[0] 
		var icon_change = data[1]
		
		# เพิ่มแถวใหม่ใน ItemList
		var index = add_item(item + " : " + str(amount),icon_change)
		

		# กำหนดสีสำหรับแต่ละแถว
		set_item_custom_fg_color(index, color)


func get_item_data(item: String) -> Array:
	match item:
		"White":
			return [Color.WHITE, 0]
		"Red":
			return [Color.RED, 1]
		"Yellow":
			return [Color(1,1,0), 2]
		"Green":
			return [Color(0,1,0), 3]
		"RainBow":
			return [Color(1,0,1), 4]
		_:
			return [Color.WHITE, -1]
