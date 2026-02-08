extends ItemList
var icon :Dictionary= {
	'Cpu': [preload("res://Pic/PCbuill/HardWare/CpU.png")],

	'Gpu': [preload("res://Pic/PCbuill/HardWare/gra1.png"),
			preload("res://Pic/PCbuill/HardWare/gra2.png"),
			preload("res://Pic/PCbuill/HardWare/gra3.png")],

	'MainBoard': [preload("res://Pic/PCbuill/HardWare/Mainboard.png"),
				  preload("res://Pic/PCbuill/HardWare/Mainboard2.png"),
				  preload("res://Pic/PCbuill/HardWare/Mainboard3.png")],

	'Case': [preload("res://Pic/PCbuill/HardWare/PCopen.png")],

	'Ram': [preload("res://Pic/PCbuill/HardWare/1RAM.png"),
			preload("res://Pic/PCbuill/HardWare/2RAM.png")],

	'Fan': [preload("res://Pic/PCbuill/HardWare/harddisk.png")],

	'PowerSupply': [preload("res://Pic/PCbuill/HardWare/powersupply.png")],

	'None': [preload("res://Assets/Gui/Ingame/Nooo.png")]
}


func _ready():
	InventorySystem.inventory_changed.connect(update_inventory)
	update_inventory()


func update_inventory():
	clear()  # ล้างรายการเก่า
# 🔥 กำหนดขนาดภาพที่นี่ (เช่น 64x64 หรือ 128x128)
	self.fixed_icon_size = Vector2i(64, 64) 
    # หรือจะปรับโหมดการขยายภาพให้สวยขึ้น
	self.icon_mode = ItemList.ICON_MODE_TOP
	self.icon_scale = 0.6 # ปรับสเกลภาพรวม
	for item_id in InventorySystem.Inventory.keys():
		var amount = int(InventorySystem.Inventory[item_id])
		var data = get_item_data(item_id)
		var color : Color = data[0]
		var category : String = data[1]
		
		var icon_list = icon[category]
		var selected_icon = icon_list.pick_random()
		
		# 1. สร้างข้อความที่จะแสดงใน List
		var display_text = item_id + " : " + str(amount)
		var index = add_item(display_text, selected_icon)
		
		# 2. ดึงข้อมูลจาก HardwareSpecs มาทำ Tooltip
		var specs = HardwareSpecs.get_specs(item_id)
		if not specs.is_empty():
			var desc = specs.get("description", "ไม่มีคำอธิบาย")
			var price = specs.get("price", 0)
			var rarity = specs.get("rarity", "common").to_upper()
			
			# สร้างข้อความ Tooltip (รองรับ BBCode สำหรับสีและตัวหนา)
			var tooltip_text = "%s (%s)\n" % [specs.get("name", item_id), rarity]
			tooltip_text += "--------------------------\n"
			tooltip_text += "%s\n" % desc
			tooltip_text += "--------------------------\n"
			tooltip_text += "%d Point" % price
			
			# ตั้งค่า Tooltip ให้กับ Item ตัวนี้
			set_item_tooltip(index, tooltip_text)
		
		# กำหนดสีตัวอักษร
		set_item_custom_fg_color(index, color)


func get_item_data(item: String) -> Array:
	match item:

		# CPU - สีน้ำเงิน
		"CPU_Intel_i5", "CPU_Intel_i7", "CPU_Intel_i9":
			return [Color(0.29, 0.56, 0.89), 'Cpu']  # สีน้ำเงิน
		# GPU - สีเขียว
		"GPU_RTX_3060", "GPU_RTX_3080", "GPU_RTX_4090":
			return [Color(0.18, 0.8, 0.44), 'Gpu']  # สีเขียว
		# MainBoard - สีส้ม
		"MainBoard_B550", "MainBoard_X570", "MainBoard_TRX50":
			return [Color(0.9, 0.49, 0.13), 'MainBoard']  # สีส้ม
		# Case - สีเทา
		"Case_Standard", "Case_Premium", "Case_Titan":
			return [Color(0.58, 0.65, 0.65), 'Case']  # สีเทา
		# RAM - สีชมพู
		"RAM_8GB", "RAM_16GB", "RAM_32GB":
			return [Color(0.91, 0.12, 0.39), 'Ram']  # สีชมพู
		# Fan - สีแดง
		"Fan_Standard", "Fan_Premium", "Fan_Gaming":
			return [Color(0.91, 0.3, 0.24), 'Fan']  # สีแดง
		# PowerSupply - สีม่วง
		"PowerSupply_550W", "PowerSupply_850W", "PowerSupply_1600W":
			return [Color(0.61, 0.35, 0.71), 'PowerSupply']  # สีม่วง
		_:
			return [Color.WHITE, "None"]  # ค่า default ที่ปลอดภัย

func _get_drag_data(at_position: Vector2):
	var index = get_item_at_position(at_position)
	if index == -1: return null
	
	var item_full_text = get_item_text(index) # "CPU_Intel_i5 : 1"
	var item_name = item_full_text.split(" : ")[0] # ดึงแค่ "CPU_Intel_i5"
	
	# สร้างหน้าตาไอคอนตอนที่กำลังลาก (Drag Preview)
	var preview = TextureRect.new()
	preview.texture = get_item_icon(index)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(64, 64)
	set_drag_preview(preview)
	
	# ส่งข้อมูล Dictionary ของไอเทมที่ลาก
	return { "item_name": item_name, "category": _get_item_category(item_name) }

func _get_item_category(item_name: String) -> String:
	# ใช้ HardwareSpecs หรือ Match เพื่อหา Category
	if "CPU" in item_name: return "CPU"
	if "GPU" in item_name: return "GPU"
	if "RAM" in item_name: return "Ram"
	if "MainBoard" in item_name: return "MainBoard"
	if "Case" in item_name: return "Case"
	if "Fan" in item_name: return "Fan"
	if "PowerSupply" in item_name: return "PowerSupply"
	return "None"