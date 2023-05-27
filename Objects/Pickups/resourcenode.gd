extends RigidBody2D

class_name ResourceNode

@export var starting_resources : int = 1

var current_resources : int

func _ready():
	current_resources = starting_resources
