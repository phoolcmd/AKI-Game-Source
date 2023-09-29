extends CharacterBody2D

class_name Player

# Signals
signal item_equipped(item_name)
signal item_held(item_category)


# Exported Variables
@export var move_speed: float = 3000.0
@export var starting_direction: Vector2 = Vector2(0, 1)

# Player's Equipment Variables
@onready var equipped_item_name: String = ""
@onready var equipped_item_category: String = ""
@onready var equipped_item = $Equip/Area2D/CollisionShape2D
@onready var equipped_item_pos = equipped_item.global_position
@onready var equipped_item_tex = $Equip
@onready var movement_component = $MovementComponent
@onready var farming_component = $FarmingComponent
@onready var terrain_component = $TerrainComponent

# Other Node References
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var ui = get_node("/root/Main/Level/UserInterface")
@onready var grid_system = get_tree().get_root().get_node("Main/Level/TileMap")

# Variables
var canDash = true
var dashing
var inside_inv = false
var particle_instance = null
var enemy_position = Vector2.ZERO

func _ready():
	# Initialize starting animation and cursor
	movement_component.update_animation_parameters(starting_direction)

func _physics_process(delta):
	animation_tree.advance(delta * 0.2)
	movement_component.get_input(delta)
	move_and_slide()
	
	handle_item_actions(delta)

func _process(_delta):
	movement_component.pick_new_state()
	handle_item_equip()

func handle_item_actions(delta):
	# Hole Digging
	if equipped_item_name == "shovel":
		farming_component.dig_process(delta)
		grid_system.grid_placement_process()
		terrain_component.grass_placement_process()
		
	else:
		grid_system.hide_cursor()
	# Planting Seed
#	if equipped_item_category == "Seed":
#		farming_component.plant_process(delta, equipped_item_name)
#	else:
#		pass
		
	# Watering Plant
	if equipped_item_name == "watering can": #FUNCTIONALITY FOR PLANT WATERING IS CONTROLLED INSIDE PLANT_LOGIC SCRIPT
#		farming_component.water_process(delta)
		terrain_component.dirt_placement_process()
func handle_item_equip():
	# Check equipment and emit the appropriate signal
	if equipped_item_category == "Tool":
		emit_signal("item_equipped", equipped_item_name)
	else:
		emit_signal("item_held", equipped_item_category)
		emit_signal("item_equipped", equipped_item_name)

func unequip_item():
	equipped_item_name = ""
	equipped_item_category = ""
	# Any other necessary cleanup...

