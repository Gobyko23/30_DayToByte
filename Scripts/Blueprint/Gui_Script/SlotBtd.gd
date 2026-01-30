# ListBtd.gd
extends Button

# ลาก Label จากในช่อง Scene มาใส่ในตัวแปรนี้ (หรือพิมพ์ชื่อให้ตรง)
@onready var info_label: Label = $Label 


# ใน ListBtd.gd
func setup(id: int, data: Dictionary) -> void:
	# ใช้ find_child เพื่อหา Label ไม่ว่าจะวางไว้ตรงไหนในปุ่ม
	var label_node = find_child("Label", true, false) as Label
	
	if label_node == null:
		print("❌ หา Node ชื่อ Label ไม่เจอในปุ่ม Slot ", id)
		return

	if data.is_empty():
		label_node.text = "Slot %d | Empty" % id
	else:
		# ดึงข้อมูลมาแสดง (ต้องมั่นใจว่าใน SaveManager บันทึกชื่อ 'player' และ 'money' ไว้)
		var p_points = data.get("player", {}).get("points", 0)
		var p_name = data.get("player", {}).get("name", "Player")
		
		label_node.text = "Slot %d | %s | %d P" % [id, p_name, p_points]
		print("✅ อัปเดตปุ่ม Slot ", id, " เรียบร้อย: ", label_node.text)
