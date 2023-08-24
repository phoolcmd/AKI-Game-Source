extends Node2D

@onready var plant = get_parent()
@onready var player = get_node("/root/Main/Level/Player_Shelby")
@onready var player_pos = player.position
@onready var player_global_pos = player.global_position
@onready var sprite = plant.get_node("Sprite2D")


var in_range = false
var picking_up = false
var item_name

var velocity = Vector2.ZERO
var direction = Vector2.ZERO
var acceleration = 50 

func _ready():
	var regex = RegEx.new()
	regex.compile("\\d+")
	item_name = regex.sub(plant.name, "", false)
	#print(item_name)

func _on_area_2d_body_entered(body):
	if body == player:
		sprite.material.set_shader_parameter("line_scale", 1.0)
		in_range = true

func _on_area_2d_body_exited(body):
	if body == player:
		sprite.material.set_shader_parameter("line_scale", 0.0)
		in_range = false

func _process(_delta):
	player_global_pos = player.global_position

func _physics_process(delta):
	if in_range:
		if Input.is_action_just_pressed("interact"):
			picking_up = true
			$Delay.start()
	
	if picking_up and $Delay.is_stopped():
		sprite.material.set_shader_parameter("line_scale", 0.0)
		player_global_pos = player.global_position
		direction = (player_global_pos - plant.position).normalized()
		velocity = velocity.move_toward(direction * 80, acceleration * delta)
		
		plant.move_and_collide(velocity)
		
func _on_pickup_zone_body_entered(_body):
	if picking_up:
		PlayerInventory.add_item(item_name, 1) # Add item to inventory
		plant.queue_free()
