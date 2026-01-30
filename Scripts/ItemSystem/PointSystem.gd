extends Node


var points: int = 0

signal points_changed(new_amount: int)  # สัญญาณแจ้งเมื่อคะแนนเปลี่ยน


# เพิ่มคะแนน
func add(amount: int) -> void:
	points += amount
	points_changed.emit(points)
	print("➕ Points added: ", amount, " | Total: ", points)


# ใช้คะแนน
func spend(amount: int) -> bool:
	if points < amount:
		print("❌ Not enough points! Need: ", amount, " | Have: ", points)
		return false

	points -= amount
	points_changed.emit(points)
	print("➖ Points spent: ", amount, " | Remaining: ", points)
	return true


# ตรวจสอบคะแนนเพียงพอหรือไม่
func has(amount: int) -> bool:
	return points >= amount


# กำหนดคะแนน (ใช้เมื่อ Load Game)
func set_points(amount: int) -> void:
	print("🔧 Points set to: ", amount)
	points = max(0, amount)
	points_changed.emit(points)
