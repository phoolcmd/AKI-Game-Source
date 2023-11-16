extends Node2D
#This script handles the cursor interaction with the animal. it has a variable called interactable the controls when the player can access the information menu in informationcomponent

# Initialize onready and member variables
@onready var animal : CharacterBody2D = get_parent()
@onready var player = get_node("/root/Main/Level/Player_Shelby")
@onready var interact_area = $"../InteractArea"
@onready var interactable = false  # Flag to indicate if the animal is interactable
var mouse_over = false  # Flag to indicate if the mouse is over the animal

# Called when a body enters the collection area
func _on_interact_area_body_entered(body):
	if body.is_in_group("player"):  # Check if the entering body is the player
		update_interactable_status()
		update_cursor_shape()

# Called when a body exits the collection area
func _on_interact_area_body_exited(body):
	if body.is_in_group("player"):  # Check if the exiting body is the player
		update_interactable_status()
		update_cursor_shape()

# Called when the mouse enters the animal's mouse area
func _on_mouse_area_mouse_entered():
	mouse_over = true  # Set the mouse_over flag to true
	update_interactable_status()
	update_cursor_shape()

# Called when the mouse exits the animal's mouse area
func _on_mouse_area_mouse_exited():
	mouse_over = false  # Reset the mouse_over flag
	update_interactable_status()
	update_cursor_shape()

# Helper function to update the interactable status
func update_interactable_status():
	# Check if the player is in the collect area and the mouse is over the animal
	interactable = mouse_over && is_player_in_collect_area()

# Helper function to check if the player is in the collect area
func is_player_in_collect_area() -> bool:
	# Assuming you have a collision shape or area for the collection area
	return interact_area.overlaps_body(player)

# Helper function to update the cursor shape based on current status
func update_cursor_shape():
	if interactable:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
