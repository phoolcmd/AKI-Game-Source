extends Panel

var default_tex = preload("res://Art/UI/hotbar_slot.png")
var selected_tex = preload("res://Art/UI/hotbar_slot_selected.png")
var selected_empty_tex = preload("res://Art/UI/hotbar_slot_selected_empty.png")
var filled_tex = preload("res://Art/UI/hotbar_slot_filled.png")
var default_style: StyleBoxTexture = null
var selected_style: StyleBoxTexture = null
var selected_empty_style: StyleBoxTexture = null
var filled_style :  StyleBoxTexture = null

var ItemClass = preload("res://Items/item.tscn")
var item = null
var slot_index = null
var slot_type

enum SlotType {
	HOTBAR = 0,
	INVENTORY,
}

func _ready():
	default_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	selected_empty_style = StyleBoxTexture.new()
	filled_style = StyleBoxTexture.new()
	default_style.texture = default_tex
	selected_style.texture = selected_tex
	selected_empty_style.texture = selected_tex
	filled_style.texture = filled_tex

	#PlayerInventory.active_item_updated.connect(Callable(self,"refresh_style"))

	refresh_style()

func refresh_style():
	if SlotType.HOTBAR == slot_type and PlayerInventory.active_item_slot == slot_index:
		if item == null:
			selected_empty_style.texture = selected_empty_tex
			set('theme_override_styles/panel', selected_empty_style)
			print("change my damn style")
		else:
			selected_style.texture = selected_tex
			set('theme_override_styles/panel', selected_style)
			print("change my damn style")
		
	elif item == null:
		default_style.texture = default_tex
		set('theme_override_styles/panel', default_style)
		
	else:
		filled_style.texture = filled_tex
		set('theme_override_styles/panel', filled_style) 

func pickFromSlot():
	if item != null:
		remove_child(item) # remove from Panel node
		var inventoryNode = find_parent("UserInterface")
		inventoryNode.add_child(item)  # add to Inventory node
		item = null
		refresh_style()  # update slot's appearance

func putIntoSlot(new_item):
	# Remove item from inventory node
	var inventoryNode = find_parent("UserInterface")
	inventoryNode.remove_child(new_item)

	# Assign new_item to item and set its position to (0, 0)
	item = new_item
	item.position = Vector2(0 , 0)

	# Add item as a child to the Panel node itself
	add_child(item)

	# Update the slot's appearance
	refresh_style()

func initialize_item(item_name, item_quantity):
	if item == null:
		item = ItemClass.instantiate()
		add_child(item)
		item.set_item(item_name, item_quantity)
	else:
		item.set_item(item_name, item_quantity)

	refresh_style()
