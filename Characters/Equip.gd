extends Sprite2D

class_name Equip


@onready var hold : Hold = get_parent().get_node("Hold")

func _on_player_shelby_item_equipped(item_name):
	if item_name:
		var new_texture = load("res://Art/Items/item_" + item_name + ".png")
		texture = new_texture
		visible = true
		hold.visible = false
		

		
func _on_player_shelby_item_held(item_category):
	if item_category != "Tool":
		visible = false
		hold.visible = true

