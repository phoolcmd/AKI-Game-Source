extends CanvasLayer
var holding_item = null


func _input(event):
	if event.is_action_pressed("inventory"):
		$Inventory.visible = !$Inventory.visible
		$Inventory.initialize_inventory()
	if event.is_action_pressed("scroll_up"):
		print("scrolling up")
		PlayerInventory.active_item_scroll_up()
	elif event.is_action_pressed("scroll_down"):
		print("scrolling down")
		PlayerInventory.active_item_scroll_down()
func _ready():
	pass
	
func _process(delta):
	pass
