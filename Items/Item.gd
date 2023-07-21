extends Node2D

var item_name
var item_quantity
var item_category
var item_description

##USED FOR MODIFYING VARIABLES FROM JSON DATA
 # - update any item information from here

func add_item_quantity(amount_to_add):
	item_quantity += amount_to_add
	$Label.text = str(item_quantity)
	
func decrease_item_quantity(amount_to_remove):
	item_quantity -= amount_to_remove
	$Label.text = str(item_quantity)
		
func set_item(nm, qt):
	item_name = nm.to_lower()
	item_quantity = qt
	
	$TextureRect.texture = load("res://Art/Items/item_" + item_name + ".png")
	
	var stack_size = int(JsonData.item_data[item_name]["StackSize"])
	item_category = JsonData.item_data[item_name]["ItemCategory"];
	item_description = JsonData.item_data[item_name]["Description"]
	if stack_size == 1:
		$Label.visible = false
	else:
		$Label.visible = true
		$Label.text = str(item_quantity)
