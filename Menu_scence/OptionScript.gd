extends HSlider

@export var bus_name: String = "" # พิมพ์ชื่อ Bus ให้ตรงกับในแถบ Audio
var bus_index: int
@onready var Hslide_SFX :AudioStreamPlayer= %DragSFX

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	
	# 1. ดึงค่าเสียงปัจจุบันจาก AudioServer (เป็นค่า dB)
	var current_db = AudioServer.get_bus_volume_db(bus_index)
	
	# 2. แปลงค่าจาก dB เป็นสเกล 0-1 (Linear) 
	# แล้วคูณ 100 เพื่อให้ตรงกับ Max Value (100) ของ Slider คุณ
	var slider_value = db_to_linear(current_db) * 100
	
	# 3. สั่งให้ Slider ขยับไปที่ค่านั้น
	value = slider_value
	
	# เชื่อมต่อสัญญาณเมื่อมีการเลื่อนหลอด
	value_changed.connect(_on_value_changed)

func _on_value_changed(new_value: float) -> void:
# เมื่อเลื่อน ต้องหาร 100 กลับคืน เพื่อให้ได้ค่า 0-1 ก่อนแปลงเป็น dB
	var volume_db = linear_to_db(new_value / 100.0)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	
	# ปิดเสียงสนิทถ้าเลื่อนจนสุด
	AudioServer.set_bus_mute(bus_index, new_value < 1.0)
	
	
	# เล่นเสียงตัวอย่างสั้นๆ เฉพาะตอนที่ไม่ได้ลากค้างไว้แรงๆ (ป้องกันเสียงซ้อน)
	if not Hslide_SFX.playing:
		Hslide_SFX.play()
