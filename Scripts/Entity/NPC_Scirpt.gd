extends Obj_Main
class_name NPC

@onready var Dialogue_sprite :Sprite3D = $NPC_Dialog
@onready var Dialogue_text :RichTextLabel = $NPC_Dialog/SubViewport/Control/RichTextLabel
@onready var Anotation :Sprite3D = $NPC_UnknowTation

@onready var world_camera = get_tree().get_first_node_in_group("WorldCamera")
@onready var focus_marker: Marker3D = $NPC_Sprite/NpcPivot

# ระบบ Dialogue
@export var dialogue_data: DialogueData = null  # Dialogue Resource
@export var default_dialogue: Array[String] = []  # Dialogue สำรอง

# ระบบ Quest
@onready var quest_system: NPCQuestSystem = NPCQuestSystem.new()
@export var current_quest: QuestData = null  # เก็บ Quest Data ปัจจุบัน

var current_dialogue_source: Array[String] = []  # เก็บ Dialogue จาก Quest
var quest_state: String = ""  # เก็บสถานะ Quest: "give", "complete", "reward"
var is_showing_dialogue: bool = false  # ตรวจสอบว่าแสดง dialogue อยู่หรือไม่

func _ready() -> void:
	if Dialogue_text:
		Dialogue_text.text = ""
	if Dialogue_sprite:
		Dialogue_sprite.visible = false
	
	# ถ้ามี dialogue_data ให้รีเซ็ต
	if dialogue_data:
		dialogue_data.reset()
	
	# ถ้ามี current_quest ให้ใช้ dialogue จาก quest นั้น
	if current_quest:
		set_quest_dialogue(current_quest)
	
	# เตรียม Quest System
	add_child(quest_system)
	quest_system.npc_name = name


func interact_event_in():
	print("OBJ: Detect!")
	if Anotation:
		Anotation.visible = true
	
func interact_event_out():
	print("OBJ: Out of length ")
	if Anotation:
		Anotation.visible = false

func interacting():
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.showbar()
		player.is_talking = true
		if Anotation:
			Anotation.visible = false
		player.talking_npc = self 
		if Dialogue_sprite:
			Dialogue_sprite.visible = true
	
	# รีเซ็ต dialogue และเริ่มใหม่
	if dialogue_data:
		dialogue_data.reset()
	
	is_showing_dialogue = true
	show_dialogue()

	
func interacting_cancle():
	pass

#------------------------------------------------------------------------
# ============= ฟังก์ชัน Dialogue System =============

# ฟังก์ชัน: ตั้งค่า Dialogue Resource
func set_dialogue(new_dialogue: DialogueData) -> void:
	dialogue_data = new_dialogue
	if dialogue_data:
		dialogue_data.reset()
		print("📝 Dialogue set: ", dialogue_data.dialogue_name)

# ฟังก์ชัน: ได้ Dialogue ปัจจุบัน
func get_current_dialogue() -> String:
	if dialogue_data:
		return dialogue_data.get_current_dialogue()
	return ""

# ฟังก์ชัน: ตรวจสอบว่า Dialogue จบหรือไม่
func is_dialogue_complete() -> bool:
	if dialogue_data:
		return dialogue_data.is_dialogue_complete()
	return true

# ฟังก์ชัน: ตั้งค่า Quest และ Dialogue จาก Quest Data
func set_quest_dialogue(quest: QuestData, state: String = "give") -> void:
	current_quest = quest
	quest_state = state
	
	match state:
		"give":
			current_dialogue_source = quest.give_quest_dialogue.duplicate()
			print("📋 Quest give dialogue set: ", quest.quest_name)
		"complete":
			current_dialogue_source = quest.complete_quest_dialogue.duplicate()
			print("✅ Quest complete dialogue set: ", quest.quest_name)
		"reward":
			current_dialogue_source = quest.reward_dialogue.duplicate()
			print("🎁 Quest reward dialogue set: ", quest.quest_name)
		_:
			current_dialogue_source = quest.give_quest_dialogue.duplicate()


func end_dialogue():
	is_showing_dialogue = false
	world_camera.release_focus()
	if Anotation:
		Anotation.visible = true
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.is_talking = false
		if Dialogue_text:
			Dialogue_text.text = ""
		player.showbar()
	print("Dialogue ended")
	
	# ปิด Dialogue Sprite
	if Dialogue_sprite:
		Dialogue_sprite.visible = false
	
	
