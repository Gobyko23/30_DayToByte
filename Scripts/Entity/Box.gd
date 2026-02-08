extends Obj_Main
class_name Obj_Box
@onready var DesTime :Timer = $DestoryTime
@onready var Box :MeshInstance3D = $BOX
@onready var OpenBox :MeshInstance3D = $open_BOX
@onready var OpenSfx :AudioStreamPlayer3D = $OpenSFX
@onready var OpenVFX :GPUParticles3D = $OpenPaticle
@onready var Interact_Anim :AnimationPlayer= $Interact_Anim

func interact_event_in():
	print("OBJ: Detect!")
	
func interact_event_out():
	print("OBJ: Out of length ")
#------------------------------------------------------------------------
#กำลัง interact 
func interacting():
	Interact_Anim.play("OpenBoxAnim")
	Interact_Anim.speed_scale = 1.2
#------------------------------------------------------------------------
func interacting_cancle():
	Interact_Anim.stop()

#------------------------------------------------------------------------
#interact เสร็จแล้ว
func interactable() -> String:
	var Objfound = InventorySystem.random_obj()
	print("Drop :", Objfound)
	QuestManager.add_progress("box", 1)
	InventorySystem.update_item(Objfound, 1)
	DesTime.start()
	Box.visible = false
	OpenBox.visible = true
	get_node("HighlightMesh").queue_free()
	OpenSfx.play()
	OpenVFX.emitting = true
	PointSystem.add(50)
	return Objfound
#------------------------------------------------------------------------

func _on_destory_time_timeout() -> void:
	queue_free()
#------------------------------------------------------------------------
