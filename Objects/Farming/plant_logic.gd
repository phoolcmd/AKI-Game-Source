extends Node2D

@onready var growth_timer: Timer = $'../GrowTimer'
@onready var dying_timer: Timer = $'../DyingTimer'
@onready var status_timer : Timer = $'../StatusTimer'
@onready var drain_timer : Timer = $'../DrainTimer'
@onready var addition_timer : Timer = $'../WaterAdditionTimer'

@onready var sprite : Sprite2D = $'../Sprite2D'
@onready var water_meter : Control = $'../WaterMeter'

@export var time_grow : float = 10.0 #Time it takes for the plants to grow
@export var time_die : float = 20.0 #Time it takes for the plant to die if water level too low
@export var time_drain : float = 5.0 #The time is takes for the water level to decrease by a value
@export var time_status : float = 3.0 #The time before a check on the water level is executed. water_level_process() - good to have this match drain time
	
@export var water_capacity : float = 20.0 #Capacity of water for the plant
@export var wet_multiplier : float = 0.5 #Multiplier for when the plant water level is high
@export var dry_multiplier : float = 1.5 #Multiplier for when the plant water level is low
@export var default_water_level : float = 10.0
@export var item_drop : String
@onready var player = get_node("/root/Main/Level/Player_Shelby")
@onready var plant = get_parent()
var water_level = null
var original_time_to_grow = time_grow # Storing the original value to reset later if needed
var multiplier_applied = false
var plant_harvestable = false
var mouse_over_meter: bool = false
var can_water : bool = false
var finished_growing : bool = false

func _ready():
	water_level = default_water_level
	sprite.frame = 0 # Initial frame
	growth_timer.wait_time = time_grow # Set the initial growth time
	growth_timer.one_shot = true # Make the timer only go off once
	growth_timer.start()
	
	dying_timer.wait_time = time_die
	dying_timer.one_shot = true
	
	status_timer.wait_time = time_status
	status_timer.one_shot = true
	status_timer.start()
	
	drain_timer.wait_time = time_drain
	drain_timer.one_shot = true
	drain_timer.start()
	
	water_level_process()
	water_meter.visible = false
	
func _process(delta):
	if mouse_over_meter and addition_timer.is_stopped():
		water_meter_update()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not finished_growing:
			water_level += 3.0
			water_meter_update()
			addition_timer.start()		

		
func _on_grow_timer_timeout():
	sprite.frame += 1 # Move to the next frame
	if sprite.frame < 3: # If the plant hasn't reached the last frame yet
		growth_timer.start() # Restart the timer
	else:
		finished_growing = true;
##Plant Water Logic
func water_level_process():
	if water_level < 0.2 * water_capacity and water_level > 0 and dying_timer.is_stopped():
		dying_timer.start() #Start the dying timer - queue freed
		growth_timer.stop() #Stop plant growth
		print("Dying state ACTIVE")
#	elif dying_timer.is_running():
#		dying_timer.stop()
#		print("Dying state Stopped")
	if water_level >= 0.2 * water_capacity and water_level < 0.5 * water_capacity and not multiplier_applied:
		growth_timer.start()#Restart plant growth
		dying_timer.stop()#Stop dying timer
		print("Dying state INACTIVE")
		time_grow *= dry_multiplier #Apply dry multipler to time
		growth_timer.wait_time = time_grow
		multiplier_applied = true
		print("Time to Grow (Dry): " , time_grow)
	elif water_level >= 0.5 * water_capacity and water_level < 0.7 * water_capacity and multiplier_applied:
		dying_timer.stop()#Stop dying timer
		print("Dying state INACTIVE")
		time_grow = original_time_to_grow
		growth_timer.wait_time = time_grow
		multiplier_applied = false
		print("Time to Grow (Normal): " , time_grow)
	elif water_level >= 0.7 * water_capacity and not multiplier_applied:
		dying_timer.stop()#Stop dying timer
		print("Dying state INACTIVE")
		time_grow *= wet_multiplier
		growth_timer.wait_time = time_grow
		multiplier_applied = true
		print("Time to Grow (Wet): " , time_grow)

	# Update the water level after processing (for example, reducing it over time or due to some other mechanic)
	# water_level -= some_value

func water_meter_update():
	var frame = 9 - int((water_level / water_capacity) * 10) # Reverse the frame calculation

	# Ensure frame is within valid range
	frame = clamp(frame, 0, 9)
	# Set the sprite's frame based on water level
	water_meter.get_node("Sprite2D").frame = frame

func _on_dying_timer_timeout():
	print("Plant has died")
	plant.queue_free()


func _on_status_timer_timeout():
	water_level_process()
	print("_on_status_timer_timeout() : Checking water Level")
	status_timer.start()
	
	if sprite.frame >= 3:
		print("Plant finished growing - all timers stopped")
		plant_harvestable = true
		drain_timer.stop()
		status_timer.stop()
		growth_timer.stop()  


func _on_drain_timer_timeout():
	water_level-=1
	if water_level < 0 : water_level = 0
	print("water: " , water_level)
	drain_timer.start()


func _on_mouse_area_mouse_shape_entered(shape_idx):	
	if player.equipped_item_name == "watering can":
		water_meter_update()
		water_meter.visible = not finished_growing
		mouse_over_meter = true
		sprite.material.set_shader_parameter("line_scale", 1.0)
		


func _on_mouse_area_mouse_shape_exited(shape_idx):
	water_meter.visible = false
	mouse_over_meter = false
	sprite.material.set_shader_parameter("line_scale", 0.0)

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		can_water = true
		if mouse_over_meter:
			sprite.material.set_shader_parameter("line_scale", 1.0)



func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		can_water = false
		water_meter.visible = false
		mouse_over_meter = false
		sprite.material.set_shader_parameter("line_scale", 0.0)
