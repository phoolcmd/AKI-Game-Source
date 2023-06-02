extends Node2D

@onready var rigid_body = get_parent()
@onready var player = get_node("/root/Main/Player_Shelby")
@onready var player_pos = player.position
@onready var player_global_pos = player.global_position
@onready var sprite = rigid_body.get_node("Sprite2D")

@export var resource_type : Resource

var in_range = false
var picking_up = false

var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var acceleration = 50 

func _ready():
	connect("body_entered", _on_pickup_zone_body_entered)

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
			$Delay.start()
	
	if picking_up and $Delay.is_stopped():
		sprite.frame = 2
		player_global_pos = player.global_position
		direction = (player_global_pos - rigid_body.position).normalized()
		velocity = velocity.move_toward(direction * 80, acceleration * delta)
		rigid_body.move_and_collide(velocity)
		



func _on_pickup_zone_body_entered(body):
	var inventory = body.find_child("Inventory")
	if(inventory and picking_up):
		inventory.add_resources(resource_type, 1)
		print("added to inventory")
		rigid_body.queue_free()
