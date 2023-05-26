extends RigidBody2D

@onready var player = get_node("/root/Main/Player_Shelby")
@onready var player_pos = player.position
@onready var player_global_pos = player.global_position

@onready var sprite = $Sprite2D



func _on_area_2d_body_entered(body):
	if body == player:
		sprite.frame = 1


func _on_area_2d_body_exited(body):
	if body == player:
		sprite.frame = 0
