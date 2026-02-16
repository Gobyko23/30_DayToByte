extends Camera3D

@export var target: Node3D              # Player
@export var smooth_speed: float = 5.0
@export var offset: Vector3 = Vector3(0, 3, -6)
@export var mouse_look_strength := 5     # ความแรงการขยับ
@export var mouse_return_speed := 1.5      # ความเร็วกลับศูนย์
@export var mouse_limit := Vector2(20, 20)   # จำกัดองศา (x = yaw, y = pitch)
@export var normal_fov: float = 75.0
@export var dialog_fov: float = 50.0
@export var fov_speed: float = 5.0
@export var Dialogoffset :Vector3= Vector3(0, 1, 3)

var mouse_offset := Vector2.ZERO


var focus_target: Node3D = null          # NPC ที่กำลังคุย
var is_talking := false

# เพิ่มตัวแปรและฟังก์ชันใน player_camera.gd
var is_custom_view := false
var custom_offset := Vector3.ZERO
var custom_look_target: Node3D = null

func set_custom_view(new_offset: Vector3):
	is_custom_view = true
	custom_offset = new_offset
	custom_look_target = target

func reset_view():
	is_custom_view = false
	is_talking = false # คืนค่าสถานะคุยด้วย

func focus_on(npc: Node3D):
	is_talking = true
	focus_target = npc

func release_focus():
	is_talking = false
	focus_target = null

func _input(event):
	if not is_talking:
		return

	if event is InputEventMouseMotion:
		mouse_offset.x += event.relative.x * 0.01 * mouse_look_strength
		mouse_offset.y -= event.relative.y * 0.01 * mouse_look_strength

		mouse_offset.x = clamp(mouse_offset.x, -mouse_limit.x, mouse_limit.x)
		mouse_offset.y = clamp(mouse_offset.y, -mouse_limit.y, mouse_limit.y)


func _process(delta):
	if target == null:
		return

	var look_target: Node3D
	var desired_pos: Vector3

	if is_talking and focus_target:
		# 🔴 ตอนคุย → โฟกัส NPC
		
		look_target = focus_target
		desired_pos = focus_target.global_position + Dialogoffset
		
		# 🎥 FOV ตอนคุย
		fov = lerp(fov, dialog_fov, delta * fov_speed)
		
			# ===== 👇 โค้ดที่คุณถาม ต้องอยู่ตรงนี้ =====
		# ทิศทางพื้นฐานไปที่ NPC
		var base_dir = (look_target.global_position - global_position).normalized()
		var base_basis = Basis.looking_at(base_dir, Vector3.UP)
		# yaw (ซ้าย-ขวา) รอบแกนโลก
		var yaw_basis = Basis(Vector3.UP, deg_to_rad(-mouse_offset.x))
	# pitch (ขึ้น-ลง) รอบแกนขวาของกล้อง (local)
		var right_axis = base_basis.x
		var pitch_basis = Basis(right_axis, deg_to_rad(-mouse_offset.y))

		# รวม rotation (ลำดับสำคัญมาก)
		var final_basis = yaw_basis * pitch_basis * base_basis

		global_basis = global_basis.slerp(
			final_basis,
			delta * smooth_speed
		)
		# ===== 👆 จบตรงนี้ =====
	elif is_custom_view:
		# 🔥 โหมดพื้นที่พิเศษ (Trigger)
		look_target = custom_look_target
		desired_pos = custom_look_target.global_position + custom_offset	
	else:
		# 🟢 ปกติ → ตาม Player
		look_target = target
		desired_pos = target.global_position + offset
		
		# 🎥 FOV ปกติ
		fov = lerp(fov, normal_fov, delta * fov_speed)

	# Smooth move
	global_position = global_position.lerp(
		desired_pos,
		delta * smooth_speed
	)

	# Smooth look (ดีกว่า look_at ตรง ๆ)
	var dir = (look_target.global_position - global_position).normalized()
	var target_basis = Basis.looking_at(dir, Vector3.UP)
	global_basis = global_basis.slerp(target_basis, delta * smooth_speed)
