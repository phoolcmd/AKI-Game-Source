extends Node

class_name Inventory

@export var resources : Dictionary = { }

signal item_count_changed(type : ResourceItem, new_count : int)

func add_resources(type : Resource, amount: int):
	if(resources.has(type)):
		resources[type] = resources[type] + amount
	else: 
		resources[type] = amount
	emit_signal("item_count_changed", type, resources[type])
