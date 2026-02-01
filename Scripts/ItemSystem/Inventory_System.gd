extends Node2D

var Inventory: Dictionary = {}
signal inventory_changed
# ฟังก์ชันอัปเดต Inventory
func update_item(item: String, amount: int):
	if Inventory.has(item):
		Inventory[item] += amount
	else:
		Inventory[item] = amount
	
	if Inventory[item] <= 0:
		Inventory.erase(item)
	emit_signal("inventory_changed")



# ----------------------------
#  ฟังก์ชันสุ่มแบบ Weighted
# ----------------------------
func random_obj() -> String:
	var table = {
		# ไอเทมฮาร์ดแวร์คอมพิวเตอร์
		"CPU_Intel_i5" = 8,
		"CPU_Intel_i7" = 5,
		"CPU_Intel_i9" = 2,
		"GPU_RTX_3060" = 8,
		"GPU_RTX_3080" = 5,
		"GPU_RTX_4090" = 2,
		"MainBoard_B550" = 8,
		"MainBoard_X570" = 5,
		"MainBoard_TRX50" = 2,
		"Case_Standard" = 9,
		"Case_Premium" = 5,
		"Case_Titan" = 2,
		"RAM_8GB" = 7,
		"RAM_16GB" = 5,
		"RAM_32GB" = 2,
		"Fan_Standard" = 8,
		"Fan_Premium" = 5,
		"Fan_Gaming" = 2
	}

	var total_weight := 0
	for w in table.values():
		total_weight += w

	var rnd := randi() % total_weight
	var cumulative := 0

	for key in table.keys():
		cumulative += table[key]
		if rnd < cumulative:
			return key  # return string
	
	return ""  # กัน error (แต่จริง ๆ ไม่เคยถึง)
