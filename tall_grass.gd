extends Node2D

@onready var anim_player = $AnimationPlayer



func _on_area_2d_body_entered(body):
	anim_player.play("stepped")
