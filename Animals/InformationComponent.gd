extends Node2D

# Animal properties
@export var description = ""  # Description of the animal
@onready var animal_name = name  # The name which is assignable by the player

# Mate requirements
@export var requirement_item_1 : PackedScene
@export var requirement_item_2 : PackedScene

# Tracking variables
var requirement_1_met = false
var requirement_2_met = false
var mateable = false


# Initialization
func _ready():
	# Connect the eat signal from the animal node to this script.
	# Make sure the animal node's script emits the signal "animal_eat(item_name)"
#	self.connect("animal_eat", self, "_on_animal_eat")
	pass

func _on_animal_eat(item_name: String):
	# Update requirements based on the eaten item
	if item_name == requirement_item_1.name:
		requirement_1_met = true
	elif item_name == requirement_item_2.name:
		requirement_2_met = true

	# Check if both requirements are met
	update_mate_status()


func update_mate_status():
	# Determine if the animal is mateable
	if requirement_1_met and requirement_2_met:
		mateable = true
