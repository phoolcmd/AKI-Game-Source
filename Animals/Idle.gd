extends State
class_name Idle

@export var animal: CharacterBody2D
@export var move_speed : float = 30.0

@export var favorite_food_scene: PackedScene = null
var food_instances: Array = []
var food : RigidBody2D
var move_direction : Vector2
var wander_duration : float
var idle_duration : float

func randomize_wander():
	move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_duration = randf_range(1,4)
	idle_duration = randf_range(1,8) # Idle for a random duration between 1 to 3 seconds
	
func Enter():
	food = get_tree().get_first_node_in_group("food")
	randomize_wander()
	
func Update(delta: float):
	if wander_duration > 0:
		wander_duration -= delta
		if wander_duration <= 0: # Start the idle timer when wander time finishes
			idle_duration = randf_range(1,8)
	else:
		idle_duration -= delta
		if idle_duration <= 0: # Start wandering again when idle time finishes
			randomize_wander()

func Physics_Update(delta : float): # if food item is present then walk towards it
	if animal:
		if wander_duration > 0: # Only move when wandering
			animal.velocity = move_direction * move_speed
		else:
			animal.velocity = Vector2(0, 0) # Stop when idling


func _on_food_detection_body_entered(body):
	if body == food:
		print("food detected")
		print(food)
		print("position: ", food.position)
		Transitioned.emit(self,"Eat")
