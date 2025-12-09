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
		"White" = 3,
		"Red" = 4,
		"Yellow" = 5,
		"Green" = 2,
		"RainBow" = 1
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
