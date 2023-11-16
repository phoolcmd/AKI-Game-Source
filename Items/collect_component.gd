extends Node2D

# Initialize onready and member variables
@onready var item : RigidBody2D = get_parent()
@onready var player = get_node("/root/Main/Level/Player_Shelby")
@onready var cursor_component : Node2D = $'../CursorComponent'

var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var max_speed = 500  # Max speed for the item in pixels per second
var acceleration = 2000  # Acceleration for the item in pixels per second squared
var player_pos = null
var collecting = false
@export var item_name : String #name this for item to be added correctly

# Called when the node enters the scene tree for the first time
#func _ready():
#	# Extract the item name by removing digits using regex
#	var regex = RegEx.new()
#	regex.compile("\\d+")
#	item_name = regex.sub(item.name, "", false)

# Called every physics frame (delta is the time since the last _physics_process call)
func _physics_process(delta):
	# If the item is being collected
	if collecting and InputEvent:
		print("Collecting items nearby wtf")
		# Calculate the normalized direction towards the player
		direction = (player_pos - item.global_position).normalized()
		# Move the item's velocity towards the desired direction * max_speed
		velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
		# Update item's position
		item.global_position += velocity * delta
		# Check if the item is close enough to the player
		if item.global_position.distance_to(player_pos) < 10:
			# Try to add the item to the inventory
			PlayerInventory.add_item(item_name, 1) #There is an issue with this code. if the player is in the area of two items and it attempts to add, the game crashes!
			# Remove the item from the scene
			item.queue_free()

# Called when the collect area receives an input event
func _on_collect_area_input_event(viewport, event, shape_idx):
	# Check if the left mouse button is pressed and the item is collectable
	if Input.is_action_just_pressed("left_click") and cursor_component.collectable:
		collecting = true  # Start the collection process
		player_pos = player.global_position  # Update the player's position
	if player.equipped_item_category == "Seed":
		pass

# Called when a body enters the collect area
func _on_collect_area_body_entered(body):
	# Update the player's position for use in the _physics_process function
	player_pos = player.global_position
