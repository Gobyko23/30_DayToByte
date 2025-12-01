extends Camera3D
@export var target: Node3D       # โหนดที่กล้องจะตาม เช่น Player
@export var smooth_speed: float = 5.0
@export var offset: Vector3 = Vector3(0, 3, -6)   # ระยะกล้องจาก Player

func _process(delta):
	if target == null:
		return

	# ตำแหน่งกล้องที่ต้องการ
	var desired_pos = target.global_transform.origin + offset

	# เคลื่อนตำแหน่งแบบ Smooth
	global_transform.origin = global_transform.origin.lerp(desired_pos, delta * smooth_speed)

	# ให้กล้องมองไปที่ผู้เล่น
	look_at(target.global_transform.origin, Vector3.UP)
