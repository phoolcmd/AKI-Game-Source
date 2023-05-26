extends CharacterBody2D
var speed = 100

var player_body = get_node(".")
var player_pos = player_body.position

var randomnum
var target

enum {
	SURROUND,
	ATTACK,
	HIT,
}
var state = SURROUND

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	randomnum = rng.randf()
	target = get_circle_position(randomnum)
	
func _physics_process(delta):
	match state:
		SURROUND:
			move(target, delta)
func move(target, delta):
	var direction = (target - global_position).normalized()
	var desired_velocity = direction * speed
	var steering = (desired_velocity - velocity) * delta * 2.5
	velocity += steering
	move_and_slide()

func get_circle_position(random):
	var kill_circle_centre = player.global_position
	var radius = 40
	var angle =  random * PI * 2
	var x = kill_circle_centre.x + cos(angle) * radius
	var y = kill_circle_centre.y + sin(angle) * radius
	
	return Vector2(x,y)
	
