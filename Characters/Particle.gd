extends Sprite2D

@export var speed = 200
var velocity = Vector2()
var mouse_position = null

func _physics_process(delta):
	velocity = Vector2(0,0)
	mouse_position = get_global_mouse_position()
	
	if Input.is_action_pressed("follow"):
		var direction = (mouse_position - position).normalized()
		velocity = (direction * speed)
		
		
