extends Node3D

@onready var DesTime :Timer = $DestoryTime
@onready var Box :MeshInstance3D = $BOX
@onready var OpenBox :MeshInstance3D = $open_BOX
@onready var OpenSfx :AudioStreamPlayer3D = $OpenSFX
@onready var OpenVFX :GPUParticles3D = $OpenPaticle
@onready var Interact_Anim :AnimationPlayer= $Interact_Anim
func interact_event_in():
	print("OBJ: Body Find")
	
func interact_event_out():
	print("OBJ: Out of length 555555")

func interacting():
	Interact_Anim.play("OpenBoxAnim")
	Interact_Anim.speed_scale = 1.2
	
func interacting_cancle():
	Interact_Anim.stop()


func interactable():
	DesTime.start()
	Box.visible = false
	OpenBox.visible = true
	get_node("HighlightMesh").queue_free()
	OpenSfx.play()
	OpenVFX.emitting = true
	
func _on_destory_time_timeout() -> void:
	queue_free()
