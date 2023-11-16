extends Sprite2D
class_name Hold
var item_name
var new_texture
func _on_player_shelby_item_held(item_name, item_category):
	texture = null  # Default to null texture
	visible = false  # Default to invisible
	
	if item_category in ["Consumable", "Seed"] and item_name and item_name != "":
		new_texture = load("res://Art/Items/item_" + item_name + ".png")
		if new_texture:
			texture = new_texture
			visible = false #Set to true to make visible
			
		

