extends Node2D

# Initialize onready and member variables
@onready var item : RigidBody2D = get_parent()
@onready var player = get_node("/root/Main/Level/Player_Shelby")

var cursor_grab = load("res://Art/Items/item_carrot.png")  # Load cursor image for grabbing
var collectable = false  # Flag to indicate if the item is collectable
var mouse_over = false  # Flag to indicate if the mouse is over the item

# Called when a body enters the collection area
func _on_collect_area_body_entered(body):
	if body.is_in_group("player"):  # Check if the entering body is the player
		collectable = true  # Set the item to be collectable
		if mouse_over:  # If the mouse is over the item
			# Change the cursor to a pointing hand
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

# Called when a body exits the collection area
func _on_collect_area_body_exited(body):
	if body.is_in_group("player"):  # Check if the exiting body is the player
		collectable = false  # Set the item to not be collectable
		if mouse_over:  # If the mouse is still over the item
			# Change the cursor back to an arrow
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

# Called when the mouse enters the item's mouse area
func _on_mouse_area_mouse_entered():
	mouse_over = true  # Set the mouse_over flag to true
	# Check if the item is collectable
	if collectable:
		# Change the cursor to a pointing hand
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		# If not collectable, change cursor back to an arrow
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

# Called when the mouse exits the item's mouse area
func _on_mouse_area_mouse_exited():
	mouse_over = false  # Reset the mouse_over flag
	# Change the cursor back to an arrow
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
