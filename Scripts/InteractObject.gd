extends Node3D

@onready var Delete_time :Timer= $"../DestoryTime"
@onready var open_BOX :MeshInstance3D= $open_BOX
@onready var BOX :MeshInstance3D= $BOX
@onready var open_SFX :AudioStreamPlayer3D= $"../Open_SFX"
@onready var VFX :GPUParticles3D= $InteractParticles
func _ready():
	# ต่อสัญญาณให้ Timer
	Delete_time.timeout.connect(_on_destory_time_timeout)

func interact_event_in():
	print("OBJ: Body Find")
	
func interact_event_out():
	print("OBJ: Out of length 555555")

func interactable():
	BOX.visible = false 
	open_BOX.visible = true
	VFX.emitting = true
	open_SFX.play()
	Delete_time.start()
	

func _on_destory_time_timeout():
	queue_free()
