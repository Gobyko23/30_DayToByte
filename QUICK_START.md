# 📌 QUICK START - ขั้นตอนการตั้งค่า

## 1️⃣ ต้องทำใน Godot Editor ก่อน

### Step 1: Register PointSystem เป็น Autoload
```
1. เปิด Godot Editor
2. ไปที่ Project → Project Settings → Autoload
3. ค้นหา "CashSystem" และลบมันออก
4. เพิ่ม PointSystem ใหม่:
   - Path: res://Scripts/ItemSystem/PointSystem.gd
   - Node Name: PointSystem
   - คลิก "Add"
5. Save project.godot
```

### Step 2: อัปเดต UI ที่แสดงคะแนน
```
ถ้าคุณใช้ MoneyLabel อยู่:
- ฉันแก้มันไปแล้ว ให้ใช้ PointSystem แทน CashSystem
- ชื่อใหม่: MoneyLabel.gd (แต่ใช้ PointSystem)
- หรือสร้าง PointsLabel.gd ใหม่

ถ้าคุณสร้าง UI เอง:
- ใช้: PointSystem.points_changed.connect(_callback)
- แทน: CashSystem.money_changed.connect(_callback)
```

---

## 2️⃣ ตัวอักษร Warnings ที่อาจเห็น

**Warning**: PointSystem not declared
- ✅ ปกติ! เพราะยังไม่ได้ register เป็น Autoload
- วิธีแก้: ทำ Step 1 ด้านบน

**Warning**: CashSystem ไม่พบ
- ✅ ปกติ! ลบออกจาก Autoload แล้ว
- วิธีแก้: ใช้ PointSystem แทน

---

## 3️⃣ ทดสอบระบบ

```gdscript
# ใน Any Script:

# ✅ ทดสอบ PointSystem
func test_point_system():
	print("Current Points: ", PointSystem.points)
	PointSystem.add(100)
	print("After add(100): ", PointSystem.points)
	
	if PointSystem.spend(50):
		print("Spent 50, Remaining: ", PointSystem.points)
	
	print("Has 100 points? ", PointSystem.has(100))

# ✅ ทดสอบ Save/Load
func test_save_load():
	SaveAndLoad.save_game(1)
	print("Game saved!")
	
	var loaded = SaveAndLoad.load_game(1)
	print("Loaded points: ", loaded["player"]["points"])

# ✅ ทดสอบ NPC Quest State
func test_npc_state():
	var npc = get_tree().root.find_child("NPCName", true, false)
	if npc:
		npc.debug_npc_state()  # แสดง state ปัจจุบัน
```

---

## 4️⃣ ค้นหาข้อมูล

### ดูค่า Points ปัจจุบัน:
```gdscript
print(PointSystem.points)  # ดูคะแนน
```

### ดูค่า NPC State:
```gdscript
var npc_mgr = get_node("/root/NPCManager")
var npc_state = npc_mgr.get_npc_state("NPC_Name")
print(npc_state)  # ดูสถานะ NPC
```

### ดูไฟล์ Save:
```
File Location: user://saves/slot_1.json
เมื่อแก้ไขสำเร็จ จะเห็น:
{
  "player": {
	"points": 150,  # ✅ NEW! (เดิม "money")
	...
  },
  "npcs": {
	"NPC_Name": {
	  "current_processing_quest_id": "quest_001",  # ✅ NEW!
	  ...
	}
  }
}
```

---

## 5️⃣ Troubleshooting

### ❌ PointSystem ไม่พบ
**สาเหตุ**: ยังไม่ register ใน Autoload
**แก้ไข**: ทำ Step 1 ด้านบน

### ❌ NPC ไม่ restore quest state
**สาเหตุ**: SaveAndLoad ยังไม่รันการ restore
**แก้ไข**: ตรวจสอบว่าเรียก `_restore_all_npc_states()` แล้วหรือยัง

### ❌ UI ไม่อัปเดตคะแนน
**สาเหตุ**: MoneyLabel ยังเชื่อมต่อกับ CashSystem
**แก้ไข**: เปลี่ยนไปเชื่อมต่อ PointSystem.points_changed

---

## 6️⃣ File Reference

| File | Status | วัตถุประสงค์ |
|------|--------|-----------|
| `PointSystem.gd` | ✅ สร้างใหม่ | ระบบคะแนน (autoload) |
| `PointsLabel.gd` | ✅ สร้างใหม่ | แสดง UI คะแนน |
| `NPCManager.gd` | ✅ อัปเดต | เก็บ current_processing_quest_id |
| `NPC_Quest_System.gd` | ✅ อัปเดต | ส่งข้อมูล quest ไป NPCManager |
| `SaveAndLoadscript.gd` | ✅ อัปเดต | บันทึก points + NPC quest state |
| `QuestManager.gd` | ✅ อัปเดต | ใช้ PointSystem.add() |
| `Box.gd` | ✅ อัปเดต | ใช้ PointSystem.add(50) |
| `MoneyLabel.gd` | ✅ อัปเดต | ใช้ PointSystem |
| `MainData.gd` | ✅ อัปเดต | โหลด points จาก save |
| `PlayerData.gd` | ✅ อัปเดต | ลบ money variable |
| `project.godot` | ✅ อัปเดต | PointSystem autoload |

---

## 7️⃣ API Reference

### PointSystem
```gdscript
PointSystem.points                    # ดูคะแนนปัจจุบัน
PointSystem.add(amount: int)         # เพิ่มคะแนน
PointSystem.spend(amount: int) -> bool  # ใช้คะแนน (คืนสำเร็จหรือไม่)
PointSystem.has(amount: int) -> bool    # เช็คคะแนนเพียงพอ
PointSystem.set_points(amount: int)     # กำหนดคะแนน (สำหรับ Load)
PointSystem.points_changed             # Signal ที่ emit เมื่อคะแนนเปลี่ยน
```

### NPCManager
```gdscript
npc_mgr.set_npc_action_state(
	npc_name: String, 
	action: int,              # NONE/START_QUEST/COMPLETE_QUEST
	quest_id: String,         # Quest ID ที่ active
	current_processing_quest_id: String  # Quest ID ที่ NPC จัดการ
)

npc_mgr.get_npc_action_state(npc_name: String) -> Dictionary
# Returns: {
#   "action": int,
#   "quest_id": String,
#   "current_processing_quest_id": String  # ✅ NEW!
# }
```

### NPC_Quest_System
```gdscript
npc.debug_npc_state()  # แสดง state เพื่อ debug
```

---

## ✨ สำเร็จ!

ขั้นตอนทั้งหมดเสร็จแล้ว! 🎉

- ✅ ระบบ Save บันทึก current_processing_quest
- ✅ เปลี่ยน Money → Points
- ✅ NPC จำ Quest state หลังจาก Load Game

**ต่อไปควรทำ**:
1. Register PointSystem ใน Autoload
2. ทดสอบ Save/Load
3. ทดสอบ NPC Quest flow
4. ลบ CashSystem.gd (ถ้าไม่ใช้แล้ว)
