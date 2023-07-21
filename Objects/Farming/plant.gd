extends RigidBody2D

@onready var growth_timer: Timer = $GrowTimer
@onready var sprite : Sprite2D = $Sprite2D

func _ready():
	sprite.frame = 0 # Initial frame
	growth_timer.wait_time = 7.5 # Divide the total time by the number of frames
	growth_timer.one_shot = true # Make the timer only go off once
	growth_timer.start()


func _on_grow_timer_timeout():
	sprite.frame += 1 # Move to the next frame
	if sprite.frame < 3: # If the plant hasn't reached the last frame yet
		growth_timer.start() # Restart the timer
