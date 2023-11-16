extends Sprite2D

@onready var player = get_node("/root/Main/Level/Player_Shelby")
var new_texture
@onready var default_cursor = %DefaultCursor
var collision_count = 0  # Counter for the number of bodies in collision
var collision_detected = false
var shader_material
var active_item_name #used in the signal to pass the items name
var active_item_category
@onready var cursor = $".."
func _ready():
	material.set_shader_parameter("modulate_color", Color(0.5, 1.0, 0.7, 0.5))
	player.item_held.connect(Callable(self, "_on_item_held"))

func _on_item_held(item_name, item_category):
	texture = null  # Default to null texture
	visible = false  # Default to invisible
	default_cursor.visible = true  # Default the cursor to visible
	active_item_name = item_name
	active_item_category = item_category
	if item_category in ["Consumable", "Seed"] and item_name and item_name != "":
		new_texture = load("res://Art/Items/item_" + item_name + ".png")
#		print(new_texture)
		if new_texture:
			texture = new_texture
			visible = true
			default_cursor.visible = false
			if not collision_detected:
				cursor.emit_signal("item_placeable", active_item_name, active_item_category)

func _on_collision_area_body_entered(body):
	print("collision")
	if body and not body.is_in_group("holes"):
		collision_count += 1
		if collision_count > 0:
			collision_detected = true
			material.set_shader_parameter("modulate_color", Color(1.0, 0.5, 0.5, 0.5))
	if body.is_in_group("holes"):
		collision_detected = false
		material.set_shader_parameter("modulate_color", Color(0.5, 1.0, 0.7, 0.5))

func _on_collision_area_body_exited(body):
	collision_count -= 1
	if collision_count <= 0:
		collision_count = 0
		collision_detected = false
		material.set_shader_parameter("modulate_color", Color(0.5, 1.0, 0.7, 0.5))
		if not collision_detected:
			cursor.emit_signal("item_placeable", active_item_name, active_item_category)
 
