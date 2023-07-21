extends CharacterBody2D

class_name Player

signal player_moving_signal
signal player_stopped_signal
signal player_firing_signal
signal item_equipped (item_name)

@export var move_speed : float = 50.0
@export var dash_speed : float = 250.0
@export var dash_duration: float  = 0.1
@export var dig_radius : float = 100
@export var starting_direction : Vector2 = Vector2(0,1)
@export var particle_speed = 500
@export var shield_force = 1000.0

@export var particle = preload("res://particle.tscn")
@export var hole = preload("res://Objects/Farming/hole.tscn")
@export var cursor = preload("res://UI/placement_cursor.tscn")

@onready var animation_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var dash = $Dash

@onready var enemy = get_node("/root/Main/Level/Enemy")
@onready var enemy_pos = enemy.position
@onready var enemy_global_pos = enemy.global_position
@onready var equiped_item_name : String = ""
@onready var equipped_item = $Equip/Area2D/CollisionShape2D
@onready var equipped_item_pos = equipped_item.global_position
@onready var equipped_item_tex = $Equip

@onready var light = get_node("/root/Main/Light")
@onready var ui = get_node("/root/Main/Level/UserInterface")

@onready var dig_timer = $DigTimer
var canDash = true
var dashing
var inside_inv = false


var particle_instance = null
var cursor_instance = null
var enemy_position = Vector2.ZERO
var target_pos = Vector2.ZERO
var hole_to_remove = null
var hole_radius = 10
var placeable : bool = true


func _ready():
	update_animation_parameters(starting_direction)
	cursor_instance = cursor.instantiate()
	add_child(cursor_instance)

func _physics_process(delta):
	if enemy != null:
		enemy_global_pos = enemy.global_position
	animation_tree.advance(delta * 0.2)
	get_input(delta)
	move_and_slide()
#	fire()
#	projectile_process(delta)
	
	if equiped_item_name == "wand blue":
		cursor_instance.visible = true
		dig_process(delta)
	else:
		cursor_instance.visible = false
			
func get_input(delta):
	var movement_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	var facing_direction = movement_direction
#	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and particle_instance != null:
#		equipped_item_pos = equipped_item.global_position
#		var mouse_pos = get_global_mouse_position()
#		facing_direction = (mouse_pos - global_position).normalized()
#		movement_direction = Vector2.ZERO
	update_animation_parameters(facing_direction)
	velocity = facing_direction.normalized() * move_speed * delta
#	_dash(movement_direction)
	
	
func _process(_delta):
	pick_new_state()
	#if equiped item is the blue want change the texture of the wand 
	if equiped_item_name == "wand blue":
		emit_signal("item_equipped", "wand blue")


func update_animation_parameters(move_input : Vector2):
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)
		animation_tree.set("parameters/Collect/blend_position", move_input)
		animation_tree.set("parameters/Wand Attack/blend_position", move_input)
				
func pick_new_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Walk")
		emit_signal("player_moving_signal")
		
#	elif(Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
#		animation_tree["parameters/conditions/attack"] = true
		
	else:
		emit_signal("player_stopped_signal")
		state_machine.travel("Idle")
		
	if(Input.is_action_just_pressed("interact")):
		animation_tree["parameters/conditions/swing"] = true
	else:
		animation_tree["parameters/conditions/swing"] = false
	
func fire():
	if Input.is_action_just_pressed("follow") and !inside_inv:
		particle_instance = particle.instantiate()
		particle_instance.position = equipped_item_pos
		light.add_child(particle_instance)
		#get_tree().get_root().add_child(particle_instance)
		emit_signal("player_firing_signal")
		
		
func _dash(direction):
	if Input.is_action_just_pressed("dash") && dash.can_dash && !dash.is_dashing():
		dash.start_dash(dash_duration)
	var speed = dash_speed if dash.is_dashing() else move_speed
	velocity = direction.normalized() * speed 
	equipped_item_pos = equipped_item.global_position
		
