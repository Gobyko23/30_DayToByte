extends Node3D
class_name Obj_Main

func interact_event_in():
	print("in")
	
func interact_event_out():
	print("out")

func interacting():
	print("Interacting")
	
func interacting_cancle():
	print("cancle")


func interactable() -> String:
	return "Success"
	
