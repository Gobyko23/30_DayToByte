extends Panel

@onready var time_text: RichTextLabel = %TimeText
@onready var time_node: Node = %TimeNode
@onready var day_text: RichTextLabel = $DayText
func _ready() -> void:
	# เชื่อมต่อกับสัญญาณของ TimeNode
	time_node.time_changed.connect(_on_time_changed)
	
	# อัปเดตการแสดงผลครั้งแรก ด้วยค่าปัจจุบันจาก TimeNode
	print("⏰ Time Panel initialized")

func _process(delta: float) -> void:
	_on_time_changed(time_node.remaining_seconds / 60, time_node.remaining_seconds % 60)

func _on_time_changed(minutes: int, seconds: int) -> void:
	var time_string = "%02d:%02d" % [minutes, seconds]
	var color = "white"
	var bb_prefix = ""
	var bb_suffix = ""
	
	if minutes == 0 and seconds <= 30:
		color = "#ffd93d" # เหลือง
		bb_prefix = "[wave amp=50.0 freq=5.0]"
		bb_suffix = "[/wave]"
	elif minutes == 0:
		color = "#ff6b6b" # แดง
		bb_prefix = "[shake rate=20.0 level=50]"
		bb_suffix = "[/shake]"

	
	# ใช้การต่อ String แบบนี้จะลดโอกาส Error เรื่อง Tag ว่าง
	var final_bbcode = "[center][color=" + color + "]" + bb_prefix + "[b]" + time_string + "[/b]" + bb_suffix + "[/color][/center]"
	
	time_text.text = final_bbcode
	if time_node.day == time_node.max_days:
		day_text.text = "Day: [shake rate=20.0 level=20][color=red]%d/%d[/color][/shake]" % [time_node.day, time_node.max_days]
	else:
		day_text.text = "Day: [pulse freq=1.0 color=#ffffff40]%d/%d[/pulse]" % [time_node.day, time_node.max_days]