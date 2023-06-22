extends Node2D

## Script responsible for handling the inventory system.
##
## The inventory system allows the user to pick up, place, and stack items in the inventory slots.
## It also allows for the swapping of different items and merging of the same items in a slot.
## The inventory system is a node2D that consists of a grid of slots and can hold an item.

const SlotClass = preload("res://UI/Slot.gd")
@onready var inventory_slots = $GridContainer
var holding_item = null

## Called when the node enters the scene tree, used for initialization.
##
## Connects the 'gui_input' signal from each inventory slot to the 'slot_gui_input' function in this script.
func _ready():
	for inv_slot in inventory_slots.get_children():
		inv_slot.gui_input.connect(slot_gui_input.bind(inv_slot))

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
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
			if holding_item != null:
				if !slot.item: 
					slot.putIntoSlot(holding_item)
					holding_item = null
				else:
					if holding_item.item_name != slot.item.item_name:
						var temp_item = slot.item
						slot.pickFromSlot()
						temp_item.global_position = event.global_position
						slot.putIntoSlot(holding_item)
						holding_item = temp_item
					else: 
						var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
						var able_to_add = stack_size - slot.item.item_quantity
						if able_to_add >= holding_item.item_quantity:
							slot.item.add_item_quantity(holding_item.item_quantity)
							holding_item.queue_free()
							holding_item = null
						else:
							slot.item.add_item_quantity(able_to_add)
							holding_item.decrease_item_quantity(able_to_add)
			elif slot.item:
				holding_item = slot.item
				slot.pickFromSlot()
				holding_item.global_position = get_global_mouse_position()

## Called whenever the player provides any input.
##
## This function continuously updates the holding item's position to follow the mouse, if there is a holding item.
func _input(event):
	if holding_item:
		holding_item.global_position = get_global_mouse_position()
