extends Node3D

@onready var DesTime :Timer = $DestoryTime
@onready var Box :MeshInstance3D = $BOX
@onready var OpenBox :MeshInstance3D = $open_BOX
@onready var OpenSfx :AudioStreamPlayer3D = $OpenSFX
@onready var OpenVFX :GPUParticles3D = $OpenPaticle
@onready var Interact_Anim :AnimationPlayer= $Interact_Anim

func interact_event_in():
	print("OBJ: Detect!")
	
func interact_event_out():
	print("OBJ: Out of length 555555")

func interacting():
	Interact_Anim.play("OpenBoxAnim")
	Interact_Anim.speed_scale = 1.2
	
func interacting_cancle():
	Interact_Anim.stop()


func interactable() -> String:
	var Objfound = _random_obj()
	DesTime.start()
	Box.visible = false
	OpenBox.visible = true
	get_node("HighlightMesh").queue_free()
	OpenSfx.play()
	OpenVFX.emitting = true
	
	return Objfound
	
func _random_obj():
	# สร้างพจนานุกรมที่เก็บชื่อ -> น้ำหนัก (weight)
	var table = {
		"White": 50,
		"Red": 15,
		"Yellow": 25,
		"Green": 10,
		'RainBow': 1
	}

	# หาผลรวมของน้ำหนักทั้งหมด
	var total_weight = 0
	for w in table.values():
		total_weight += w

	# สุ่มค่าแบบตัวเลข 0 .. total_weight-1
	var rnd = randi() % total_weight

	# ไล่สะสมค่าน้ำหนักทีละคีย์
	var cumulative = 0
	for key in table.keys():
		cumulative += table[key]
		# ถ้าค่า rnd น้อยกว่า cumulative แปลว่า key นี้ถูกเลือก
		if rnd < cumulative:
			return str(key)  # คืนชื่อที่สุ่มได้
func _on_destory_time_timeout() -> void:
	queue_free()
