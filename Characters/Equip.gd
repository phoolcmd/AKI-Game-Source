extends Sprite2D
	
func _on_player_shelby_item_equipped(item_name):
	if item_name == "wand blue":
		var new_texture = load("res://Art/Items/item_wand blue.png")
		texture = new_texture
		visible = true
