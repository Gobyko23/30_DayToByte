extends Node3D

@export_group("Settings")
@export var npc_templates: Array[PackedScene] = [] 
@export var max_npc_per_day: int = 3 
@export var min_count: int = 3
var spawn_markers: Array[Marker3D] = []

func _ready() -> void:
	# 1. จัดการเรื่องกลุ่ม
	if not is_in_group("NPC_Spawner_System"):
		add_to_group("NPC_Spawner_System")
	
	# 2. เก็บตำแหน่ง Marker ทั้งหมด
	spawn_markers.clear()
	for child in get_children():
		if child is Marker3D:
			spawn_markers.append(child)
	
	# 3. 🔥 สั่งสปอว์นทันทีที่โหลด Scene (รองรับ Day 0 / วันแรก)
	# ใช้ call_deferred เพื่อรอให้ทุก Node ในฉากพร้อมก่อน
	spawn_random_npcs.call_deferred()

func spawn_random_npcs(_day: int = 1) -> void:
	_clear_old_npcs()
	
	if npc_templates.is_empty() or spawn_markers.is_empty():
		return

	# 1. ดึงค่าวันปัจจุบันจาก PlayerData (สมมติเริ่มที่ day 0)
	var current_day = PlayerData.current_day
	
	# 2. คำนวณจำนวน NPC ตามวัน 
	# เช่น วันที่ 0 เกิด 1-2 ตัว, วันที่ 1 เกิด 2-3 ตัว
	var calculated_min = 1 + current_day
	var calculated_max = max_npc_per_day + current_day
	
	# 3. สุ่มจำนวนโดยอิงจากค่าที่คำนวณมา (ไม่ให้เกินจำนวน Marker ที่มี)
	var limit = min(calculated_max, spawn_markers.size())
	var amount_to_spawn = randi_range(calculated_min, limit)
	
	print("📅 Day: ", current_day, " | Spawning: ", amount_to_spawn, " NPCs")

	var available_markers = spawn_markers.duplicate()
	available_markers.shuffle()
	
	for i in range(amount_to_spawn):
		if available_markers.is_empty(): break
		var marker = available_markers.pop_back()
		var npc_instance = npc_templates.pick_random().instantiate()
		get_tree().current_scene.add_child(npc_instance)
		npc_instance.global_position = marker.global_position
		npc_instance.global_rotation = marker.global_rotation


func _clear_old_npcs() -> void:
	var current_npcs = get_tree().get_nodes_in_group("Npc")
	for npc in current_npcs:
		npc.queue_free()