func dig_process(delta):
	
	var player_pos = position
	var mouse_distance = get_global_mouse_position().distance_to(player_pos)
	var dig_pos = get_global_mouse_position()	
	var closest_hole = null
	var closest_distance = 0
	placeable = true
	cursor_instance.global_position = dig_pos
	cursor_instance.get_node("Sprite2D").frame = 1
	#Check if cursor is in valid zone to place hole
	if mouse_distance < dig_radius:
		cursor_instance.get_node("Sprite2D").frame = 0
		# Make the cursor invisible if digging has begun

		if !dig_timer.is_stopped():
			cursor_instance.visible = false
		# Save target location when player left clicks
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and dig_timer.is_stopped():
			target_pos = dig_pos
			
		move_to_target(delta)
				
		var holes = get_tree().get_nodes_in_group("holes")
		# Find the closest hole
		for hole in holes: 
			var distance_to_hole = dig_pos.distance_to(hole.global_position)
			if distance_to_hole < 10:
				if closest_hole == null or distance_to_hole < closest_distance:
					closest_hole = hole
					closest_distance = distance_to_hole
			
		if !dig_timer.is_stopped():
			cursor_instance.visible = false
				
		for hole in holes:
			if hole == closest_hole:
				#Apply outline shader to nearest hole
				hole.get_node("Sprite2D").material.set_shader_parameter("line_scale", 1.0)
				print(hole)
				if is_position_overlapping_hole(dig_pos):
					cursor_instance.get_node("Sprite2D").frame = 1
				#Remove hole if player right clicks	
				if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and dig_timer.is_stopped():
					hole_to_remove = closest_hole
					target_pos = closest_hole.global_position
					cursor_instance.visible = false
			else:
				hole.get_node("Sprite2D").material.set_shader_parameter("line_scale", 0.0)
	else:
		move_to_target(delta)
	
func move_to_target(delta):
	# If a target position has been set
	if target_pos != Vector2.ZERO:
		cursor_instance.visible = false
		# Calculate direction to target
		var dir_to_target = (target_pos - global_position).normalized()
		# Move towards target
		velocity = dir_to_target * move_speed * delta
		update_animation_parameters(dir_to_target)
		move_and_slide()
		# If player is close enough to target
		if (global_position + Vector2(0, 16)).distance_to(target_pos) < 18:
			if hole_to_remove != null:
				#Remove the hole
				hole_to_remove.queue_free()
				hole_to_remove = null
				#Reset target_pos
				target_pos = Vector2.ZERO
				dig_timer.start()
			else:
				# Instantiate hole
				var hole_instance = hole.instantiate()
				hole_instance.position = target_pos
				hole_instance.get_node("Sprite2D").material = hole_instance.get_node("Sprite2D").material.duplicate()
				get_tree().get_root().add_child(hole_instance)
				hole_instance.get_node("CPUParticles2D").emitting = true
				dig_timer.start()
				# Reset target position
				target_pos = Vector2.ZERO
				
func is_position_overlapping_hole(pos):
	var holes = get_tree().get_nodes_in_group("holes")
	for hole in holes:
		if pos.distance_to(hole.position) < hole_radius:
			print(true)
			return true
	return false				
func projectile_process(delta):
	var shot_direction = Vector2.ZERO
	var mouse_pos = get_global_mouse_position().x
	var player_pos = get_global_transform().origin.x
	var closest_enemy = null
	var closest_distance = 0
	#If there is a particle present
	if particle_instance != null:
		#Follow mouse cursor when left click held
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			particle_instance.position = particle_instance.position.lerp(get_global_mouse_position(), delta * 7.0)
		#When mouse released
		elif Input.is_action_just_released("follow"):
			#shoot to the left if mouse cursor to the left of character
			if mouse_pos < player_pos:
				shot_direction = Vector2.LEFT
			#shoot to the right if mouse cursor to the right of charcter
			if mouse_pos > player_pos:
				shot_direction = Vector2.RIGHT
				
			#Get enemies from group
			var enemies = get_tree().get_nodes_in_group("enemy")
			#Iterate through enemies and target the nearest one
			for enemy in enemies:
				var distance_to_enemy = particle_instance.position.distance_to(enemy.global_position)
				# print(distance_to_enemy)
				if distance_to_enemy < 100:	
					if closest_enemy == null or distance_to_enemy < closest_distance:
						closest_enemy = enemy
						closest_distance = distance_to_enemy
		#if enemy found apply impulse in direction of closest enemy
					if closest_enemy != null:
						shot_direction = closest_enemy.global_position - particle_instance.position
						shot_direction = shot_direction.normalized()		
		particle_instance.apply_impulse(Vector2(shot_direction * particle_speed))		
func _exit_tree():
	cursor_instance.queue_free()					
		


