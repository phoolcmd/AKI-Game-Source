extends Node2D
signal player_planting(item_name)

# Preloaded Assets
@export var hole = preload("res://Objects/Farming/hole.tscn")

@export var plant_radius : float = 30
@export var dig_radius : float = 100

@onready var player = get_parent()
@onready var dig_timer = $'../DigTimer'
@onready var movement_component = $'../MovementComponent'
@onready var canvas_layer = get_tree().get_root().get_node("Main/Level/Farm")
@onready var grid_system = get_tree().get_root().get_node("Main/Level/TileMap")

var target_pos = Vector2.ZERO
var hole_to_remove = null
var hole_radius = 10
var placeable = true

var plants_inside = []

	
func dig_process(delta):
	
	var player_pos = player.position
	var dig_pos = null
	if grid_system and grid_system.cursor_spawn_pos:
		dig_pos = Vector2(grid_system.cursor_spawn_pos.x, grid_system.cursor_spawn_pos.y)
	else:
		print("grid_system or cursor_spawn_pos is not initialized")
		return  # Early exit from the function
		
	var mouse_distance = dig_pos.distance_to(player_pos)
	var holes = get_tree().get_nodes_in_group("holes")
	
	# Determine target position before looping through holes
	if mouse_distance < dig_radius and dig_timer.is_stopped() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var can_place_hole = true
		#Calculate mouse distance to nearest hole
		for hole in holes:
			#If distance is less than 10 you cannot place a hole
			if dig_pos.distance_to(hole.global_position) < 10:
				can_place_hole = false
				break
		#Calculate mouse distance to nearest node in group named "items"
		for group in get_groups():
			if group == "items":
				var node = get_node("")
		if grid_system.cursor_instance.collision_detected == false:
			target_pos = dig_pos
			
	move_to_target(delta)
	# Find the closest hole
	var closest_hole = null
	var closest_distance = INF
	for hole in holes: 
		var distance_to_hole = dig_pos.distance_to(hole.global_position)
		if distance_to_hole < 10 and (closest_hole == null or distance_to_hole < closest_distance) and mouse_distance < dig_radius:
			closest_hole = hole
			closest_distance = distance_to_hole
			# Apply outline shader to nearest hole
			hole.get_node("Sprite2D").material.set_shader_parameter("line_scale", 1.0)
		else:
			hole.get_node("Sprite2D").material.set_shader_parameter("line_scale", 0.0)
	
	#Remove hole if player right clicks on a hole and is within dig radius	
	if closest_hole != null and mouse_distance < dig_radius and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and dig_timer.is_stopped():
		hole_to_remove = closest_hole
		target_pos = closest_hole.global_position
func plant_process(delta, item_name):	
	
	var player_pos = player.position
	var plant_pos = get_global_mouse_position()
	var mouse_distance = plant_pos.distance_to(player_pos)
	var plant_target_pos = Vector2.ZERO
	var plant_instance = null
	
	var holes = get_tree().get_nodes_in_group("holes")
	# Find the closest holeada
	var closest_hole = null
	var closest_distance = INF
	for hole in holes: 
		var distance_to_hole = plant_pos.distance_to(hole.global_position)
		if distance_to_hole < 10 and (closest_hole == null or distance_to_hole < closest_distance) and mouse_distance < plant_radius:
			closest_hole = hole
			closest_distance = distance_to_hole
			# Apply outline shader to nearest hole
			hole.get_node("Sprite2D").material.set_shader_parameter("line_scale", 1.0)
		else:
			hole.get_node("Sprite2D").material.set_shader_parameter("line_scale", 0.0)
	if closest_hole != null and mouse_distance < plant_radius and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and dig_timer.is_stopped():
		hole_to_remove = closest_hole
		plant_target_pos = closest_hole.global_position
		emit_signal("player_planting", player.equipped_item_name)
		var plant_name = item_name.split(" ")[0]
		var plant_name_path = "res://Objects/Farming/" + plant_name + " plant.tscn"
		plant_instance = load(plant_name_path)
		plant_instance = load(plant_name_path).instantiate()
		plant_instance.position = plant_target_pos
#		get_tree().get_root().add_child(plant_instance)
		canvas_layer.add_child(plant_instance) 
		#Remove hole
		hole_to_remove.queue_free()
		#Instantiate plant
func move_to_target(delta):
	# If a target position has been set
	if target_pos != Vector2.ZERO and dig_timer.is_stopped():
		# Check if any movement keys are pressed
		if Input.is_action_pressed("up") or Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			# Interrupt move to target if movement key pressed
			target_pos = Vector2.ZERO
		else:
			# Calculate direction to target
			var dir_to_target = (target_pos - global_position).normalized()
			# Move towards target
			player.velocity = dir_to_target * player.move_speed * delta
			movement_component.update_animation_parameters(dir_to_target)
			player.move_and_slide()
			# If player is close enough to target
			if (global_position + Vector2(0, 16)).distance_to(target_pos) < 18:
				if hole_to_remove != null:
					#Remove the hole
					hole_to_remove.queue_free()
					hole_to_remove = null
				else:
					# Instantiate hole
					var hole_instance = hole.instantiate()
					hole_instance.position = target_pos
					hole_instance.get_node("Sprite2D").material = hole_instance.get_node("Sprite2D").material.duplicate()
#					get_tree().get_root().add_child(hole_instance)
					canvas_layer.add_child(hole_instance) 
					hole_instance.get_node("CPUParticles2D").emitting = true
				dig_timer.start()
				# Reset target position
				target_pos = Vector2.ZERO		
func water_process(delta):
	var player_pos = player.position
	var plant_pos = get_global_mouse_position()
	var mouse_distance = plant_pos.distance_to(player_pos)
	var closest_plant = null
	var closest_distance = INF
	# Now, search for the closest plant
	for plant in plants_inside:
		var distance_to_plant = plant_pos.distance_to(plant.global_position)
		if distance_to_plant < 10 and (closest_plant == null or distance_to_plant < closest_distance) and mouse_distance < plant_radius:
			closest_plant = plant
			closest_distance = distance_to_plant




func _on_scan_zone_body_entered(body):
	if body.is_in_group("plants"):
		print("Plant nearby!!!!")
		plants_inside.append(body)
		body.get_node("Sprite2D").material = body.get_node("Sprite2D").material.duplicate()


func _on_scan_zone_body_exited(body):
	if body in plants_inside:
		plants_inside.erase(body)


func _on_player_shelby_player_planting(item_name):
	pass # Replace with function body.
