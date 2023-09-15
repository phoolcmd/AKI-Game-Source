extends RigidBody2D

# Handles movement and state logic of animal

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var navReg = $'../NavigationRegion2D'
@onready var nav = get_node("NavigationAgent2D")
@export var speed : float = 30.0

enum AnimationState {
	Idle = 0,
	Idle_Down = 1,
	Idle_Up = 2,
	Walk = 3,
	Walk_Down = 4,
	Walk_Up = 5,
}

var current_state = AnimationState.Idle
var anim_states = []
var last_direction = Vector2(0, -1)
var path = []
var map
var random_move_timer = 5.0  # The time in seconds after which the animal chooses a new random target
var last_random_move_time = 0.0

func setup_navserver():
	map = NavigationServer2D.map_create()
	NavigationServer2D.map_set_active(map, true)
	
	var region = NavigationServer2D.region_create()
	NavigationServer2D.region_set_transform(region, Transform2D())
	NavigationServer2D.region_set_map(region, map)
	
	var navigation_poly = NavigationMesh.new()
	navigation_poly = $'../NavigationRegion2D'.navigation_polygon
	NavigationServer2D.region_set_navigation_polygon(region, navigation_poly)
func _update_navigation_path(start_position, end_position):
	path = NavigationServer2D.map_get_path(map,start_position,end_position, true)
	path.remove_at(0)
	set_process(true)
	
func _ready():
	call_deferred("setup_navserver")
	anim_states = sprite.sprite_frames.get_animation_names()
	set_animation_state(current_state)
#	initiate_random_path()  # Start the first random path
#
#func _unhandled_input(event):
#	if not event.is_action_pressed("left_click"):
#		return
#	_update_navigation_path(self.position, get_global_mouse_position())
	
func _physics_process(delta):
	var walk_distance = speed * delta
	wander(delta)

	
func move_along_path(distance):
	var last_point = self.position 

	while path.size():
		var distance_between_points = last_point.distance_to(path[0])
		
		if distance <= distance_between_points:
			self.position =  last_point.lerp(path[0], distance / distance_between_points)
			
			# Compute direction and choose animation
			var direction = (path[0] - last_point).normalized()
			choose_animation(direction)
			return

		# Compute direction and choose animation for the whole segment
		var direction = (path[0] - last_point).normalized()
		choose_animation(direction)
		
		distance -= distance_between_points
		last_point = path[0]
		path.remove_at(0)

	if path.size() == 0 and last_point != self.position:
		self.position = last_point
		set_idle()
	
	set_process(false)


	
func choose_animation(direction: Vector2):
	last_direction = direction
	if direction == Vector2.ZERO:
		set_idle()
	else:
		if abs(direction.x) > abs(direction.y):
			set_animation_state(AnimationState.Walk) # Moving horizontally
			if direction.x < 0:
				sprite.flip_h = false # Moving left
			else:
				sprite.flip_h = true # Moving right
		else:
			sprite.flip_h = true # Reset to default
			if direction.y < 0:
				set_animation_state(AnimationState.Walk_Up) # Moving upwards
			else:
				set_animation_state(AnimationState.Walk_Down) # Moving downwards



func set_animation_state(state):
	current_state = state
	sprite.play(anim_states[current_state])
	
func set_idle():
#	linear_velocity = Vector2(0, 0)  # Set velocity to 0

	# Determine the correct idle animation based on the last known direction
	if abs(last_direction.x) > abs(last_direction.y):
		set_animation_state(AnimationState.Idle)
	else:
		if last_direction.y < 0:
			set_animation_state(AnimationState.Idle_Up)
		else:
			set_animation_state(AnimationState.Idle_Down)
	
func wander(delta: float):
	var walk_distance = speed * delta
	move_along_path(walk_distance)
	
	# Check if it's time to choose a new random target
	last_random_move_time += delta
	if last_random_move_time >= random_move_timer:
		last_random_move_time = 0.0
		initiate_random_path()
		
func initiate_random_path():
	var max_distance = 50.0  # The maximum distance the animal can move in any direction from its current position
	
	# Generate a random vector with both x and y components in the range [-max_distance, max_distance]
	var random_offset = Vector2(randf_range(-max_distance, max_distance), randf_range(-max_distance, max_distance))
	
	var random_target = self.position + random_offset
	
	_update_navigation_path(self.position, random_target)
