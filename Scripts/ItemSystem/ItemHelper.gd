extends Node

# ฟังก์ชัน Helper สำหรับระบบไอเทมและสเปค

# ดึงชื่อไอเทมแบบ Friendly
func get_item_display_name(item_code: String) -> String:
	var specs = HardwareSpecs.get_specs(item_code)
	if not specs.is_empty() and specs.has("name"):
		return specs["name"]
	return item_code

# ดึงคำอธิบายไอเทม
func get_item_description(item_code: String) -> String:
	var specs = HardwareSpecs.get_specs(item_code)
	if not specs.is_empty() and specs.has("description"):
		return specs["description"]
	return ""

# ดึงราคาไอเทม
func get_item_price(item_code: String) -> int:
	var specs = HardwareSpecs.get_specs(item_code)
	if not specs.is_empty() and specs.has("price"):
		return specs["price"]
	return 0

# ดึงหมวดหมู่ไอเทม
func get_item_category(item_code: String) -> String:
	var specs = HardwareSpecs.get_specs(item_code)
	if not specs.is_empty() and specs.has("category"):
		return specs["category"]
	return "Unknown"

# ดึงระดับความหายากของไอเทม
func get_item_rarity(item_code: String) -> String:
	var specs = HardwareSpecs.get_specs(item_code)
	if not specs.is_empty() and specs.has("rarity"):
		return specs["rarity"]
	return "common"

# ดึงสเปคทั้งหมด
func get_item_specs_list(item_code: String) -> Array:
	var specs = HardwareSpecs.get_specs(item_code)
	if not specs.is_empty() and specs.has("specs"):
		return specs["specs"]
	return []

# นับไอเทมตามหมวดหมู่
func count_items_by_category(category: String) -> int:
	var count = 0
	for item in InventorySystem.Inventory.keys():
		if get_item_category(item) == category:
			count += InventorySystem.Inventory[item]
	return count

# ดึงรายชื่อหมวดหมู่ทั้งหมด
func get_all_categories() -> Array:
	var categories = []
	var all_specs = HardwareSpecs.get_all_specs()
	for item_code in all_specs.keys():
		var category = all_specs[item_code]["category"]
		if not category in categories:
			categories.append(category)
	return categories

# สร้างสตริง tooltip สำหรับ UI
func create_tooltip(item_code: String) -> String:
	var specs = HardwareSpecs.get_specs(item_code)
	if specs.is_empty():
		return ""
	
	var tooltip = "[color=#ffff00]" + specs["name"] + "[/color]\n"
	tooltip += "[color=#888888]" + specs["category"] + "[/color]\n"
	tooltip += "━━━━━━━━━━━━\n"
	
	for spec in specs["specs"]:
		tooltip += "[color=#aaffff]• " + spec + "[/color]\n"
	
	tooltip += "━━━━━━━━━━━━\n"
	tooltip += "[color=#00ff00]฿" + str(specs["price"]) + "[/color]\n"
	tooltip += "[color=#ffaa00]" + specs["description"] + "[/color]"
	
	return tooltip
