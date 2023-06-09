extends MarginContainer
@export var item_display_template : PackedScene

@onready var grid_container : GridContainer = $GridContainer

var displays : Array = []   # Create an empty array
var player_inventory : Inventory

func _ready():
	var player : Player = get_tree().get_first_node_in_group("player")
	player_inventory = player.find_child("Inventory") as Inventory
	player_inventory.connect("item_count_changed", _on_player_inventory_item_count_changed)
	
func _on_player_inventory_item_count_changed(type : ResourceItem, new_count : int) -> void:
	var current_display : HotbarItemDisplay = null
	
	for display in displays:
		if(display.resource_type == type):
			current_display = display
			break
	
	if current_display != null:
		current_display.update_count(new_count)
	else:
		var new_display : HotbarItemDisplay = item_display_template.instantiate() as HotbarItemDisplay
		grid_container.add_child(new_display)
		new_display.resource_type = type
		new_display.update_count(new_count)
		displays.append(new_display)  
