extends Node2D
@onready var canvas_layer = $Level/UserInterface
@onready var ui = $Level/UserInterface/DayNightCycleUI
@onready var canvas_modulate = $Level/CanvasModulate

func _on_ready():
	canvas_layer.visible = true
	canvas_modulate.time_tick.connect(ui.set_daytime)
	
