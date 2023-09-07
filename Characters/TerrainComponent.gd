extends Node2D

@onready var player = get_parent()

var ground_layer = 0
var environment_layer = 1
var can_place_grass_custom_data = "can_place_grass"
var can_place_dirt_custom_data = "can_place_dirt"
# This is the list of atlas coordinates you want to exclude
var excluded_atlas_coords = [Vector2i(10, 1), Vector2i(11, 2)]  # Add the tiles you want to exclude here

func grass_placement_process():
	if Input.is_action_just_pressed("middle_mouse"):
		print("Placing grass tile")
		
		var mouse_pos : Vector2 = get_global_mouse_position()
		var tile_mouse_pos : Vector2i = player.grid_system.local_to_map(mouse_pos)
		var atlas_coord : Vector2i = Vector2i(11, 1)

		# Check if the atlas coord is not in the exclusion list and the custom data allows grass placement
		if atlas_coord not in excluded_atlas_coords and retrieve_custom_data(tile_mouse_pos, can_place_grass_custom_data, ground_layer):
			# Set the terrain connect for just this tile position
			player.grid_system.set_cells_terrain_connect(ground_layer, [tile_mouse_pos], 0, 0)

func dirt_placement_process():
	if Input.is_action_just_pressed("middle_mouse"):
		print("Placing dirt tile")
		
		var mouse_pos : Vector2 = get_global_mouse_position()
		var tile_mouse_pos : Vector2i = player.grid_system.local_to_map(mouse_pos)
		var atlas_coord : Vector2i = Vector2i(11, 1)

		# Check if the atlas coord is not in the exclusion list and the custom data allows grass placement
		if atlas_coord not in excluded_atlas_coords and retrieve_custom_data(tile_mouse_pos, can_place_dirt_custom_data, ground_layer):
			# Set the terrain connect for just this tile position
			player.grid_system.set_cells_terrain_connect(ground_layer, [tile_mouse_pos], 0, 1)

func retrieve_custom_data(tile_mouse_pos, custom_data_layer, layer):
	var tile_data : TileData = player.grid_system.get_cell_tile_data(layer, tile_mouse_pos)
	if tile_data:
		return tile_data.get_custom_data(custom_data_layer)
	else:
		return false
