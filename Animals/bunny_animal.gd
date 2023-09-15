extends CharacterBody2D
class_name Animal

var last_direction: Vector2 = Vector2(0, -1)  # Defaulting to 'up'
var is_eating: bool = false
@onready var eat_class : Eat = $StateMachine/Eat

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
		if last_direction.y > 0:
			$AnimatedSprite2D.play("idle_down")
		elif last_direction.y < 0:
			$AnimatedSprite2D.play("idle_up")
		else:
			$AnimatedSprite2D.play("idle")  # Default idle animation if the character was moving horizontally last

func _on_Eating():
	print("eating signal caught")
	is_eating = true
	$AnimatedSprite2D.play("eat")


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "eat":
		is_eating = false 
