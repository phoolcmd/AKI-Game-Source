extends CharacterBody2D

class_name Player

signal player_moving_signal
signal player_stopped_signal
signal player_firing_signal

@export var move_speed : float = 5000.0
@export var dash_speed : float = 10000.0
@export var dash_duration: float  = 0.1
@export var starting_direction : Vector2 = Vector2(0,1)
@export var particle_speed = 500
@export var particle = preload("res://particle.tscn")

@onready var animation_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var dash = $Dash

@onready var enemy = get_node("/root/Main/Enemy")
@onready var enemy_pos = enemy.position
@onready var enemy_global_pos = enemy.global_position
@onready var equipped_item = $Equip/Area2D/CollisionShape2D
@onready var equipped_item_pos = equipped_item.global_position
var canDash = true
var dashing



var particle_instance = null
var enemy_position = Vector2.ZERO



func _ready():
	update_animation_parameters(starting_direction)

func _physics_process(delta):
	if enemy != null:
		enemy_global_pos = enemy.global_position
		
	animation_tree.advance(delta * 0.3)
	fire()
	projectile_process(delta)
			
		
func _process(delta):
	if enemy != null:
		enemy_pos = enemy.position
		enemy_global_pos = enemy.global_position
	
	var movement_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	##facing direction is equal to the movement_directions unless the mouse button is clicked
	var facing_direction = movement_direction

	## Update facing_direction based on the mouse position when left mouse button is held down.
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and particle_instance != null:
		equipped_item_pos = equipped_item.global_position
		var mouse_pos = get_global_mouse_position()
		facing_direction = (mouse_pos - global_position).normalized()
		movement_direction = Vector2.ZERO
	if Input.is_action_pressed("interact"):
		movement_direction = Vector2.ZERO
		
	pick_new_state()	
	move_and_slide()
	update_animation_parameters(facing_direction)
	_dash(movement_direction, delta)

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
		
	elif(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		animation_tree["parameters/conditions/attack"] = true
		
	else:
		emit_signal("player_stopped_signal")
		state_machine.travel("Idle")
		animation_tree["parameters/conditions/attack"] = false
		
	if(Input.is_action_just_pressed("interact")):
		animation_tree["parameters/conditions/swing"] = true
	else:
		animation_tree["parameters/conditions/swing"] = false
	
func fire():
	if Input.is_action_just_pressed("follow"):
		particle_instance = particle.instantiate()
		particle_instance.position = equipped_item_pos
		get_tree().get_root().add_child(particle_instance)
		emit_signal("player_firing_signal")
		
		
func _dash(direction, delta):
	if Input.is_action_just_pressed("dash") && dash.can_dash && !dash.is_dashing():
		dash.start_dash(dash_duration)
	var speed = dash_speed if dash.is_dashing() else move_speed
	velocity = direction.normalized() * speed * delta
	equipped_item_pos = equipped_item.global_position
		
func projectile_process(delta):
	var shot_direction = Vector2.ZERO;
	var mouse_pos = get_global_mouse_position().x
	var player_pos = get_global_transform().origin.x
	var closest_enemy = null
	var closest_distance = 0
	#If there is a particle present
	if particle_instance != null:
		#Follow mouse cursor when left click held
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
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
				print(distance_to_enemy)
				if distance_to_enemy < 100:	
					if closest_enemy == null or distance_to_enemy < closest_distance:
						closest_enemy = enemy
						closest_distance = distance_to_enemy
		#if enemy found apply impulse in direction of closest enemy
		if closest_enemy != null:
			shot_direction = closest_enemy.global_position - particle_instance.position
			shot_direction = shot_direction.normalized()		
		particle_instance.apply_impulse(Vector2(shot_direction * particle_speed))

		
	
			
			
			
	
