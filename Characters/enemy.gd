extends CharacterBody2D
@onready var player = get_node("/root/Main/Player_Shelby")
@onready var player_pos = player.position
@onready var player_global_pos = player.global_position

@export var particle_speed = 10
@export var particle = preload("res://enemy_particle.tscn")
@export var particle_player = preload("res://particle.tscn")

var particle_instance = null

@export var move_speed : float = 30
var move_direction : Vector2 = Vector2.ZERO
@onready var collision = $CollisionShape2D
@onready var sprite = $Sprite2D
var current_animation = "idle"

var enemy_pos = null
var chase_player = false
@export var health = 100


func _ready():
	move_direction = Vector2.ZERO
	
	
func _physics_process(delta):
	player_pos = player.position
	player_global_pos = player.global_position
	if chase_player:
		move_direction = (player_pos - position).normalized()
	else:
		move_direction = Vector2.ZERO
	update_animation()
	velocity = move_direction * move_speed * delta
	move_and_collide(velocity)
		
func fire():
	particle_instance = particle.instantiate()
	particle_instance.position = position
	get_tree().get_root().add_child(particle_instance)


func _on_fire_timer_timeout():
	fire() # Replace with function body.

func _process(delta):
	if particle_instance != null:
		var direction = player_global_pos - particle_instance.position
		direction = direction.normalized()
		particle_instance.apply_impulse(Vector2(direction * particle_speed))
		
	if health == 0:
		print("Ghost dead")
		queue_free()

func _on_prox_zone_body_entered(body):
	if body == player:
		print("entered detection zone - attacking")
		chase_player = true
		$FireTimer.start() # Replace with function body.
		

func _on_sight_zone_body_exited(body):
	if body == player:
		print("exited sight - no longer pursuing")
		chase_player = false
		$FireTimer.stop()
	
func _on_hurt_box_body_entered(body):
	if body.is_in_group("player_projectile"):
		health -= 10
		print("hit from player: -", health)


func _on_stop_zone_body_entered(body):
	if body == player:
		chase_player = false
		
func _on_stop_zone_body_exited(body):
	if body == player:
		chase_player = true

func update_animation():
	if move_direction != Vector2.ZERO:
		if abs(move_direction.x) > abs(move_direction.y):
			# Horizontal movement
			if move_direction.x > 0:
				current_animation = "walk_right"
				sprite.flip_h = false
			else:
				current_animation = "walk_right"
				sprite.flip_h = true
		else:
			# Vertical movement
			if move_direction.y > 0:
				current_animation = "walk_down"
			else:
				current_animation = "walk_up"
			
	else:
		current_animation = "idle"

	$AnimationPlayer.play(current_animation)
