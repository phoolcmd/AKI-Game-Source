extends Panel
var default_tex = preload("res://Art/UI/hotbar_slot.png")

var default_style: StyleBoxTexture = null

var ItemClass = preload("res://Items/item.tscn")
var centerContainer : CenterContainer
var item = null

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	default_style = StyleBoxTexture.new()
	default_style.texture = default_tex
	centerContainer = CenterContainer.new()

	self.add_child(centerContainer)

		
	if randi() % 2 == 0:
		item = ItemClass.instantiate()
		#item.get_node("Sprite2D").frame = 2 # change the item sprite to the no shadow version
		centerContainer.add_child(item)
	refresh_style()
func refresh_style():
	if item == null:
		set('custom_style/panel', default_style)
	else:
		set('custom_style/panel', default_style) # change this to an alternative texture for items in a slot

func pickFromSlot():
	centerContainer.remove_child(item) # remove from centerContainer
	var inventoryNode = find_parent("Inventory")
	inventoryNode.add_child(item)  # add to Inventory node
	item = null
	refresh_style()  # update slot's appearance
	
func putIntoSlot(new_item):
	# Remove item from inventory node
	var inventoryNode = find_parent("Inventory")
	inventoryNode.remove_child(new_item)

	# Assign new_item to item and set its position to (0, 0)
	item = new_item
	item.position = Vector2(0 , 0)

	# Add item as a child to the centerContainer of the slot
	centerContainer.add_child(item)

	# Update the slot's appearance
	refresh_style()
