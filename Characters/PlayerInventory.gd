extends Node

signal active_item_updated
signal item_quantity_updated

const SlotClass = preload("res://UI/Slot.gd")
const ItemClass = preload("res://Items/Item.gd")

const NUM_INVENTORY_SLOTS = 15
const NUM_HOTBAR_SLOTS = 6

@onready var player_node : Player = get_tree().get_first_node_in_group("player")
@onready var farm_component : Node2D = player_node.get_node("FarmingComponent")
var inventory = {
	0: ["mushroom", 97],
	1: ["rock", 11]
}

var hotbar = {
1: ["shovel", 1],
2: ["watering can", 1],
3: ["carrot seed", 99],

}

var active_item_slot = 0
func _ready():
	print(inventory)
#	player_node = get_tree().get_first_node_in_group("player")
#	player_node.player_planting.connect(Callable(self,"_on_player_planting"))
	farm_component.player_planting.connect(Callable(self,"_on_player_planting"))
func add_item(item_name, item_quantity):
	for item in hotbar:
		if hotbar[item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - hotbar[item][1]
			if able_to_add >= item_quantity:
				hotbar[item][1] += item_quantity
				update_slot_visual(item, hotbar[item][0], hotbar[item][1])
				return
			else:
				hotbar[item][1] += able_to_add
				update_slot_visual(item, hotbar[item][0], hotbar[item][1])
				item_quantity = item_quantity - able_to_add

			
	for i in range(NUM_HOTBAR_SLOTS):
		if hotbar.has(i) == false:
			hotbar[i] = [item_name, item_quantity]
			update_slot_visual(i, hotbar[i][0], hotbar[i][1])
			return
func update_slot_visual(slot_index, item_name, new_quantity):
	var slot = get_tree().root.get_node("/root/Main/Level/UserInterface/Hotbar/HotbarSlots/HotbarSlot" + str(slot_index + 1))
	if slot.item != null:
		slot.item.set_item(item_name, new_quantity)
	else:
		slot.initialize_item(item_name, new_quantity)
		
func add_item_to_empty_slot(item: ItemClass, slot: SlotClass, is_hotbar: bool = false):
	if is_hotbar:
		hotbar[slot.slot_index] = [item.item_name, item.item_quantity]
		print("res://Characters/PlayerInventory.gd\n----------HOTBAR----------")
		print("********Item Added to Empty Slot********")
		print(hotbar)
	else:
		inventory[slot.slot_index] = [item.item_name, item.item_quantity]
		print("res://Characters/PlayerInventory.gd\n----------INVENTORY----------")
		print("********Item Added to Empty Slot********")
		print(inventory)
func remove_item(slot: SlotClass, is_hotbar: bool = false):
	if is_hotbar:
		hotbar.erase(slot.slot_index)
		print("res://Characters/PlayerInventory.gd\n----------HOTBAR----------")
		print("********Item REMOVED from Slot********")
		print("is_hotbar = " + str(is_hotbar))
		print(hotbar)
	else:
		inventory.erase(slot.slot_index)
		print("res://Characters/PlayerInventory.gd\n----------INVENTORY----------")
		print("********Item REMOVED from Slot********")
		print("is_hotbar = " + str(is_hotbar))
		print(inventory)
func add_item_quantity(slot: SlotClass, quantity_to_add: int, is_hotbar: bool = false):
	if is_hotbar:
		hotbar[slot.slot_index][1] += quantity_to_add
		print("res://Characters/PlayerInventory.gd\n----------HOTBAR----------")
		print("********Item ADDED Quantity********")
		print(hotbar)
	else:
		print("res://Characters/PlayerInventory.gd\n----------INVENTORY----------")
		print("********Item ADDED Quantity********")
		print(hotbar)
		inventory[slot.slot_index][1] += quantity_to_add

func active_item_scroll_up():
	if active_item_slot == 0:
		active_item_slot = NUM_HOTBAR_SLOTS - 1
	else:
		active_item_slot -= 1
	emit_signal("active_item_updated")
	
	
func active_item_scroll_down():
	active_item_slot = (active_item_slot + 1) % NUM_HOTBAR_SLOTS
	emit_signal("active_item_updated")
func decrease_item_quantity(slot_index, quantity=1):
	if hotbar.has(slot_index):
		var item = hotbar[slot_index]
		item[1] -= quantity  # Decrease the quantity of the item

		if item[1] <= 0:  # If the quantity is 0 or less
			hotbar.erase(slot_index)  # Remove the item from the hotbar
			emit_signal("item_quantity_updated")
		else:
			hotbar[slot_index] = item  # Update the item in the hotbar
			emit_signal("item_quantity_updated")
##Adds items to the players inventory when this signal is caught from the farming component in player			
func _on_player_planting(item_name):
	print("res://Characters/PlayerInventory.gd : Planting: ", item_name)  # Print when the function is called
	if hotbar.has(active_item_slot) and hotbar[active_item_slot][0] == item_name:
		decrease_item_quantity(active_item_slot, 1)
		if hotbar.has(active_item_slot):
			update_slot_visual(active_item_slot, hotbar[active_item_slot][0], hotbar[active_item_slot][1])





	

		
