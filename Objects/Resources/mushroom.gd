extends RigidBody2D

@onready var player = get_node("/root/Main/Player_Shelby")
@onready var player_pos = player.position
@onready var player_global_pos = player.global_position

@onready var sprite = $Sprite2D
var in_range = false
var picking_up = false

var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var acceleration = 50

func _ready():
	pass
func _on_area_2d_body_entered(body):
	if body == player:
		sprite.frame = 1
		in_range = true


func _on_area_2d_body_exited(body):
	if body == player:
		sprite.frame = 0
		in_range = false
		
func _process(delta):
	player_global_pos = player.global_position
	if picking_up:
		#emit particles
		pass
		
func _physics_process(delta):
	if in_range:
		if Input.is_action_just_pressed("interact"):
			picking_up = true

	if picking_up:
		player_global_pos = player.global_position
		direction = (player_global_pos - position).normalized()
		velocity = velocity.move_toward(direction * 80, acceleration * delta)
		move_and_collide(velocity)

		if player_global_pos.distance_to(global_position) < 10:
			queue_free()
			
	
