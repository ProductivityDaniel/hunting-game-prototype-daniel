#inventory item -> script for an item's behaviour when it is in your inventory 

extends RigidBody2D #extends a 2D rigidbody 
class_name InventoryItem

@export var itemData: Resource #access itemData from the .tres file associated with the item
@onready var sprite = $Texture
@onready var hitbox = $Hitbox
@onready var mousebox = $MouseDetectionBox
@onready var label = $Label
@onready var player = $Player
signal itemswap(itemToBeSwapped) #signal to equip the item 
signal removeItem(itemToBeRemoved) #signal to throw out the item 

var mouseHover = false #is the mouse hovering over the item? 
var dragging = true #is the mouse hovering over the item and the mouse is held down? 

func _ready() -> void:
	label.visible = false 
	sprite.texture = itemData.texture #load in the texture from .tres
	
	#HITBOX CODE - EXCEEDINGLY JANKY AT THE MOMENT
	var textureSize = itemData.texture.get_size() #get the size of the texture
	hitbox.shape.extents = textureSize/3 *0.85 #create a hitbox the size of the texture but a lot smaller
	
	label.text = itemData.item_name #load label text 
	mousebox.connect("mouse_entered", Callable(self, "_mouseEntered")) #connect mouse signals 
	mousebox.connect("mouse_exited", Callable(self, "_mouseExited")) 
	
#MOUSE DETECTION FUNCTIONS 
func _mouseEntered():
	mouseHover = true
func _mouseExited():
	mouseHover = false
	
func _process(delta: float) -> void:
	label.rotation = -self.rotation #THE ROTATION OF THE LABEL ALWAYS NEEDS TO COUNTERACT THE ITEMS BASE ROTATION TO MAINTAIN IN A HORIZONTAL FORM
	if mouseHover: 
		label.visible = true #label is made visible upon mouse contact
		if Input.is_action_pressed("use"): #if mouse pressed down 
				dragging = true
		if Input.is_action_just_pressed("equip"): 
			emit_signal("itemswap", self) #signal an itemswap
			get_parent().items.remove_at(get_parent().items.find(self)) #basically trying to remove the item from the inventory
			queue_free() #delete the item
	else:
		label.visible = false
	if dragging:
		set_freeze_enabled(true) #FREEZES RIGIDBODY PHYSICS TO ALLOW OVERRIDE
		global_position = get_global_mouse_position() #go to mouse when being dragging
		
		#ROTATION CODE SO THAT ITEM ROTATES WITH THE SCROLL WHEEL 
		if Input.is_action_just_pressed("cycleup"): 
			rotation += (PI/6)
			label.rotation -=PI/6
		if Input.is_action_just_pressed("cycledown"):
			rotation += (-PI/6)
			label.rotation += PI/6
			
		if not Input.is_action_pressed("use"):
			dragging = false
			set_freeze_enabled(false) #resumes rigidbody physics once mouse is let go 
	
	
