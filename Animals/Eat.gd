extends State
class_name Eat

signal Eating

@export var favorite_food_scene: PackedScene = null
@export var animal: CharacterBody2D
@export var move_speed: float = 30.0
var food_instances: Array = []
var is_eating = false
var closest_food
@onready var sprite : AnimatedSprite2D = $"../../AnimatedSprite2D"

func Enter():
	print("Rabbit in eat mode")
	
func Exit():
	is_eating = false
	
func update_food_instances():
	food_instances = get_tree().get_nodes_in_group("food")

	if food_instances.size() == 0:
		print("Warning: No food instances found in the scene!")

func find_closest_food():
	var closest_food = null
	var closest_distance = INF

	for food in food_instances:
		var distance = food.global_position.distance_to(animal.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_food = food

	if closest_food:
		print("position: ", closest_food.global_position)
	return closest_food

func Physics_Update(delta: float):
	update_food_instances()
	closest_food = find_closest_food()

	if closest_food:
		var margin: float = 15.0
		var adjusted_food_position = closest_food.global_position - Vector2(0, margin)
		var direction_to_food = (adjusted_food_position - animal.global_position).normalized()
		animal.velocity = direction_to_food * move_speed
		if animal.global_position.distance_to(closest_food.global_position) < 20.0:
			animal.velocity = Vector2.ZERO
			Eating.emit() #used to trigger animation in animal script
			if closest_food:
				closest_food.queue_free()
				Transitioned.emit(self, "Idle")

