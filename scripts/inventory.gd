#inventory -> overall script to manage inventory contents and scene 

extends Node
class_name Inventory 

@export var space: int 
var items: Array = [] #list of items you have 
var itemsInContainer: Array = [] #list of items in container 
var itemEquipped = null #equipped item 
@onready var player = get_parent()
var inventoryShown := false
@onready var validInventoryArea = $Container/Area2D 


func _ready() -> void:
	player.connect("toggleInventory", Callable(self, "_toggleInventoryMenu")) #connect to a signal in player to open the inventory

func _toggleInventoryMenu():
	if inventoryShown:
		inventoryShown = false
	else:
		inventoryShown = true

func _process(delta: float) -> void:
	itemsInContainer = validInventoryArea.get_overlapping_bodies() #find the items in the valid area using the area3D
	if inventoryShown:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) #set mouse to visible
		self.visible = true #show the 2D scene when inventory is toggled 
	else:#if the inventory is closed, go through the inventory and identify any items outside of the container, then eject them. 
		for thing in items: #go through items and identify any items not in container
			if thing not in itemsInContainer:
				eject(thing) #eject it out into a WORLDITEM 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		self.visible = false #make the inventory invisble and mouse captured 
	

func addItems(item: Resource) -> void: #add items function 
	inventoryShown = true #show the inventory automatically (this can be modified probably!!)
	#instantiate an INVENTORY ITEM with the itemData specified  
	var itemScene = preload("res://scenes/inventory_item.tscn") 
	var instance = itemScene.instantiate()
	instance.itemData = item
	add_child(instance)
	items.append(instance)
	instance.connect("itemswap", Callable(player, "_itemSwap")) #connect the newly instantiated item to the signal "itemSwap" so that it is equippable

	
func removeItems(item: InventoryItem) -> void: #remove the item
	items.remove_at(items.find(item)) #remove it. 
	item.queue_free() #delete it. 
	
			
func eject(item: InventoryItem) -> void: #eject: TURNS THE ITEM INTO A WORLDITEM 
	var itemInformation = item.itemData #store itemData in a temporary variable (i don't actually know if this is necessary) 
	removeItems(item) #delete the item 
	#instantiate a WORLD ITEM with the itemData specified 
	var itemScene = preload("res://scenes/world_item.tscn") 
	var instance = itemScene.instantiate()
	instance.itemData = item.itemData
	player.get_parent().add_child(instance)
	var offset = Vector3(randf_range(-2, 2), 0, randf_range(-2, 2)) #add a small positional offset
	instance.global_position = player.global_position + offset

	
