extends Node

# ค่าเวลามูลฐาน - สามารถปรับได้ใน Inspector
@export var countdown_duration_seconds: int = 300  # ค่าเริ่มต้น 5 นาที (300 วินาที)
@export var autostart_countdown: bool = true  # เริ่มนับถ่อยหลังโดยอัตโนมัติ
@export var max_days: int = 15  # วันสูงสุดก่อนจบเกม - ปรับได้ใน Inspector

var total_seconds := 300  # ค่าเริ่มต้น 5 นาที
var remaining_seconds := 300
var is_counting := false
var countdown_timer: Timer

signal time_changed(minutes: int, seconds: int)
signal countdown_finished

# สำหรับการจัดการวัน/ชั่วโมง/นาที
var day := 0
var hour := 0
var minute := 0
var second := 0

func _ready() -> void:
	# สร้าง Timer สำหรับนับถ่อยหลัง
	countdown_timer = Timer.new()
	add_child(countdown_timer)
	countdown_timer.timeout.connect(_on_timer_tick)
	countdown_timer.wait_time = 1.0  # อัปเดตทุก 1 วินาที
	
	# ใช้ค่าจาก @export ตอนเริ่มต้น
	total_seconds = countdown_duration_seconds
	remaining_seconds = countdown_duration_seconds
	is_counting = false
	
	print("⏰ TimeManager initialized - countdown_duration: %d seconds (%.1f minutes)" % [total_seconds, float(total_seconds) / 60.0])
	
	# ส่งสัญญาณให้ UI อัปเดตแสดงเวลาถูกต้อง
	time_changed.emit(remaining_seconds / 60, remaining_seconds % 60)
	
	# เริ่มนับถ่อยหลังโดยอัตโนมัติถ้ากำหนดไว้
	if autostart_countdown:
		start_countdown()

func start_countdown() -> void:
	"""เริ่มนับถ่อยหลัง (นับต่อจากเวลาที่เหลือ)"""
	"""บังคับให้เริ่มนับถอยหลังแน่นอน"""
	is_counting = true
	if countdown_timer:
		countdown_timer.start() # สั่ง Timer โดยตรง
    
    # อัปเดต UI ทันทีหนึ่งครั้ง
	time_changed.emit(remaining_seconds / 60, remaining_seconds % 60)
	print("⏱️ Timer started via start_countdown()")

func stop_countdown() -> void:
	"""หยุดนับถ่อยหลัง"""
	is_counting = false
	countdown_timer.stop()
	print("⏸️ Countdown stopped")

func reset_countdown() -> void:
	"""รีเซตเวลากลับไปค่าเริ่มต้น"""
	stop_countdown()
	remaining_seconds = total_seconds
	time_changed.emit(total_seconds / 60, total_seconds % 60)
	print("🔄 Countdown reset to %d seconds" % total_seconds)
	# เริ่มนับถอยหลังใหม่โดยอัตโนมัติ

func set_countdown_duration(seconds: int) -> void:
	"""ปรับเปลี่ยนระยะเวลานับถ่อยหลัง"""
	total_seconds = max(0, seconds)  # ต้องไม่น้อยกว่า 0
	remaining_seconds = total_seconds
	time_changed.emit(total_seconds / 60, total_seconds % 60)
	print("⚙️ Countdown duration set to %d seconds (%.1f minutes)" % [total_seconds, float(total_seconds) / 60.0])

func _on_timer_tick() -> void:
	"""ฟังก์ชันเรียกทุก 1 วินาที"""
	if is_counting:
		# ตรวจสอบก่อนว่าเวลาหมดแล้วหรือไม่
		if remaining_seconds <= 0:
			is_counting = false
			countdown_timer.stop()
			
			# เพิ่ม Day += 1 เมื่อนับเวลาเสร็จ
			day += 1
			print("📅 Day increased to: %d/%d" % [day, max_days])
			
			countdown_finished.emit()
			print("⏱️ Countdown finished! (Day: %d/%d)" % [day, max_days])
			return
		
		# นับถ่อยหลัง
		remaining_seconds -= 1
		var mins = remaining_seconds / 60
		var secs = remaining_seconds % 60
		time_changed.emit(mins, secs)

func get_time_string() -> String:
	"""ส่งกลับสตริงเวลาในรูปแบบ MM:SS"""
	var mins = remaining_seconds / 60
	var secs = remaining_seconds % 60
	return "%02d:%02d" % [mins, secs]

func export_time_data() -> Dictionary:
	"""ส่งออกข้อมูลเวลาสำหรับการบันทึก"""
	return {
		"day": day,
		"hour": hour,
		"minute": minute,
		"second": second,
		"total_countdown_seconds": total_seconds,
		"remaining_countdown_seconds": remaining_seconds,
		"is_counting": is_counting
	}

func load_time_data(data: Dictionary) -> void:
	"""โหลดข้อมูลเวลาจากการบันทึก"""
	if data.has("day"):
		day = data["day"]
	if data.has("hour"):
		hour = data["hour"]
	if data.has("minute"):
		minute = data["minute"]
	if data.has("second"):
		second = data["second"]
	
	if data.has("total_countdown_seconds"):
		total_seconds = data["total_countdown_seconds"]
	if data.has("remaining_countdown_seconds"):
		remaining_seconds = data["remaining_countdown_seconds"]
	if data.has("is_counting"):
		is_counting = data["is_counting"]
	
	# ส่งสัญญาณให้ GUI อัปเดต
	time_changed.emit(remaining_seconds / 60, remaining_seconds % 60)
	
	# เริ่มต้อม timer ใหม่เสมอเมื่อโหลดเกม
	start_countdown()
	
	print("✅ Time data loaded: %s" % get_time_string())
