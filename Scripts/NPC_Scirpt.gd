extends Obj_Main
class_name NPC

@onready var Dialogue_sprite :Sprite3D = $NPC_Dialog
@onready var Dialogue_text :RichTextLabel = $NPC_Dialog/SubViewport/Control/RichTextLabel
@onready var Anotation :Sprite3D = $NPC_UnknowTation
@onready var TalkingTime :Timer = $TalkingTimer
@export var Dialogue :Array[String] = [
	"AAA",
	"EEE",
	"OOO",
	"121313",
	"[wave amp=25 freq=5][color=green]6767676767676767676767
676767?[/color][/wave] or [shake rate=2e0.0 level=100 connected=0][color=red]69?[/color][/shake]"
]

var Dia :int = 0

func _ready() -> void:
	Dialogue_text.text = ""
	Dialogue_sprite.visible = false


func interact_event_in():
	print("OBJ: Detect!")
	Anotation.visible = true
	
func interact_event_out():
	print("OBJ: Out of length ")
	Anotation.visible = false

func interacting():
	Dia = 0
	show_dialogue()

	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.showbar()
		player.is_talking = true
		Anotation.visible = false
		player.talking_npc = self 
		Dialogue_sprite.visible = true

	
func interacting_cancle():
	pass

func end_dialogue():
	Anotation.visible = true
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.is_talking = false
		Dialogue_text.text = ""
		player.showbar()
	print("Dialogue ended")
	
	
func show_dialogue():
	if Dia < Dialogue.size():
		Dialogue_text.text = Dialogue[Dia]
		print("NPC:", Dialogue[Dia])
	else:
		end_dialogue()
		
func next_dialogue():
	Dia += 1
	show_dialogue()
