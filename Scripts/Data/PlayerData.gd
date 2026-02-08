extends Node


var position := Vector3.ZERO
var Name := "Gobyko"
var GlobalSaveSlot := 1
var current_day := 0

func reset_system():
    current_day = 0 # หรือ 0 ตามที่คุณต้องการเริ่มต้น
    # ถ้ามีตัวแปรอื่นๆ เช่น ชื่อผู้เล่น หรือ Slot ก็รีเซ็ตที่นี่
    print("🔄 PlayerData has been reset")