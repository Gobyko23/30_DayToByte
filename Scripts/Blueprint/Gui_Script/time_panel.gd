extends Panel

@onready var time_text: RichTextLabel = %TimeText
@onready var time_node: Node = %TimeNode
@onready var day_text: RichTextLabel = $DayText
@onready var clock_sfx: AudioStreamPlayer = $ClockSFX
@onready var clock_sfxfast: AudioStreamPlayer = $ClockSFXFast
var last_second_checked: int = -1 # ใช้สำหรับเก็บค่าวินาทีล่าสุดที่เล่นเสียงไป

func _ready() -> void:
    time_node.time_changed.connect(_on_time_changed)
    print("⏰ Time Panel initialized")

func _process(_delta: float) -> void:
    var current_minutes = int(time_node.remaining_seconds / 60)
    var current_seconds = int(time_node.remaining_seconds) % 60
    
    # ส่งค่าไปอัปเดต UI (ตามเดิม)
    _on_time_changed(current_minutes, current_seconds)
    
    # เช็คว่าวินาทีเปลี่ยนไปหรือยัง เพื่อเล่นเสียง
    if current_seconds != last_second_checked:
        play_clock_sound()
        last_second_checked = current_seconds

func play_clock_sound():
    # ดึงเวลาปัจจุบันมาเช็ค (Minutes และ Seconds)
    var current_minutes = int(time_node.remaining_seconds / 60)
    var current_seconds = int(time_node.remaining_seconds) % 60
    
    # เงื่อนไข: ถ้า 0 นาที และ น้อยกว่าหรือเท่ากับ 30 วินาที
    if current_minutes <= 0 and current_seconds < 10:
        if clock_sfxfast:
            clock_sfxfast.pitch_scale = randf_range(0.9, 1) # ปรับ pitch ให้ดูตื่นเต้นขึ้นเล็กน้อย
            clock_sfxfast.play()
    else:
        if clock_sfx:
            clock_sfx.pitch_scale = randf_range(0.8,1.2)
            clock_sfx.play()

func _on_time_changed(minutes: int, seconds: int) -> void:
    var time_string = "%02d:%02d" % [minutes, seconds]
    var color = "white"
    var bb_prefix = ""
    var bb_suffix = ""
    
    if minutes <= 0 and seconds >= 10:
        color = "#ffd93d"
        bb_prefix = "[wave amp=50.0 freq=5.0]"
        bb_suffix = "[/wave]"
    elif minutes <= 0 and seconds < 10: # เช็ค minutes ด้วยเพื่อความแม่นยำ
        color = "#ff6b6b"
        bb_prefix = "[shake rate=30.0 level=15]"
        bb_suffix = "[/shake]"

    var final_bbcode = "[center][color=" + color + "]" + bb_prefix + "[b]" + time_string + "[/b]" + bb_suffix + "[/color][/center]"
    time_text.text = final_bbcode
    
    if time_node.day == time_node.max_days:
        day_text.text = "Day: [shake rate=20.0 level=20][color=red]%d/%d[/color][/shake]" % [time_node.day, time_node.max_days]
    else:
        day_text.text = "Day: %d/%d" % [time_node.day, time_node.max_days]