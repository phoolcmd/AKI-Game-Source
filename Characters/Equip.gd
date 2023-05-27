extends Node2D

@export var equipped_item : Resource

func _on_area_2d_body_entered(body):
	if (body is ResourceNode):
		body.harvest()
