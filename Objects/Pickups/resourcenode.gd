extends RigidBody2D

@export var resource_type : Resource

func _ready():
	connect("body_entered", _on_body_entered)

