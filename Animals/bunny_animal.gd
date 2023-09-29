extends CharacterBody2D
class_name Animal

var last_direction: Vector2 = Vector2(0, -1)  # Defaulting to 'up'
var is_eating: bool = false
@onready var eat_class : Eat = $StateMachine/Eat
@export var move_speed : float = 30.0
@onready var eat_particles = $CPUParticles2D

func _ready():
	eat_class.Eating.connect(_on_Eating)

func _physics_process(delta):
	move_and_slide()

	if is_eating:
		return  # Skip the usual animation logic if the character is eating

	# Check if the character is moving
	if velocity.length() > 0:
		last_direction = velocity.normalized()

		# Horizontal movement
		if abs(velocity.x) > abs(velocity.y):
			$AnimatedSprite2D.play("walk")
			$AnimatedSprite2D.flip_h = velocity.x > 0
		# Vertical movement
		else:
			if velocity.y > 0:
				$AnimatedSprite2D.play("walk_down")
			elif velocity.y < 0:
				$AnimatedSprite2D.play("walk_up")
	else:
		# Idle state
		# If last horizontal movement is stronger or equal than vertical
		if abs(last_direction.x) >= abs(last_direction.y):
			if last_direction.x < 0:
				$AnimatedSprite2D.play("idle")  # Left
				$AnimatedSprite2D.flip_h = false  # Ensure it's not flipped
			else:
				$AnimatedSprite2D.play("idle")  # Right
				$AnimatedSprite2D.flip_h = true   # Flip the sprite
		# Else, it's primarily vertical movement
		else:
			if last_direction.y > 0:
				$AnimatedSprite2D.play("idle_down")
			else:
				$AnimatedSprite2D.play("idle_up")


func _on_Eating():
#	print("eating signal caught")
	is_eating = true
	$AnimatedSprite2D.play("eat")

	if abs(last_direction.x) >= abs(last_direction.y):
		if last_direction.x < 0:
			eat_particles.emitting = true
		else:
			# Get the current gravity value
			var current_gravity = eat_particles.gravity
			var particle_position = eat_particles.position
			# Flip the gravity direction and particle positon
			eat_particles.gravity = Vector2(current_gravity.x * -1, current_gravity.y * 1)
			eat_particles.position = Vector2(particle_position.x * -1, particle_position.y * 1)
			eat_particles.emitting = true
			


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "eat":
		is_eating = false 
