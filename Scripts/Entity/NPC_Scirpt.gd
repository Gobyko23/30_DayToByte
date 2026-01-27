extends Obj_Main
class_name NPC

@onready var Dialogue_sprite :Sprite3D = $NPC_Dialog
@onready var Dialogue_text :RichTextLabel = $NPC_Dialog/SubViewport/Control/RichTextLabel
@onready var Anotation :Sprite3D = $NPC_UnknowTation
@onready var world_camera = get_tree().get_first_node_in_group("WorldCamera")
@onready var focus_marker: Marker3D = $NPC_Sprite/NpcPivot

# ระบบ Quest
@export var quest_system: NPCQuestSystem
# ตัวแปรจัดการบทพูด
var current_dialogue_queue: Array[String] = [] # เก็บข้อความที่จะพูด
var current_line_index: int = 0              # บรรทัดปัจจุบัน
var pending_quest_action = NPCQuestSystem.NEXT_ACTION.NONE # สิ่งที่ต้องทำหลังคุยจบ
var is_talking: bool = false

func _ready() -> void:
	# Setup UI
	if Dialogue_text: Dialogue_text.text = ""
	if Dialogue_sprite: Dialogue_sprite.visible = false
	
	# Setup System
	add_child(quest_system)
	quest_system.npc_name = String(name)
	
	# (Option) ถ้าคุณตั้งค่า Quest ใน Inspector ของ NPC_Script
	# คุณอาจต้องส่งค่า quest_list ไปให้ quest_system ด้วย
	# quest_system.quest_list = self.quest_list (ถ้ามีตัวแปรนี้)

func interacting():
	# เริ่มต้นการคุย
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.is_talking = true
		player.talking_npc = self 
		if Anotation: Anotation.visible = false
		if Dialogue_sprite: Dialogue_sprite.visible = true
	
	is_talking = true
	
	# 1. ขอข้อมูลจาก Quest System
	var interaction_data = quest_system.get_current_interaction()
	
	# 2. ตั้งค่าตัวแปร
	# ----------------- แก้ไขตรงนี้ -----------------
	# ลบ: current_dialogue_queue = interaction_data["dialogues"]
	# ใช้บรรทัดนี้แทน:
	current_dialogue_queue.assign(interaction_data["dialogues"]) 
	# ---------------------------------------------
	
	pending_quest_action = interaction_data["action"]
	current_line_index = 0
	
	# 3. เริ่มแสดงผล
	show_dialogue()

func show_dialogue():
	# จัดการกล้อง
	if not world_camera: world_camera = get_tree().get_first_node_in_group("WorldCamera")
	if not focus_marker: focus_marker = get_node_or_null("NPC_Sprite/NpcPivot")
	if world_camera and focus_marker: world_camera.focus_on(focus_marker)
	
	# แสดงข้อความ
	if current_line_index < current_dialogue_queue.size():
		var text_to_show = current_dialogue_queue[current_line_index]
		if Dialogue_text:
			Dialogue_text.text = text_to_show
		print("NPC Says: ", text_to_show)
	else:
		# ถ้า Index เกินขนาด Array แปลว่าคุยจบแล้ว
		end_dialogue()

func next_dialogue():
	if not is_talking: return
	
	# ขยับไปบรรทัดถัดไป
	current_line_index += 1
	
	if current_line_index < current_dialogue_queue.size():
		show_dialogue()
	else:
		end_dialogue()

func end_dialogue():
	print("End Logic")
	is_talking = false
	
	# 1. ทำ Action ของ Quest (เช่น รับเควส / รับรางวัล)
	if pending_quest_action != NPCQuestSystem.NEXT_ACTION.NONE:
		quest_system.perform_action(pending_quest_action)
		pending_quest_action = NPCQuestSystem.NEXT_ACTION.NONE
	
	# 2. คืนค่า Player และ UI
	if Dialogue_sprite: Dialogue_sprite.visible = false
	if Anotation: Anotation.visible = true
	if world_camera: world_camera.release_focus()
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.is_talking = false
		player.showbar()
		
	# ล้างค่า
	current_dialogue_queue.clear()
	current_line_index = 0

# Override ฟังก์ชัน interact_event (ตามเดิมของคุณ)
func interact_event_in():
	if Anotation: Anotation.visible = true
func interact_event_out():
	if Anotation: Anotation.visible = false
