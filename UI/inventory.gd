extends Node2D

## Script responsible for handling the inventory system.
##
## The inventory system allows the user to pick up, place, and stack items in the inventory slots.
## It also allows for the swapping of different items and merging of the same items in a slot.
## The inventory system is a node2D that consists of a grid of slots and can hold an item.

const SlotClass = preload("res://UI/Slot.gd")
#@onready var player = get_node("res://Characters/player.tscn")
@onready var inventory_slots = $GridContainer


## Called when the node enters the scene tree, used for initialization.
##
## Connects the 'gui_input' signal from each inventory slot to the 'slot_gui_input' function in this script.
func _ready():
	#player.inside_inv = false
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		slots[i].gui_input.connect(slot_gui_input.bind(slots[i]))
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.INVENTORY
	initialize_inventory()
	print(PlayerInventory.inventory)
	
## Iterates through all inventory slots and adds the item
func initialize_inventory():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			slots[i].initialize_item(PlayerInventory.inventory[i][0], PlayerInventory.inventory[i][1])
## Handles user interaction with a slot.
##
## Arguments:
## - event: The input event.
## - slot: The slot that the user interacted with.
##
## This function is called whenever the user interacts with the slot. It handles logic
## for picking up items, placing items, and stacking items.
func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		print(PlayerInventory.inventory)
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
			if find_parent("UserInterface").holding_item != null:
				if !slot.item: 
					left_click_empty_slot(slot)
				else:
					if find_parent("UserInterface").holding_item.item_name != slot.item.item_name:
						left_click_different_item(event, slot)
					else: 
						left_click_same_item(slot)
			elif slot.item:
				left_click_not_holding(slot)

## Called whenever the player provides any input.
##
## This function continuously updates the holding item's position to follow the mouse, if there is a holding item.
func _input(event):
	if find_parent("UserInterface").holding_item:
		find_parent("UserInterface").holding_item.global_position = get_global_mouse_position()
		
func left_click_empty_slot(slot):
	PlayerInventory.add_item_to_empty_slot(find_parent("UserInterface").holding_item, slot)
	slot.putIntoSlot(find_parent("UserInterface").holding_item)
	find_parent("UserInterface").holding_item = null
	
func left_click_different_item(event: InputEvent, slot: SlotClass):
	print(PlayerInventory.inventory)
	PlayerInventory.remove_item(slot)
	PlayerInventory.add_item_to_empty_slot(find_parent("UserInterface").holding_item, slot)
	var temp_item = slot.item
	slot.pickFromSlot()
	temp_item.global_position = event.global_position
	slot.putIntoSlot(find_parent("UserInterface").holding_item)
	find_parent("UserInterface").holding_item = temp_item
	
func left_click_same_item(slot: SlotClass):
	var held_item_quantity = find_parent("UserInterface").holding_item.item_quantity
	var slot_item_quantity = slot.item.item_quantity

	var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
	var able_to_add = stack_size - slot_item_quantity

	if able_to_add >= held_item_quantity:
		PlayerInventory.add_item_quantity(slot, held_item_quantity)
		slot.item.add_item_quantity(held_item_quantity)
		find_parent("UserInterface").holding_item.queue_free()
		find_parent("UserInterface").holding_item = null
	else:
		PlayerInventory.add_item_quantity(slot, able_to_add)
		slot.item.add_item_quantity(able_to_add)
		find_parent("UserInterface").holding_item.decrease_item_quantity(able_to_add)
	
func left_click_not_holding(slot: SlotClass):
	PlayerInventory.remove_item(slot)
	find_parent("UserInterface").holding_item = slot.item
	slot.pickFromSlot()
	find_parent("UserInterface").holding_item.global_position = get_global_mouse_position()

