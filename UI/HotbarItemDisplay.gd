extends HFlowContainer

class_name HotbarItemDisplay

@onready var texture_rect : TextureRect = $TextureRect

@onready var label : Label = $Label

var resource_type : ResourceItem :
	set(new_type):
		resource_type = new_type
		texture_rect.texture = resource_type.texture

func update_count(count : int):
	label.text = str(count)
