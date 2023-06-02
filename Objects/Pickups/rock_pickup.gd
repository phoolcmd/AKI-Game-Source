extends RigidBody2D

class_name Pickup

@export var resource_type : Resource
var picking_up : bool = false

func _ready():
	pass
	
func _process(delta):
	if(Input.is_action_just_pressed("interact")):
		picking_up = true

func _on_area_2d_body_entered(body):
	var inventory = body.find_child("Inventory")
	if(inventory and picking_up):
		inventory.add_resources(resource_type, 1)
		print("rock added to inventory")
