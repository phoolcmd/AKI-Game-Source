extends State
class_name Wander
@export var animal: CharacterBody2D


@export var favorite_food_scene: PackedScene = null
@export var wander_duration : int = 3 #The random duration the animal will wander for
var food_instances: Array = []
var food : RigidBody2D
var move_direction : Vector2
var wander_timer : float

func randomize_wander():
	move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized() #set a random direction
	wander_timer = randf_range(1,wander_duration) #Set a random wander duration
	
func Enter():
	print("Wander Mode")
	randomize()
	food = get_tree().get_first_node_in_group("food") #retrieve food from nodes in group. CHANGE THIS WHEN SANCTUARY SYSTEM IS ADDED
	randomize_wander()
	
func Update(delta: float):
	if wander_timer > 0:
		wander_timer -= delta
		if wander_timer <= 0: 
			randomize_wander()

func Physics_Update(delta : float):
	print("Physics Update")
	if wander_timer > 1: # Only move when wandering
		animal.velocity = move_direction * animal.move_speed
	else:
		Transitioned.emit(self,"Idle")


func _on_food_detection_body_entered(body):
	if body == food:
		print("food detected")
		print(food)
		print("position: ", food.position)
		Transitioned.emit(self,"Eat")
