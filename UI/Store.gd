extends Control

@export var store_inventory = []
var itemPanelScene = preload("res://UI/store_item_panel.tscn")  # Preload your item panel scene
@onready var vbox = $"%VBoxContainer"

func _ready():
	print("Control node is ready.")
	print("Store inventory: ", store_inventory)
	populate_store()

func populate_store():
	for item_name in store_inventory:
		print(item_name)
		if JsonData.item_data.has(item_name):
			var item_panel = itemPanelScene.instantiate()
			var item_cost = JsonData.item_data[item_name].get("Cost", 10)  # Default cost to 10 if not specified
			item_panel.set_item(item_name, item_cost)
			vbox.add_child(item_panel)
