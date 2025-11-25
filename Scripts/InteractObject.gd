class_name InteractOBJ
extends Node3D

@export var Interact_Promp : String
@export var CanInteract : bool = true

func interact_event_in():
	print("OBJ: Body Find")
	
func interact_event_out():
	print("OBJ: Out of length")

func interactable():
	queue_free()
	