func show_dialogue():
	# เช็ค world_camera ก่อน
	if not world_camera:
		world_camera = get_tree().get_first_node_in_group("WorldCamera")
	if not focus_marker:
		focus_marker = get_node_or_null("NPC_Sprite/NpcPivot")
	
	if world_camera and focus_marker:
		world_camera.focus_on(focus_marker)
	
	# ใช้ Dialogue Resource ที่กำหนด
	if dialogue_data:
		var current_text = dialogue_data.get_current_dialogue()
		if current_text:
			if Dialogue_text:
				Dialogue_text.text = current_text
			print("NPC: ", current_text)
		else:
			# Dialogue จบแล้ว
			if dialogue_data.close_on_end:
				end_dialogue()
	# ใช้ Dialogue จาก Quest ถ้ามี
	elif current_quest and current_dialogue_source.size() > 0:
		show_quest_dialogue()
	# ใช้ Default Dialogue
	elif default_dialogue.size() > 0:
		show_default_dialogue()
	else:
		end_dialogue()


func show_quest_dialogue() -> void:
	var dialogue_array = current_dialogue_source
	# ใช้ quest_state เพื่อเก็บสถานะ dialogue
	# สามารถเพิ่มตัวแปร quest_dialogue_index เพื่อติดตามได้
	pass


func show_default_dialogue() -> void:
	# สามารถใช้สำหรับการแสดง dialogue ทั่วไป
	pass


# ============= ฟังก์ชัน Quest System =============

# ฟังก์ชัน: ตั้งประเภท NPC (Dialogue Only หรือ Quest Giver)
func set_npc_type(npc_type: int) -> void:
	quest_system.change_npc_type(npc_type)


# ฟังก์ชัน: เพิ่ม Quest ให้ NPC
func add_quest_to_npc(quest: QuestData) -> void:
	quest_system.add_quest(quest)


# ฟังก์ชัน: ให้เควสแก่ผู้เล่น
func give_quest_to_player() -> QuestData:
	var quest = quest_system.give_quest()
	if quest:
		# ถ้ามี quest dialogue ให้ใช้นั้น
		if quest_system.give_quest_dialogue.size() > 0:
			current_dialogue_source = quest_system.give_quest_dialogue
	# ถ้า current_quest มี ให้ใช้ dialogue จาก current_quest
	elif current_quest:
		set_quest_dialogue(current_quest, "give")
		quest = current_quest
	return quest


# ฟังก์ชัน: ตรวจสอบว่า Quest เสร็จแล้วหรือไม่
func check_player_quest_done() -> bool:
	return quest_system.check_quest_completion()


# ฟังก์ชัน: เสร็จสิ้น Quest และให้รางวัล
func complete_player_quest() -> void:
	if quest_system.check_quest_completion():
		# ใช้ complete_quest_dialogue
		if quest_system.complete_quest_dialogue.size() > 0:
			current_dialogue_source = quest_system.complete_quest_dialogue
		quest_system.complete_quest_reward()
	elif current_quest:
		# ถ้า current_quest มี ให้ใช้ complete dialogue
		if current_quest.is_completed:
			set_quest_dialogue(current_quest, "complete")
		else:
			# ถ้า quest ยังไม่เสร็จ
			current_dialogue_source = ["Quest ยังไม่เสร็จสิ้น"]
	else:
		# ถ้า quest ยังไม่เสร็จ
		current_dialogue_source = ["Quest ยังไม่เสร็จสิ้น"]


# ฟังก์ชัน: ดึงข้อมูล NPC
func get_npc_info() -> Dictionary:
	return {
		"name": name,
		"type": quest_system.NPC_TYPE.keys()[quest_system.npc_type],
		"quest_count": quest_system.get_quest_count(),
		"current_dialogue": quest_system.get_dialogue()
	}
		
func next_dialogue():
	if dialogue_data and is_showing_dialogue:
		dialogue_data.next_dialogue()
		show_dialogue()
	elif current_dialogue_source.size() > 0:
		# ยังมีการจัดการ quest dialogue
		pass
