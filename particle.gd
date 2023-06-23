extends RigidBody2D

@onready var particle_explode = $particle_explode
@onready var particle_trail = $trails
@onready var particle_trail_2 = $trails2
@onready var particle_orb = $Sprite2D
@onready var trail_tween = get_tree().create_tween()
@onready var trail2_tween = get_tree().create_tween()
@onready var orb_tween = get_tree().create_tween()

func _on_body_entered(body):
	if body.is_in_group("npc") || body.is_in_group(("enemy")):
		#print("hit")
		queue_free()

		
	
func _ready():
	#var start_color = particle_trail.color
	var final_color = Color(100/255.0, 0, 255/255.0)
	particle_explode.restart()
	trail_tween.tween_property(particle_trail, "color", final_color, 3)
	trail_tween.play()
	trail2_tween.tween_property(particle_trail_2, "color", final_color, 3)
	trail2_tween.play()
	orb_tween.tween_property(particle_orb, "modulate", final_color, 3)
	orb_tween.play()
	$Timer.start()

	
	
	
func _on_timer_timeout():
	queue_free()


#func _process(delta):
	#tween.tween_property(particle_trail,"color",final_color, 3)
	#if Input.is_action_just_released("follow"):
		#$Timer.start()
	#pass

