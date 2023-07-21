extends Sprite2D


class_name Hold

@onready var equip : Equip = get_parent().get_node("Equip")


func _on_player_shelby_item_held(item_category):
	if item_category == "Seed":
		var new_texture = load("res://Art/Items/item_carrot seed.png")
		texture = new_texture
		visible = true
		equip.visible = false
		
	elif item_category == "Consumable":
		var new_texture = load("res://Art/Items/item_mushroom.png")
		texture = new_texture
		visible = true
		equip.visible = false
	
	elif item_category == "Resource":
		var new_texture = load("res://Art/Items/item_rock.png")
		texture = new_texture
		visible = true
		equip.visible = false
	
	else:
		visible = false
		equip.visible = false


func _on_player_shelby_item_equipped(item_name):
	if item_name == "":
		visible = false
