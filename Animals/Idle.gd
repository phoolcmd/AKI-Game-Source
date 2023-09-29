extends State
class_name Idle

@export var animal: CharacterBody2D
@export var move_speed : float = 30.0
@export var idle_duration : int = 5 #the random duration that the animal will idle
@onready var move_direction = $"../Wander".move_direction
var food_instances: Array = []
var food : RigidBody2D

var idle_timer : float

func Exit():
	pass

func Enter():
	print("Idle Mode")
	randomize() # random seed initialization
	idle_timer = randf_range(1, idle_duration) # Set a random wander duration
	animal.velocity = Vector2.ZERO
	
	if randf() > 0.7: # 70% chance no emote, 30% chance an emote will play
		if randf() < 0.2: # 20% chance emote 1 will play
			play_emote(1)
		else: # 80% chance emote 2 will play
			play_emote(2)
	
func Update(delta : float):
	if idle_timer > 0:
		idle_timer -= delta

func Physics_Update(_delta : float):
	if idle_timer < 1:
		Transitioned.emit(self, "Wander")
		
func play_emote(emote_number: int):
	match emote_number:
		1:
			# code to play emote 1
			print("Playing Emote 1")
			pass
		2:
			# code to play emote 2
			print("Playing Emote 2")
			pass
		_:
			# default case, in case more emotes are added in the future
			pass
