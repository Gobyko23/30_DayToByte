# ระบบ NPC ตอบคำถาม (Question System)

## ภาพรวม
ระบบนี้ช่วยให้ NPC สามารถถามคำถามผู้เล่น และแสดง UI ปุ่ม "Accept/Refuse" เพื่อให้ผู้เล่นตัดสินใจรับภารกิจหรือไม่

## ขั้นตอนการใช้งาน

### 1. ตั้งค่า QuestData.gd
เมื่อสร้าง Quest ที่เป็นคำถาม ให้กำหนด:

```gdscript
# ประเภท NPC
@export var npc_type: NPC_TYPE = NPC_TYPE.QUESTION

# ข้อความคำถาม
@export var questions_dialogue: Array[String] = ["คุณพร้อมตอบคำถามหรือไม่?"]
@export var question_text: String = "1 + 1 = ?"
@export var accept_question_dialogue: Array[String] = ["ดีเลย! นี่คือคำถามของฉัน"]
```

### 2. ตั้งค่า NPC_Quest_System.gd
เมื่อ NPC ถูกใช้งาน ระบบจะ:

1. **เช็คประเภท NPC** - ถ้าเป็น `QUESTION` ให้เตรียมคำถาม
2. **ส่งข้อมูลไป NPC_Script.gd** - รวม dialogues และ action

```
get_current_interaction() 
  → dialogues = [questions_dialogue + question_text + "จะรับภารกิจหรือไม่?"]
  → action = NEXT_ACTION.START_QUEST
```

### 3. แสดง UI ใน NPC_Script.gd

เมื่อ NPC พูดจบ:

```
show_dialogue()
  → เช็คว่า is_question_phase == true หรือไม่
  → แสดงข้อความ "จะรับภารกิจหรือไม่?"
  → เปิดปุ่ม Accept_btn และ Refise_btn
```

### 4. การกดปุ่ม

**กดปุ่ม Accept:**
```gdscript
_on_accept_btn_pressed()
  → pending_quest_action = NEXT_ACTION.START_QUEST
  → call end_dialogue()
  → quest_system.perform_action(START_QUEST)
  → บันทึก is_question_answered = false (ยังไม่ได้ตอบ)
```

**กดปุ่ม Refuse:**
```gdscript
_on_refise_btn_pressed()
  → pending_quest_action = NEXT_ACTION.NONE
  → call end_dialogue()
  → ปิดหน้าต่าง ไม่รับภารกิจ
```

### 5. บันทึกข้อมูล (SaveAndLoadscript.gd)

สิ่งที่บันทึก:
- `is_question_answered` - สถานะว่าตอบคำถามแล้วหรือไม่
- `npc_question_states` - Dictionary เก็บสถานะทั้ง NPC

```gdscript
save_game()
  → _export_npc_question_states()
  → ส่ง {"npc_name": {"is_question_answered": true/false}} 

load_game()
  → _restore_npc_question_states()
  → เรียกใช้ _apply_npc_question_states() ลงไปใน NPC nodes
```

## ตัวอย่างการใช้งาน

### สร้าง Quest คำถาม
```gdscript
var question_quest = QuestData.new()
question_quest.quest_id = "q_001"
question_quest.npc_type = QuestData.NPC_TYPE.QUESTION
question_quest.questions_dialogue = ["ฉันมีคำถามให้คุณ"]
question_quest.question_text = "2 + 2 = ?"
question_quest.reward_money = 50
```

### ตัวแปรที่ติดตามสถานะ
- `is_question_answered` (NPC_Quest_System.gd) - ว่าตอบแล้วหรือไม่
- `is_question_phase` (NPC_Script.gd) - ว่ากำลังแสดงหน้าต่างคำถาม
- `pending_quest_action` (NPC_Script.gd) - action ที่รอการทำ

## Flow diagram

```
NPC Interaction
     ↓
get_current_interaction() [NPC_Quest_System]
     ↓
Check: npc_type == QUESTION?
     ↓ Yes
current_dialogue_queue = [questions_dialogue + question_text + "จะรับ?"]
pending_quest_action = START_QUEST
     ↓
show_dialogue() [NPC_Script]
     ↓
Play dialogues...
     ↓
All dialogues played?
     ↓ Yes
is_question_phase = true
Show: "จะรับภารกิจหรือไม่?"
Show: Accept_btn + Refuse_btn
     ↓
Wait for button click
     ↓
[Accept] → pending_quest_action = START_QUEST → end_dialogue() → perform_action()
[Refuse] → pending_quest_action = NONE → end_dialogue()
     ↓
Save/Load: is_question_answered state
```

## Signal Flow

```
accept_btn.pressed.connect(_on_accept_btn_pressed)
     ↓
_on_accept_btn_pressed()
     ↓
end_dialogue()
     ↓
quest_system.perform_action(NEXT_ACTION.START_QUEST)
     ↓
is_question_answered = false
     ↓
SaveAndLoad saves state
```

## สิ่งที่ได้เพิ่มเข้ามา

### QuestData.gd
- `questions_dialogue: Array[String]` - บทพูดก่อนถามคำถาม
- `question_text: String` - ข้อความคำถาม
- `accept_question_dialogue: Array[String]` - บทพูดหลังรับคำถาม

### NPC_Quest_System.gd
- `is_question_answered: bool` - สถานะ
- ปรับแต่ง `get_current_interaction()` เพื่อรองรับคำถาม
- ปรับแต่ง `perform_action()` สำหรับ `START_QUEST` กรณีคำถาม

### NPC_Script.gd
- `is_question_phase: bool` - สถานะ
- ปรับแต่ง `show_dialogue()` เพื่อแสดง "จะรับภารกิจ?"
- เพิ่ม `_on_accept_btn_pressed()` และ `_on_refise_btn_pressed()`
- ปรับแต่ง `_ready()` เพื่อเชื่อม signal

### SaveAndLoadscript.gd
- `_export_npc_question_states()` - ส่งออกสถานะ
- `_restore_npc_question_states()` - โหลดสถานะ
- `_collect_npc_question_states()` - รวบรวม data จาก NPC
- `_apply_npc_question_states()` - ใช้ข้อมูลกับ NPC
- เพิ่ม `"npc_question_states"` ใน save data

## บันทึก
- ระบบตรวจสอบ `npc_type == QUESTION` เพื่อทำให้มีความแตกต่างจาก Quest ปกติ
- สถานะคำถามถูกบันทึกและโหลดอัตโนมัติ
- ปุ่ม Accept/Refuse จะซ่อนโดยอัตโนมัติเมื่อจบการคุย
