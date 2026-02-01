# 🔧 การตั้งค่า AutoLoad สำหรับ HardwareSpecs

## ขั้นตอนการตั้งค่า AutoLoad

HardwareSpecs และ ItemHelper ต้องเป็น AutoLoad nodes เพื่อให้สามารถเข้าถึงจากที่ใดก็ได้ในเกม

### วิธีตั้งค่า:

1. **เปิด Project Settings**
   - ไปที่ `Project` → `Project Settings`
   - หรือกด `Ctrl + ,`

2. **ไปที่ Tab "AutoLoad"**
   - บนหน้า Project Settings จะมี Tab "AutoLoad"

3. **เพิ่ม HardwareSpecs**
   - Node Path: `res://Scripts/ItemSystem/HardwareSpecs.gd`
   - Node Name: `HardwareSpecs`
   - กด "Add"

4. **เพิ่ม ItemHelper** (optional - ถ้าต้องใช้)
   - Node Path: `res://Scripts/ItemSystem/ItemHelper.gd`
   - Node Name: `ItemHelper`
   - กด "Add"

5. **บันทึกการตั้งค่า**
   - Close Project Settings

---

## ✅ ผลลัพธ์หลังตั้งค่า

หลังจากตั้งค่า AutoLoad เสร็จแล้ว:

- สามารถเรียก `HardwareSpecs.get_specs("CPU_Intel_i5")` จากที่ใดก็ได้
- สามารถเรียก `ItemHelper.get_item_display_name("GPU_RTX_4090")` จากที่ใดก็ได้
- ไม่ต้อง `var hardwareSpecs = HardwareSpecs.new()` อีกต่อไป

---

## 🧪 ทดสอบว่าตั้งค่าถูกต้อง

สร้าง Test script สำหรับทดสอบ:

```gdscript
extends Node

func _ready():
	# ทดสอบดึงข้อมูล
	var specs = HardwareSpecs.get_specs("CPU_Intel_i5")
	print("CPU i5 Details: ", specs)
	
	# ทดสอบดึงชื่อแสดง
	var name = ItemHelper.get_item_display_name("GPU_RTX_4090")
	print("GPU Name: ", name)
	
	# ทดสอบสร้าง Tooltip
	var tooltip = ItemHelper.create_tooltip("RAM_32GB")
	print("Tooltip: ", tooltip)
```

---

## 📝 หมายเหตุ

- **InventorySystem** ควรเป็น AutoLoad ด้วย (ตรวจสอบในเกมว่าตั้งไว้แล้วหรือไม่)
- **PointSystem** ควรเป็น AutoLoad ด้วย
- **TimeManager** ควรเป็น AutoLoad ด้วย
- **QuestManager** ควรเป็น AutoLoad ด้วย
