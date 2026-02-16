extends Node3D

@export var item_templates: Array[PackedScene] = []
@export var base_item_count: int = 2

func _ready() -> void:
	add_to_group("Item_Spawner_System")
	spawn_random_items()

func spawn_random_items():
	# ล้างไอเทมเก่า (ต้องใส่ Group "Items" ให้ Node หลักของไอเทมด้วย)
	for item in get_tree().get_nodes_in_group("Items"):
		item.queue_free()
		
	var markers = []
	for child in get_children():
		if child is Marker3D: markers.append(child)
	
	markers.shuffle()
	
	# จำนวนไอเทมเพิ่มตามวัน
	var count = base_item_count + PlayerData.current_day
	count = min(count, markers.size())

	for i in range(count):
		var item = item_templates.pick_random().instantiate()
		get_tree().current_scene.add_child.call_deferred(item)
		item.global_position = markers[i].global_position
