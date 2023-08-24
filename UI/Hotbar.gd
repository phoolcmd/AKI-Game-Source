extends Control

class_name Hotbar

const SlotClass = preload("res://UI/Slot.gd")
@onready var hotbar = $HotbarSlots
@onready var active_item_label = $ActiveItemLabel
@onready var slots = hotbar.get_children()
@onready var player : Player = get_tree().get_first_node_in_group("player")
var active_item_category = ""
func _ready():
	PlayerInventory.active_item_updated.connect(Callable(self, "update_active_item_label"))
	PlayerInventory.item_quantity_updated.connect(Callable(self, "update_hotbar_visual")) #Check if holding item quantity updated
	for i in range(slots.size()):
		PlayerInventory.active_item_updated.connect(Callable(slots[i], "refresh_style"))
		slots[i].gui_input.connect(slot_gui_input.bind(slots[i]))	
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.HOTBAR
	initialize_inventory()
	update_active_item_label()
	
func update_hotbar_visual():
	for i in range(slots.size()):
		if PlayerInventory.hotbar.has(i):
			slots[i].initialize_item(PlayerInventory.hotbar[i][0], PlayerInventory.hotbar[i][1])
		else:
			if slots[i].item:  # Check if there is an item in the slot
				PlayerInventory.remove_item(slots[i], true)
				slots[i].pickFromSlot()  # This should remove the item visually from the slot
				player.unequip_item()
	
func update_active_item_label():
	if slots[PlayerInventory.active_item_slot].item != null:
		active_item_label.text = slots[PlayerInventory.active_item_slot].item.item_name
		player.equipped_item_name = active_item_label.text
		active_item_category = slots[PlayerInventory.active_item_slot].item.item_category
		player.equipped_item_category = active_item_category
		print("res://UI/Hotbar.gd : ", active_item_category)
	else:
		active_item_label.text = ""
		player.equipped_item_name = ""
		active_item_category = ""
		print("res://UI/Hotbar.gd : No Active Item Held")
		

	
func initialize_inventory():
	for i in range(slots.size()):
		if PlayerInventory.hotbar.has(i):
			slots[i].initialize_item(PlayerInventory.hotbar[i][0], PlayerInventory.hotbar[i][1])
			update_active_item_label()
			

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
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
			update_active_item_label()
				
func left_click_empty_slot(slot):
	PlayerInventory.add_item_to_empty_slot(find_parent("UserInterface").holding_item, slot, true)
	slot.putIntoSlot(find_parent("UserInterface").holding_item)
	find_parent("UserInterface").holding_item = null
	
func left_click_different_item(event: InputEvent, slot: SlotClass):
	PlayerInventory.remove_item(slot, true)
	PlayerInventory.add_item_to_empty_slot(find_parent("UserInterface").holding_item, slot, true)
	var temp_item = slot.item
	slot.pickFromSlot()
	temp_item.global_position = event.global_position
	slot.putIntoSlot(find_parent("UserInterface").holding_item)
	find_parent("UserInterface").holding_item = temp_item
	
func left_click_same_item(slot: SlotClass):
	var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
	var able_to_add = stack_size - slot.item.item_quantity
	if able_to_add >= find_parent("UserInterface").holding_item.item_quantity:
		PlayerInventory.add_item_quantity(slot, find_parent("UserInterface").holding_item.item_quantity, true)
		slot.item.add_item_quantity(find_parent("UserInterface").holding_item.item_quantity)
		find_parent("UserInterface").holding_item.queue_free()
		find_parent("UserInterface").holding_item = null
	else:
		PlayerInventory.add_item_quantity(slot, able_to_add, true)
		slot.item.add_item_quantity(able_to_add)
		find_parent("UserInterface").holding_item.decrease_item_quantity(able_to_add)
	
func left_click_not_holding(slot: SlotClass):
	PlayerInventory.remove_item(slot, true)
	find_parent("UserInterface").holding_item = slot.item
	slot.pickFromSlot()
	find_parent("UserInterface").holding_item.global_position = get_global_mouse_position()
