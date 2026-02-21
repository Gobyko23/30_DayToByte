extends SubViewportContainer # หรือ Control ถ้าคุณใช้แผงควบคุมหลัก

@export var target_path: NodePath
var target: Node3D
@onready var minimap_camera = %MiniCamera3D # เปลี่ยน Path ให้ตรงกับโครงสร้างของคุณ

func _ready():
	if target_path:
		target = get_node(target_path)

func _input(event):
	# เช็คว่ากดปุ่ม M (minimap) หรือไม่
	if event.is_action_pressed("MiniMap"):
		self.visible = !self.visible # สลับค่า true เป็น false หรือ false เป็น true
		print("🗺️ Minimap visibility: ", self.visible)

func _process(_delta):
	# ให้กล้อง Minimap เลื่อนตามตัวละคร (เฉพาะตอนที่เปิดแผนที่อยู่เพื่อประหยัดทรัพยากร)
	if self.visible and target and minimap_camera:
		minimap_camera.global_position.x = target.global_position.x
		minimap_camera.global_position.z = target.global_position.z
