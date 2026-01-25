# ไฟล์นี้เป็นตัวอย่างวิธีการใช้ DialogueData Resource
# คุณสามารถสร้างไฟล์ .tres ผ่าน Editor โดยดำเนินการดังนี้:
# 1. ที่ FileSystem ให้ขวาคลิกที่โฟลเดอร์ -> New Resource -> DialogueData
# 2. ตั้งชื่อไฟล์เป็น "dialogue_npc_name.tres"
# 3. คลิก Save

# ตัวอย่างการสร้าง DialogueData ผ่านโค้ด:
#
# extends Node
#
# func _ready():
#     # สร้าง DialogueData object
#     var greeting_dialogue = DialogueData.new(
#         "dialogue_001",
#         "Greeting Dialogue",
#         ["สวัสดี!", "ยินดีที่ได้พบคุณ", "คุณมีความสุขหรือไม่?"]
#     )
#
#     # หรือสร้างผ่าน export variable ใน NPC scene
#     var npc = get_node("NPC")
#     npc.set_dialogue(greeting_dialogue)
#
# ========================================
# ตัวอย่างการใช้ใน NPC Scene:
# ========================================
#
# 1. สร้าง DialogueData Resource (.tres file)
#    - โฟลเดอร์ Scripts/Data/Dialogues (สร้างใหม่)
#    - สร้าง "greeting.tres", "farewell.tres" เป็นต้น
#
# 2. ใน Scene Tree ของ NPC:
#    - เลือก NPC node
#    - Inspector -> NPC_Script (script)
#    - Dialogue Data -> ลากไฟล์ greeting.tres มาวาง
#
# 3. เมื่อ Player interact:
#    - เรียก interacting()
#    - DialogueData จะแสดง dialogue ทีละหนึ่ง
#    - Player กด interact button เพื่อ next_dialogue()
