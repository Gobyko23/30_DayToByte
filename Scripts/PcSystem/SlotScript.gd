extends TextureRect

# ระบุว่าช่องนี้รับไอเทมประเภทไหน (ตั้งค่าได้จากหน้า Inspector)
@export var accepted_category: String = "CPU" 

func _can_drop_data(_at_position, data):
	# ตรวจสอบว่าของที่ลากมา มี category ตรงกับที่ช่องนี้รับหรือไม่
	return data is Dictionary and data.has("category") and data["category"] == accepted_category

func _drop_data(_at_position, data):
	# เมื่อวางสำเร็จ ให้เรียก Manager หลักของมินิเกมเพื่อทำการติดตั้ง
	# แนะนำให้ใช้ get_parent() หรือเจ้าของ Scene ในการรับข้อมูล
	var manager = get_tree().get_first_node_in_group("PCBuilderManager")
	if manager:
		manager.install_part(accepted_category, data["item_id"])
		
		# เปลี่ยนรูป Icon ในช่องให้เป็นรูปไอเทมที่ใส่ (ถ้ามี)
		# texture = data["icon_texture"]