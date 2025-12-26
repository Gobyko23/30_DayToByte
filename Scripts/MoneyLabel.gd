extends Node

@onready var money_label : Label = $"."


func _ready():
	CashSystem.money_changed.connect(_update_money)

func _update_money(amount:int):
	money_label.text = "%d $" % amount
