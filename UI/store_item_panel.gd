extends Panel

var item_description

func _ready():
	pass

func set_item(nm, cost):
	%ItemName.text = nm.to_lower()
	%ItemCost.text = str(cost)  # Ensure cost is converted to string
	
	var imagePath = "res://Art/Items/item_" + nm.to_lower() + ".png"
	if ResourceLoader.exists(imagePath):
		%ItemImage.texture = load(imagePath)
	else:
		print("Image not found:", imagePath)

	if JsonData.item_data.has(nm):
		item_description = JsonData.item_data[nm]["Description"]
	else:
		print("Item description not found for:", nm)

func _on_mouse_entered():
	# Change panel color when mouse over (semi-transparent)
	%Background.modulate = Color(0, 0, 0, 0.8)  # Alpha set to 0.8 for semi-transparency

func _on_mouse_exited():
	# Change panel color when mouse out (fully opaque)
	%Background.modulate = Color(0, 0, 0, 0.5)  # Alpha set to 0 for full opacity
