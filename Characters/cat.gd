extends CharacterBody2D

enum CAT_STATE {IDLE, WALK, SIT}

@export var move_speed : float = 16
@export var idle_time : float = 5
@export var walk_time : float = 3
@export var sit_time : float = 8
@export var collide_time : float = 2

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var sprite = $Sprite2D
@onready var timer = $Timer
@onready var collision = $CollisionShape2D

var move_direction : Vector2 = Vector2.ZERO
var current_state : CAT_STATE = CAT_STATE.IDLE

#	var cat_tex1 = preload("res://bullet1.tex")
#	var cat_tex2 = preload("res://bullet2.tex")
func _ready():
	select_new_direction()
	pick_new_state()

func _physics_process(delta):
	if(current_state == CAT_STATE.WALK):
		velocity = move_direction * move_speed
		var collision = move_and_collide(velocity * delta)
		if collision:
			select_new_direction()
			
func select_random_texture():
	pass
	
func select_new_direction():
	#	move_speed = 12
	move_direction = Vector2(
		randi_range(-1,1),
		randi_range(-1,1)
	)
	if(move_direction.x < 0):
		sprite.flip_h = false
	elif(move_direction.x > 0):
		sprite.flip_h = true
		
func pick_new_state():
	if(current_state == CAT_STATE.IDLE || current_state == CAT_STATE.SIT):
		state_machine.travel("walk_left")
		current_state = CAT_STATE.WALK
		timer.start(walk_time)
		select_new_direction()
	elif(current_state == CAT_STATE.WALK):
		if(randi_range(0,1) == 0):	
			state_machine.travel("idle_left")
			current_state = CAT_STATE.IDLE
			timer.start(idle_time)
		else:
			state_machine.travel("sit")
			current_state = CAT_STATE.SIT
			timer.start(sit_time)
	
	

func _on_timer_timeout():
	pick_new_state() # Replace with function body.


