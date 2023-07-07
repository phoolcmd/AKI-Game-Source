extends Node2D
@onready var canvas_layer = $UserInterface
@onready var ui = $UserInterface/DayNightCycle
@onready var canvas_modulate = $CanvasModulate

func _on_ready():
	pass
	#canvas_layer.visible = true
	#canvas_modulate.time_tick.connect(ui.set_daytime)
	
