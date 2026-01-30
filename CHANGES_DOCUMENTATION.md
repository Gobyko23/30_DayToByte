# 📝 เอกสารการปรับปรุงระบบ Save/Load และ NPC Quest

## ✅ ที่ทำเสร็จแล้ว

### 1. เปลี่ยนระบบเงิน เป็น ระบบคะแนน (Points)
- ❌ **ลบ**: `CashSystem.gd` - ระบบเงินเก่า
- ✅ **สร้างใหม่**: `PointSystem.gd` - ระบบคะแนนใหม่
- ✅ **อัปเดต**: 
  - `QuestManager.gd` - เปลี่ยนจาก `CashSystem.add()` → `PointSystem.add()`
  - `Box.gd` - เปลี่ยนจาก `CashSystem.add(50)` → `PointSystem.add(50)`
  - `SaveAndLoadscript.gd` - บันทึก/โหลด `points` แทน `money`
  - `project.godot` - Autoload ใช้ `PointSystem` แทน `CashSystem`

### 2. ปรับปรุง UI สำหรับแสดงคะแนน
- ✅ **สร้างใหม่**: `PointsLabel.gd` - แทน `MoneyLabel.gd`
- เปลี่ยนจาก `CashSystem.money_changed` → `PointSystem.points_changed`
- เปลี่ยน UI text จาก `"$ "` → `"📊 "`

### 3. ระบบ Save บันทึก current_processing_quest
- ✅ **อัปเดต NPCManager.gd**:
  - เพิ่มฟิลด์ `current_processing_quest_id` ใน NPC state dictionary
  - ปรับปรุง `set_npc_action_state()` เพื่อรับและบันทึก `current_processing_quest_id`
  - ปรับปรุง `get_npc_action_state()` เพื่อส่งกลับข้อมูล `current_processing_quest_id`

- ✅ **อัปเดต NPC_Quest_System.gd**:
  - อัปเดต `_update_npc_action_state()` เพื่อส่ง `current_processing_quest_id`
  - ปรับปรุง `_restore_state_from_npc_manager()` เพื่อ restore `current_processing_quest` จาก saved state
  - เพิ่มการค้นหา quest ใน `quest_pool` ถ้าไม่พบใน `quest_list`
  - เพิ่ม debug function `debug_npc_state()` เพื่อเอกสาร state

- ✅ **อัปเดต SaveAndLoadscript.gd**:
  - เปลี่ยน `CashSystem.set_money()` → `PointSystem.set_points()`
  - บันทึก `points` แทน `money` ในไฟล์ save

### 4. ปรับปรุง NPC Quest Logic
- ✅ เพิ่ม debug output เพื่อติดตาม state ของ quest:
  - `📌 Quest status: NEW (ready to give)`
  - `📌 Quest status: IN PROGRESS (waiting for completion)`
  - `📌 Quest status: READY TO SUBMIT`
  - `📌 Quest status: COMPLETED`
  - `🎯 Processing quest for NPC ...` เพื่อแสดง NPC กำลังจัดการ quest ไหน

---

## 🔄 ขั้นตอนการใช้งาน

### ตั้งค่า Autoload ใหม่ใน project.godot
```
PointSystem="*res://Scripts/ItemSystem/PointSystem.gd"
```

### ใช้ PointSystem แทน CashSystem ทั่วโลก
```gdscript
# เพิ่มคะแนน
PointSystem.add(50)

# ใช้คะแนน
if PointSystem.spend(100):
    # สำเร็จ
    pass

# ตรวจสอบคะแนนเพียงพอ
if PointSystem.has(100):
    # มีคะแนนเพียงพอ
    pass

# กำหนดคะแนน (ใช้เมื่อ Load Game)
PointSystem.set_points(250)
```

### Debug NPC Quest State
```gdscript
# เรียก function นี้บน NPC node ของคุณ
npc_node.debug_npc_state()
```

---

## 📊 ข้อมูล NPC State ที่เก็บ

```
npc_states[npc_name] = {
    "visited": bool,                          # เคยไปหานี้เหรอ
    "greeted": bool,                          # เคยพูดจากับ NPC นี้เหรอ
    "interaction_count": int,                 # จำนวนครั้งที่คุยกับ NPC
    "last_quest_given": String,               # Quest ID ที่ให้ล่าสุด
    "pending_action": int,                    # NEXT_ACTION enum (NONE/START_QUEST/COMPLETE_QUEST)
    "current_quest_id": String,               # Quest ID ที่ active ปัจจุบัน
    "current_processing_quest_id": String     # Quest ID ที่ NPC กำลังจัดการ (NEW!)
}
```

---

## 🐛 Debug Tips

### ดูว่า NPC ส่ง quest_id ไป NPCManager หรือเปล่า
```gdscript
# ใน NPC_Quest_System.gd
print(current_processing_quest.quest_id) # ควร print ID ของ quest
```

### เช็คค่า Save
```gdscript
# ใน SaveAndLoadscript.gd line ~20
print("💾 Saving: ", data) # จะเห็นค่า "points" แทน "money"
```

### เช็ค Restore NPC State
```gdscript
# ใน SaveAndLoadscript.gd _restore_all_npc_states()
# ควร print "✅ NPC states restored!" เมื่อโหลดเสร็จ
```

---

## ⚠️ ข้อสังเกต

1. **CashSystem.gd**: ยังเหลืออยู่ แต่ไม่ได้ใช้แล้ว (อาจลบออกได้ภายหลัง)
2. **MoneyLabel.gd**: ยังเหลืออยู่ แต่ควรจะอัปเดตให้ใช้ `PointSystem` หรือสร้าง `PointsLabel.gd` ใหม่
3. **current_processing_quest**: เก็บใน NPC state เพื่อ restore หลังจาก load game

---

## 📥 File ที่เปลี่ยนแปลง

```
✅ Scripts/ItemSystem/PointSystem.gd (สร้างใหม่)
✅ Scripts/ItemSystem/PointsLabel.gd (สร้างใหม่)
✅ Scripts/Data/NPCManager.gd (อัปเดต)
✅ Scripts/Data/QuestManager.gd (อัปเดต)
✅ Scripts/Entity/NPC_Quest_System.gd (อัปเดต)
✅ Scripts/Entity/Box.gd (อัปเดต)
✅ Scripts/SaveSystem/SaveAndLoadscript.gd (อัปเดต)
✅ project.godot (อัปเดต Autoload)
```

---

## 🚀 ขั้นตอนถัดไปแนะนำ

1. ตรวจสอบ MoneyLabel.gd ว่าใช้ `PointSystem` หรือไม่
2. ลองบันทึกเกมและโหลดกลับมาเพื่อทดสอบ
3. โทร `debug_npc_state()` บน NPC เพื่อเช็คว่า state restore ถูกหรือไม่
4. ลบ CashSystem.gd ถ้าไม่ได้ใช้แล้ว
