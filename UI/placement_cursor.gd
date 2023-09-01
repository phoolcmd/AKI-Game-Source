extends Control

@onready var sprite : Sprite2D = $Sprite2D
var collision_count = 0  # Counter for the number of bodies in collision
var collision_detected = false
func _on_collision_area_body_entered(body):
	if body:
		collision_count += 1  # Increment count when a body enters
		if collision_count > 0:  # Check if any body is in collision
			collision_detected = true
			sprite.frame = 1

func _on_collision_area_body_exited(body):
	collision_count -= 1  # Decrement count when a body exits
	if collision_count <= 0:  # Check if no bodies are in collision
		collision_count = 0  # Ensure the counter doesn't go below zero
		collision_detected = false
		sprite.frame = 0
