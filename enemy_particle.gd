extends RigidBody2D


@onready var particle_explode = $CPUParticles2D


func _on_body_entered(body):
	if body.is_in_group("player") || body.is_in_group("npc"):
		#print("hit")
		queue_free()
		
	
func _ready():
	particle_explode = $particle_explode
	particle_explode.restart()
	$Timer.start()

	
	
	
func _on_timer_timeout():
	queue_free()



func _on_area_2d_body_entered(body):
	pass # Replace with function body.
