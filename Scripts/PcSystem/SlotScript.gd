extends TextureRect

# ระบุว่าช่องนี้รับไอเทมประเภทไหน (ตั้งค่าได้จากหน้า Inspector)
@export var accepted_category: String = "CPU" 
@onready var checking_label: RichTextLabel = %CheckingLabel
@onready var drop_sfx: AudioStreamPlayer = %DropSFX

func _ready():
	# 1. ซ่อนตัวเองไว้ตอนเริ่ม (หรือตั้งค่า modulate.a = 0 ถ้าอยากให้จางๆ)
	self.visible = false 
	checking_label.visible = false
	# 2. ลงทะเบียนเข้ากลุ่มตามประเภท เพื่อให้ ItemList เรียกใช้ได้ง่าย
	add_to_group("slot_" + accepted_category.to_upper())

func show_highlight(is_show: bool):
	self.visible = is_show

# ใน SlotScript.gd
# ใน SlotScript.gd
# ใน SlotScript.gd

func reset_slot():
	# 1. ล้างรูปภาพออกให้หมด
	self.texture = load("res://Assets/Gui/Ingame/maxresdefault.jpg") # รูปช่องว่างมาตรฐาน
	
	# 2. รีเซ็ตสีกลับเป็นสีขาวปกติ (ไม่เอาสีฟ้าจางๆ แล้ว เพราะมันอาจจะทำให้ดูเหมือนยังมีเงาอยู่)
	self.modulate = Color(0.5, 1, 1, 1)
	
	# 3. ซ่อนตัวเองกลับไป (เพราะ Node นี้ทำหน้าที่เป็น Overlay รูปไอเทม)
	self.visible = false 
	
	# 4. ปิด Label แจ้งเตือน (ถ้ามีค้างอยู่)
	if checking_label:
		checking_label.visible = false
		
	print("🧹 Slot reset complete for: ", self.name)

func _can_drop_data(_at_position, data):
	# ตรวจสอบว่าของที่ลากมา มี category ตรงกับที่ช่องนี้รับหรือไม่
	return data is Dictionary and data.has("category") and data["category"] == accepted_category

# ใน SlotScript.gd
func _drop_data(_at_position, data):
	if data is Dictionary and data.has("item_id"):
		var manager = get_tree().get_first_node_in_group("PCBuilderManager")
		
		# 1. เช็คความเข้ากันได้ผ่าน Manager ก่อน (เช่น Socket ตรงไหม)
		# เราควรเช็คผลลัพธ์จาก manager.check_compatibility ก่อนจะเปลี่ยนรูป
		if manager:
			var check_result = manager.check_compatibility(accepted_category, data["item_id"])
			
			if check_result == "OK":
				# 2. ถ้าผ่าน ให้ติดตั้งชิ้นส่วน
				manager.install_part(accepted_category, data["item_id"])
				drop_sfx.stream = load("res://Assets/SFX/pickupSFX_1.wav") # เปลี่ยนเป็นเสียงที่เหมาะสมกับการติดตั้ง
				drop_sfx.play()
				self.modulate = Color(1, 1, 1) # เปลี่ยนสีกลับเป็นปกติ (ถ้าเคยเปลี่ยนตอนเช็คไม่ผ่าน)
				checking_label.visible = false
				self.visible = true # แสดงช่องที่ติดตั้งได้
				
				# 3. ✅ เปลี่ยนรูปในช่อง Slot ให้ตรงกับของที่ลากมา
				if data.has("icon_texture"):
					self.texture = data["icon_texture"]
					# ปรับขนาดภาพให้เต็มช่อง (Option)
					self.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
					self.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			else:
				drop_sfx.stream = load("res://Assets/SFX/OpenBox/OpeningBox3.wav")
				drop_sfx.play()
				print("ติดตั้งไม่ได้: ", check_result)
				checking_label.text = "[color=red]" + check_result + "[/color]"
				checking_label.visible = true
				self.visible = false # ซ่อนช่องที่ไม่สามารถติดตั้งได้
				await get_tree().create_timer(2.0).timeout
				checking_label.visible = false
	
