extends Resource
class_name DialogueData

# ข้อมูล Dialogue
@export var dialogue_id: String = "dialogue_001"
@export var dialogue_name: String = "Default Dialogue"
@export var dialogues: Array[String] = []

# ตั้งค่าเพิ่มเติม
@export var auto_play: bool = false  # เล่นอัตโนมัติเมื่อ interact
@export var close_on_end: bool = true  # ปิด dialogue เมื่อจบ

var current_index: int = 0
var is_completed: bool = false

# Constructor
func _init(p_id: String = "", p_name: String = "", p_dialogues: Array[String] = []) -> void:
	dialogue_id = p_id
	dialogue_name = p_name
	dialogues = p_dialogues.duplicate()

# รีเซ็ต Dialogue
func reset() -> void:
	current_index = 0
	is_completed = false

# ได้รับ Dialogue ปัจจุบัน
func get_current_dialogue() -> String:
	if current_index < dialogues.size():
		return dialogues[current_index]
	is_completed = true
	return ""

# ไปยัง Dialogue ถัดไป
func next_dialogue() -> String:
	current_index += 1
	if current_index >= dialogues.size():
		is_completed = true
		return ""
	return dialogues[current_index]

# ไปยัง Dialogue ก่อนหน้า
func previous_dialogue() -> String:
	if current_index > 0:
		current_index -= 1
	return dialogues[current_index] if current_index < dialogues.size() else ""

# ตั้งค่า Dialogue ตามดัชนี
func set_dialogue_by_index(index: int) -> String:
	if index >= 0 and index < dialogues.size():
		current_index = index
		return dialogues[index]
	return ""

# ตรวจสอบว่า Dialogue จบหรือไม่
func is_dialogue_complete() -> bool:
	return is_completed or current_index >= dialogues.size()

# ได้จำนวน Dialogue ทั้งหมด
func get_dialogue_count() -> int:
	return dialogues.size()

# ได้ดัชนี Dialogue ปัจจุบัน
func get_current_index() -> int:
	return current_index

# เพิ่ม Dialogue
func add_dialogue(text: String) -> void:
	dialogues.append(text)

# ลบ Dialogue ตามดัชนี
func remove_dialogue(index: int) -> void:
	if index >= 0 and index < dialogues.size():
		dialogues.remove_at(index)

# ได้ข้อมูล Dialogue ทั้งหมด
func get_dialogue_info() -> Dictionary:
	return {
		"id": dialogue_id,
		"name": dialogue_name,
		"total_dialogues": dialogues.size(),
		"current_index": current_index,
		"is_completed": is_completed,
		"dialogues": dialogues.duplicate()
	}

# Debug - พิมพ์ข้อมูล Dialogue
func debug_print() -> void:
	print("\n" + "=".repeat(50))
	print("💬 DIALOGUE DEBUG INFO")
	print("=".repeat(50))
	print("ID: ", dialogue_id)
	print("Name: ", dialogue_name)
	print("Current Index: ", current_index)
	print("Total Dialogues: ", dialogues.size())
	print("Is Completed: ", is_completed)
	print("\nAll Dialogues:")
	for i in range(dialogues.size()):
		var marker = ">>> " if i == current_index else "    "
		print(marker + "[" + str(i) + "] " + dialogues[i])
	print("=".repeat(50) + "\n")
