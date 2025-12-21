extends Obj_Main
class_name NPC

@onready var Dialogue :Sprite3D = $NPC_Dialog
@onready var Anotation :Sprite3D = $NPC_UnknowTation
@onready var TalkingTime :Timer = $TalkingTimer

func interact_event_in():
	print("OBJ: Detect!")
	Anotation.visible = true
	
func interact_event_out():
	print("OBJ: Out of length ")
	Anotation.visible = false

func interacting():
	super()
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.cancel_interact() 
		player.is_talking = true
		Anotation.visible = false
	
func interacting_cancle():
	pass

func end_dialogue():
	Anotation.visible = true
	print("Timer started: ", TalkingTime.is_stopped() == false)
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.is_talking = false
		
'''
func interactable(Count = null) -> String:
	var Dialogue :Array= ["AAA","EEE","OOO","121313"]

	return Dialogue[Dia]
'''	
