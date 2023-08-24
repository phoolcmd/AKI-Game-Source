extends Node2D

signal player_moving_signal
signal player_stopped_signal
signal player_firing_signal

@onready var animation_tree = $'../AnimationTree'
@onready var animation_player = $'../AnimationPlayer'
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var player = get_parent()

@onready var trail1 = $'../trails'
@onready var trail2 = $'../trails2'



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
	player.velocity = facing_direction.normalized() * player.move_speed * delta
#	_dash(movement_direction)

func update_animation_parameters(move_input : Vector2):
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)
		animation_tree.set("parameters/Collect/blend_position", move_input)
		animation_tree.set("parameters/Wand Attack/blend_position", move_input)
				
func pick_new_state():
	if(player.velocity != Vector2.ZERO):
		state_machine.travel("Walk")
		emit_signal("player_moving_signal")
		trail1.emitting = true
		trail2.emitting = true
		
#	elif(Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
#		animation_tree["parameters/conditions/attack"] = true
		
	else:
		emit_signal("player_stopped_signal")
		state_machine.travel("Idle")
		trail1.emitting = false
		trail2.emitting = false
		
	if(Input.is_action_just_pressed("interact")):
		animation_tree["parameters/conditions/swing"] = true
	else:
		animation_tree["parameters/conditions/swing"] = false
