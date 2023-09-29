extends Node2D
#RENAME THIS TO DROPCOMPONENT INSTEAD OF PICKUP	
@onready var grow_component : Node = $'../GrowComponent'

@onready var sprite : Sprite2D = $'../Sprite2D'

@onready var plant = get_parent()

@onready var canvas_layer = get_tree().get_root().get_node("Main/Level/Farm")

var item_instance = null
var mouse_over = false

func _process(delta):
	
	#Collect item and add to inventory		
	if grow_component.finished_growing and mouse_over: # Replace with your own growth condition
		# Check if the player is already inside the plant's detection area
		var detection_area = $'../DetectionArea' # Assuming the detection area node is named "DetectionArea"
		for body in detection_area.get_overlapping_bodies():
			if body.is_in_group("player"): # Assuming the player is in a group named "player"
				sprite.material.set_shader_parameter("line_scale", 1.0) # Assuming the plant script has a public 'sprite' variable
				if Input.is_action_just_pressed("left_click") and grow_component.finished_growing:
					#Instantiate item drop
					print(grow_component.item_drop)
					
					var item_drop = load("res://Items/" + grow_component.item_drop + ".tscn")
					item_instance = item_drop.instantiate()
					canvas_layer.add_child(item_instance)
					item_instance.position = plant.position
					
					#Start drop animation
					
					#Free queue
					plant.queue_free()

					

func _on_mouse_area_mouse_entered():
	mouse_over = true


func _on_mouse_area_mouse_exited():
	mouse_over = false
