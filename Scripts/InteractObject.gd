extends Node3D

@onready var DesTime :Timer= $DestoryTime

func interact_event_in():
	print("OBJ: Body Find")
	
func interact_event_out():
	print("OBJ: Out of length 555555")

func interactable():
	queue_free()
	print("Got it!")
	
