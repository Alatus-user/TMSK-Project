extends Node
class_name Inventory
var current_item : ItemData = RUSTY_SWORD

const RUSTY_SWORD = preload("uid://5o8gd6yplh7r")


func _ready() -> void:
	print("You Have ", current_item.item_name)
	print(current_item)
	print("Class:", current_item.get_class())
	print("Script:", current_item.get_script())
	
func add_item(new_item : ItemData):
	if current_item:
		print("Replacing ", current_item.item_name, " with ", new_item.item_name)
	current_item = new_item

func has_item() -> bool:
	return current_item != null

func get_item() -> ItemData:
	return current_item
