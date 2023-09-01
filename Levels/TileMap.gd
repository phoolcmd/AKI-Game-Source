extends TileMap

class_name GridPlacement

@onready var cursor_scene = preload("res://UI/placement_cursor.tscn")
var cursor_instance = null  # To hold the instance of the cursor scene
@onready var player = get_node("/root/Main/Level/Player_Shelby")
var cursor_spawn_pos = null
func _ready():
	cursor_instance = cursor_scene.instantiate()
	add_child(cursor_instance)
	
func grid_placement_process():
	if cursor_instance != null:
		cursor_instance.visible = true
		var global_mouse_position = get_global_mouse_position()
		var local_mouse_position = to_local(global_mouse_position)
		var tile_position = local_to_map(local_mouse_position)
		
		# Calculate the position where the cursor should be placed
		cursor_spawn_pos = map_to_local(tile_position)
		if cursor_instance:
			cursor_instance.global_position = cursor_spawn_pos + Vector2(0, -1)

func hide_cursor():
	cursor_instance.visible = false
