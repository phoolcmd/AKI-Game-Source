extends ColorRect

@onready var camera = get_node("/root/Main/Player_Shelby/Camera2D")

func _process(delta):
	#print(camera.get_screen_center_position()) 
	
	var camera_pos = camera.get_screen_center_position()
	camera_pos = camera_pos.normalized()
	
	position = camera_pos
