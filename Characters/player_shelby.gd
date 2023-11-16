extends CharacterBody2D

class_name Player

# Signals
signal item_held(item_name, item_category)

# Exported Variables
@export var move_speed: float = 3000.0
@export var starting_direction: Vector2 = Vector2(0, 1)

# Player's Equipment Variables
@onready var equipped_item_name: String = ""
@onready var equipped_item_category: String = ""
@onready var movement_component = $MovementComponent
@onready var farming_component = $FarmingComponent
@onready var terrain_component = $TerrainComponent
@onready var place_component = $PlaceComponent

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
var player_pos = global_position
func _ready():
	movement_component.update_animation_parameters(starting_direction)

func _physics_process(delta):
	animation_tree.advance(delta * 0.2)
	movement_component.get_input(delta)
	move_and_slide()
	handle_item_actions(delta)

func _process(_delta):
	movement_component.pick_new_state()
	handle_item_held()

func handle_item_actions(delta):
	match equipped_item_name:
		"shovel":
			grid_system.grid_placement_process()
			farming_component.dig_process(delta)
		"watering can":
			grid_system.hide_cursor()
			#Water processing is currently handled inside the plant script "GrowComponent"
		"wand blue":
			grid_system.grid_placement_process()
			terrain_component.dirt_placement_process()
			terrain_component.grass_placement_process()	
			
			
		_:
			grid_system.hide_cursor()

	match equipped_item_category:
		"Seed":
			farming_component.plant_process(delta, equipped_item_name)
			grid_system.grid_placement_process()
			place_component.placement_process(delta)
		"Consumable":
			grid_system.grid_placement_process()
			place_component.placement_process(delta)
		_:
			pass

func handle_item_held():
	if equipped_item_category:
		emit_signal("item_held", equipped_item_name, equipped_item_category)

func unequip_item():
	equipped_item_name = ""
	equipped_item_category = ""
