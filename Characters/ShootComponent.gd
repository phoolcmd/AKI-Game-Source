extends Node2D
@export var particle = preload("res://particle.tscn")
@export var particle_speed = 500

@onready var light = get_node("/root/Main/Light")
# Player's Equipment
@onready var equipped_item_name : String = ""
@onready var equipped_item_category : String = ""
#@onready var equipped_item = $'../Equip/Area2D/CollisionShape2D'
#@onready var equipped_item_pos = equipped_item.global_position
#@onready var equipped_item_tex = $'../Equip'




var particle_instance = null

func fire():
	if Input.is_action_just_pressed("follow"):
#		particle_instance = particle.instantiate()
#		particle_instance.position = equipped_item_pos
#		light.add_child(particle_instance)
		#get_tree().get_root().add_child(particle_instance)
		emit_signal("player_firing_signal")

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
