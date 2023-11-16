extends CharacterBody2D
# Movement properties
var speed_x: float = 500.0
var amplitude: float = 20.0
var frequency: float = 1.0
var cosine_amplitude: float = 10.0
var cosine_frequency: float = 0.5
var time: float = 0.0
var wave_speed: float = 1.0
var base_y: float

# Light flicker properties
var light: PointLight2D
var light_base_energy: float = 0.7
var light_flicker_amplitude: float = 0.4
var light_flicker_frequency: float = 2.0

# Direction change properties
# Direction change properties
var directions = [
	Vector2(-1, -1), Vector2(1, -1),
	Vector2(-1, 0),                     Vector2(1, 0),
	Vector2(-1, 1), Vector2(1, 1)
]
var current_direction: Vector2 = Vector2(1, 0)  # Start by moving to the right

var direction_timer : Timer
var time_hour

# Control visibility of the firefly
var is_visible: bool = true

func _ready():
	base_y = position.y
	light = $PointLight2D  # Assuming the PointLight2D is a direct child of the firefly
	
	# Set initial random direction and light flicker frequency
	current_direction = directions[randi() % directions.size()]
	light_flicker_frequency = randf_range(1.2, 2.0)  # Adjust range as needed
	amplitude = randf_range(15.0, 20.0)
	# Setup the timer to change direction
	direction_timer = $DirectionTimer
	direction_timer.one_shot = true
	direction_timer.wait_time = randf_range(10.0, 18.0)  # Change direction every 3 to 5 seconds
	direction_timer.start()
	Daynightcycle.time_tick.connect(Callable(self,"on_time_tick"))
	
func _physics_process(delta):
	# Calculate the desired position
	var new_x = position.x + current_direction.x * speed_x * delta
	var new_y = base_y + amplitude * sin(time * frequency) + cosine_amplitude * cos(time * cosine_frequency) + current_direction.y * speed_x * delta
	
	# Calculate the movement vector
	velocity = Vector2(new_x - position.x, new_y - position.y)
	
	# Move the KinematicBody2D using move_and_slide
	move_and_slide()
	
	# Flicker the light
	light.energy = light_base_energy + light_flicker_amplitude * sin(time * light_flicker_frequency)
	
	# Increase time for calculations
	time += wave_speed * delta
	

func _on_direction_timer_timeout():
	# Choose a new random direction
	current_direction = directions[randi() % directions.size()]

	# Restart the timer with a new random duration
	direction_timer.wait_time = randf_range(10.0, 18.0)
	direction_timer.start()

func on_time_tick(day: int, hour: int, minute: int) -> void:
	# For example, hide the firefly from 6 AM to 6 PM
#	print(hour , minute)
	if 6 <= hour && hour < 18:
		if is_visible:
			hide_firefly()
	else:
		if not is_visible:
			show_firefly()

func hide_firefly() -> void:
	is_visible = false
	var tween = create_tween().set_parallel()
#	tween.tween_property(self, "modulate:a", light_base_energy, 1)
	tween.tween_property(self, "modulate:a", 0.0, 1)
	tween.tween_property(light, "color:a", 0.0, 1 )
	

func show_firefly() -> void:
	is_visible = true
	self.show()
	light.show() # Show the light again
