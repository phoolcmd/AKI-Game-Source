extends Node2D

@onready var player = get_parent()
@onready var scan_zone = $scan_zone  # assuming 'scan_zone' is a direct child of this Node2D
@export var water_meter = preload("res://UI/water_meter.tscn")

var water_meter_instance = null
var plants_inside = []

# Define a maximum distance for a valid mouse-over or mouse-click
const MAX_MOUSE_DISTANCE = 5.0  # in pixels, you can adjust this value

func _ready():
	water_meter_instance = water_meter.instantiate()
	add_child(water_meter_instance)

func _process(delta):
	if player.equipped_item_name == "wand purple":
		water_process(delta)

func water_process(delta):
	var player_pos = player.position
	var dig_pos = get_global_mouse_position()
	var mouse_distance = dig_pos.distance_to(player_pos)
	water_meter_instance.global_position = dig_pos

func _input(event):
	var mouse_pos = get_global_mouse_position()
	var is_mouse_over_any_plant = false

	for plant in plants_inside:
		if plant.position.distance_to(mouse_pos) <= MAX_MOUSE_DISTANCE:
			is_mouse_over_any_plant = true
			plant.get_node("Sprite2D").material.set_shader_parameter("line_scale", 1.0)
			water_meter_instance.visible = true
			if event is InputEventMouseButton and event.pressed:
				print("Mouse clicked on plant:", plant.name)
		else:
			plant.get_node("Sprite2D").material.set_shader_parameter("line_scale", 0.0)
			water_meter_instance.visible = false

	# You can also handle other mouse inputs outside of the loop, if needed
	if event is InputEventMouseMotion and is_mouse_over_any_plant:
		print("Mouse over a plant")

func _on_scan_zone_body_entered(body):
	if body.is_in_group("plants"):
		print("Plant nearby!!!!")
		plants_inside.append(body)

func _on_scan_zone_body_exited(body):
	if body in plants_inside:
		plants_inside.erase(body)
