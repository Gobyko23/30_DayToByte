'''
# ========================================
# ExampleQuestData.gd - ตัวอย่างการใช้ QuestData
# ========================================
# ไฟล์นี้แสดงวิธีใช้ QuestData ทั้ง 2 วิธี:
# 1. ผ่านโค้ด (Scripting)
# 2. ผ่าน Inspector (Resource file)
# ========================================

extends Node
class_name ExampleQuestData

# ========================================
# วิธีที่ 1: การสร้าง QuestData ผ่านโค้ด
# ========================================

func create_quest_by_code() -> QuestData:
	"""
	สร้าง QuestData object ผ่าน code
	"""
	print("\n" + "=".repeat(60))
	print("📖 วิธีที่ 1: สร้าง QuestData ผ่านโค้ด")
	print("=".repeat(60))
	
	# สร้าง QuestData ใหม่
	var new_quest = QuestData.new(
		"quest_001",                      # quest_id
		"ค้นหาของหายไป",                  # quest_name
		"ฉันสูญเสีย key สำคัญ ช่วยหาให้หน่อย",  # description
		500,                              # reward_money
		QuestData.NPC_TYPE.QUEST_GIVER   # npc_type
	)
	
	# ตั้งค่า reward items
	new_quest.reward_items = ["potion_health", "gold_coin"]
	
	# ตั้งค่า Dialogue ต่างๆ
	new_quest.give_quest_dialogue = [
		"สวัสดี! ฉันมีปัญหา",
		"ฉันสูญเสีย key สำคัญ",
		"คุณช่วยหาให้หน่อยได้ไหม?"
	]
	
	new_quest.complete_quest_dialogue = [
		"ขอบคุณมากที่หาให้!",
		"คุณเป็นคนดี!"
	]
	
	new_quest.reward_dialogue = [
		"นี่คือเงินและไอเทมรางวัล",
		"ยินดีที่ได้ช่วยคุณ!"
	]
	
	# แสดงข้อมูล
	new_quest.debug_print_all()
	
	return new_quest


# ========================================
# วิธีที่ 2: การใช้ QuestData Resource (.tres file)
# ========================================

@export var quest_from_resource: QuestData = null  # ลากไฟล์ .tres มาวางที่นี่

func load_quest_from_resource() -> void:
	"""
	ใช้ QuestData ที่บันทึกไว้เป็น .tres file
	"""
	print("\n" + "=".repeat(60))
	print("📖 วิธีที่ 2: ใช้ QuestData ผ่าน Inspector (Resource file)")
	print("=".repeat(60))
	
	if quest_from_resource:
		print("\n✅ Quest loaded from resource:")
		quest_from_resource.debug_print_all()
	else:
		print("\n❌ ไม่มี quest resource ที่ลากมา")
		print("   วิธีการตั้งค่า:")
		print("   1. ขวาคลิก Scripts/Data/Example/")
		print("   2. New Resource -> QuestData")
		print("   3. ตั้งค่าข้อมูลใน Inspector")
		print("   4. Save ให้ชื่อเป็น example_quest.tres")
		print("   5. ลากไฟล์มาวาง Inspector -> quest_from_resource")


# ========================================
# ตัวอย่างการใช้งานในเกม
# ========================================

func example_quest_workflow() -> void:
	"""
	ตัวอย่าง workflow ของ Quest
	"""
	print("\n" + "=".repeat(60))
	print("🎮 ตัวอย่าง Quest Workflow")
	print("=".repeat(60))
	
	# สร้าง quest
	var quest = create_quest_by_code()
	
	# NPC ให้ quest แก่ player
	print("\n1️⃣  Player interact กับ NPC")
	quest.activate_quest()
	print("   \" ", quest.give_quest_dialogue[0], " \"")
	
	# Player ทำ quest เสร็จ
	print("\n2️⃣  Player ทำ quest เสร็จ")
	quest.complete_quest()
	print("   Status: ", "✅ Completed" if quest.is_completed else "❌ Not completed")
	
	# Player กลับมาหา NPC
	print("\n3️⃣  Player กลับมาหา NPC")
	print("   \" ", quest.complete_quest_dialogue[0], " \"")
	print("   \" ", quest.reward_dialogue[0], " \"")
	
	# แสดงรางวัล
	print("\n4️⃣  ได้รับรางวัล:")
	print("   💰 เงิน: ", quest.reward_money)
	print("   🎁 ไอเทม:", quest.reward_items)


# ========================================
# ขั้นตอนการใช้งาน Resource
# ========================================

"""
📝 ขั้นตอนสร้าง QuestData Resource (.tres file):

1. สร้างไฟล์ Resource:
   - ขวาคลิกที่ Scripts/Data/Example/
   - เลือก "New Resource"
   - เลือก "QuestData" จากรายการ
   
2. ตั้งค่า Quest:
   - กรอก quest_id, quest_name, description เป็นต้น
   - ตั้งค่า Reward Money, Reward Items
   - ตั้งค่า NPC Type (DIALOGUE_ONLY หรือ QUEST_GIVER)
   - เพิ่ม Dialogue ต่างๆ
   
3. บันทึก Resource:
   - ตั้งชื่อไฟล์ เช่น "tutorial_quest.tres"
   - Save ที่ Scripts/Data/Example/
   
4. ใช้งานใน Scene:
   - ใน NPC Script, เลือก @export var current_quest
   - ลากไฟล์ .tres มาวาง
   
5. ใช้งานใน Code:
   - var my_quest = load("res://Scripts/Data/Example/tutorial_quest.tres")
   - npc.current_quest = my_quest
   
========================================

✨ ข้อดีของการใช้ Resource:
- ไม่ต้องเขียนโค้ด สามารถตั้งค่าผ่าน Inspector
- สามารถสร้าง quest ได้หลายตัวพร้อมกัน
- ง่ายต่อการแก้ไข เปลี่ยนแปลงข้อมูล
- สามารถนำมาใช้ใหม่ได้ในหลายที่
- เก็บข้อมูลแยกจากโค้ด (Data-driven design)
"""

# ========================================
# Test Functions
# ========================================

func _ready() -> void:
	# แสดงตัวอย่างเมื่อเกมเริ่มต้น
	# ให้ uncomment เพื่อทดลอง
	
	# create_quest_by_code()
	# load_quest_from_resource()
	# example_quest_workflow()
	pass


func _process(_delta: float) -> void:
	# ปุ่มทดสอบ (ถ้าต้องการ)
	if Input.is_action_just_pressed("ui_accept"):
		print("\n🔷 คุณกด Accept")
		example_quest_workflow()
'''