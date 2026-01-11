extends Node


var money:int = 0

signal money_changed(new_amount:int) #Create Signals



#Add Money
func add(amount:int) -> void:
	money += amount
	money_changed.emit(money)




#Use Money
func spend(amount:int) -> bool:
	if money < amount:
		return false

	money -= amount
	money_changed.emit(money)
	return true
	
	#Check Money
func has(amount:int) -> bool:
	return money >= amount


	#Set Money
func set_money(amount:int):
	print("DEBUG: set_money called with value: ", amount)
	money = max(0, amount)
	money_changed.emit(money)
