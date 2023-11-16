extends Node2D

var target_pos = Vector2.ZERO
@onready var player = get_parent()
var item_cursor: Sprite2D
var placement_pos = null
var can_place = false # flag to determine if the player can place an item
@onready var grid_system = get_tree().get_root().get_node("Main/Level/TileMap")
@onready var cursor_scene = get_tree().get_root().get_node("Main/Level/TileMap/PlacementCursor")
@onready var canvas_layer = get_tree().get_root().get_node("Main/Level/Farm")
@onready var movement_component = $'../MovementComponent'
@onready var farming_component = $"../FarmingComponent"
var item 
var active_item_name
var path : String
func placement_process(delta):
	if target_pos:
#		print("moving to target")
		move_to_target(delta)
			
func _ready():
	cursor_scene.item_placeable.connect(Callable(self, "_on_item_placeable"))
#	cursor_scene.place

func _on_item_placeable(item_name, item_category):
	# If the item is not a consumable or seed, reset the target position
	active_item_name = item_name 
	if Input.is_action_just_released("left_click"):
		print(grid_system.cursor_spawn_pos)
		target_pos = grid_system.cursor_spawn_pos
	
		
func move_to_target(delta):
	# Exit early if no target set or if digging is in progress
	# If any movement keys are pressed, reset target position and exit
	var dir_to_target = (target_pos - global_position).normalized()
	player.velocity = dir_to_target * player.move_speed * delta
	movement_component.update_animation_parameters(dir_to_target)
	player.move_and_slide()
	
	if is_movement_key_pressed():
		target_pos = Vector2.ZERO
		return
	# If close enough to target, dig or remove item
	if is_close_to_target():
		print("Placing item")
		path = "res://Items/" + active_item_name + ".tscn"
		print(path)
		item = load(path)
		if !item: 
			return
		var item_instance = item.instantiate()
		print(target_pos)
		item_instance.global_position = target_pos
		canvas_layer.add_child(item_instance)
		target_pos = Vector2.ZERO
#		PlayerInventory.hotbar.remove_item()
		farming_component.emit_signal("player_placing", active_item_name) # Removes item from inventory
		
func is_close_to_target():
	return (global_position + Vector2(0, 16)).distance_to(target_pos) < 18

func is_movement_key_pressed():
	#Detects key input and resets target pos
	return Input.is_anything_pressed()
		
	

func _input(event):
	#Detects scrolling up and down and resets target pos
	if event.is_action_pressed("scroll_up"):
		target_pos = Vector2.ZERO
	elif event.is_action_pressed("scroll_down"):
		target_pos = Vector2.ZERO
	
