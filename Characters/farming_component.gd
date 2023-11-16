extends Node2D
signal player_placing(item_name)

# Preloaded Assets
@export var hole = preload("res://Objects/Farming/hole.tscn")

@export var plant_radius : float = 30
@export var dig_radius : float = 100

@onready var player = get_parent()
@onready var dig_timer = $'../DigTimer'
@onready var movement_component = $'../MovementComponent'
@onready var canvas_layer = get_tree().get_root().get_node("Main/Level/Farm")
@onready var grid_system = get_tree().get_root().get_node("Main/Level/TileMap")
@onready var animation_player = $'../AnimationPlayer'
var target_pos = Vector2.ZERO
var hole_to_remove = null
var hole_radius = 10
var placeable = true

var plants_inside = []
func _ready():
	pass

	
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
	
	# Determine target position for left-click
	if mouse_distance < dig_radius and dig_timer.is_stopped() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var can_place_hole = true
		for hole in holes:
			if dig_pos.distance_to(hole.global_position) < 10:
				can_place_hole = false
				break
		if grid_system.cursor_instance.collision_detected == false:
			target_pos = dig_pos

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
	
	# Determine target position for right-click
	if closest_hole != null and mouse_distance < dig_radius and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and dig_timer.is_stopped():
		hole_to_remove = closest_hole
		target_pos = closest_hole.global_position
	
	# Call move_to_target after determining target_pos
	move_to_target(delta)

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
			#Emit a signal here that the player is is over a hole so that the placement system does not run
			
		else:
			hole.get_node("Sprite2D").material.set_shader_parameter("line_scale", 0.0)
	if closest_hole != null and mouse_distance < plant_radius and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and dig_timer.is_stopped():
		hole_to_remove = closest_hole
		plant_target_pos = closest_hole.global_position
		emit_signal("player_placing", player.equipped_item_name)
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
	# Exit early if no target set or if digging is in progress
	if target_pos == Vector2.ZERO or not dig_timer.is_stopped():
		return

	# If any movement keys are pressed, reset target position and exit
	if is_movement_key_pressed():
		target_pos = Vector2.ZERO
		return

	# Move player towards target
	move_player_towards_target(delta)

	# If close enough to target, dig or remove hole
	if is_close_to_target():
		process_dig_or_remove_hole(delta)
		target_pos = Vector2.ZERO

# Check if any movement keys are pressed
func is_movement_key_pressed():
	return Input.is_action_pressed("up") or \
		   Input.is_action_pressed("down") or \
		   Input.is_action_pressed("left") or \
		   Input.is_action_pressed("right")

# Move the player in the direction of the target
func move_player_towards_target(delta):
	var dir_to_target = (target_pos - global_position).normalized()
	player.velocity = dir_to_target * player.move_speed * delta
	movement_component.update_animation_parameters(dir_to_target)
	player.move_and_slide()

# Check if player is close enough to the target
func is_close_to_target():
	return (global_position + Vector2(0, 16)).distance_to(target_pos) < 18

# Either instantiate a new hole or remove an existing one
func process_dig_or_remove_hole(delta):
	if is_instance_valid(hole_to_remove):
		hole_to_remove.queue_free()
		hole_to_remove = null
	else:
		instantiate_hole_at_target(delta)

# Instantiate a new hole at the target position
func instantiate_hole_at_target(delta):
	var hole_instance = hole.instantiate()
	hole_instance.position = target_pos
	# Duplicate material to prevent shared state
	hole_instance.get_node("Sprite2D").material = hole_instance.get_node("Sprite2D").material.duplicate()
	canvas_layer.add_child(hole_instance)
	hole_instance.get_node("CPUParticles2D").emitting = true
	dig_timer.start()

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
#					await get_tree().create_timer(1).timeout
					hole_to_remove.queue_free()
					hole_to_remove = null
				else:
					# Instantiate hole
#					await get_tree().create_timer(1).timeout
					hole_instance = hole.instantiate()
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


func _on_player_shelby_player_placing(item_name):
	pass # Replace with function body.



