extends CharacterBody3D

#INHERENT ATTRIBUTES
var speed = 3
const JUMP_VELOCITY = 3.5
const SENSITIVITY = 0.003
const SPRINT_MULTIPLIER = 2
var isSprint = false
var stamina = 100
var sprintLock = false #you can't sprint for a little bit 
#HEAD BOB
const BOB_FREQ = 4
const BOB_AMP = 0.1
var t_BOB = 0.0
#FOV
const BASE_FOV = 75
const FOV_CHANGE = 8.0
#GAME VARIABLES
var inventoryMode = false
#SCENE REFERENCE
@onready var head = $Head
@onready var camera = $Head/Camera
@onready var inventoryItem = $"Player/Inventory/InventoryItem"
#SIGNALS
signal toggleInventory



func _ready(): 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #this captures the mouse cursor, preventing it from leaving the window
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and !$Inventory.inventoryShown:
		head.rotate_y(-event.relative.x * SENSITIVITY) #rotate across y axis according to the x movement of the mouse
		camera.rotate_x(-event.relative.y * SENSITIVITY) #rotate across x axis according to the y movement of the mouse 
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		emit_signal("toggleInventory") #toggle inventory 

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	#DROP ITEM
	if Input.is_action_just_pressed("drop"):
		drop_item()
	#JUMP
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and stamina>25:
		velocity.y = JUMP_VELOCITY
		stamina-=20
	#MOVEMENT CHECK
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	#SPRINT CHECK
	if Input.is_action_pressed("sprint") and (Input.is_action_pressed("forward") != Input.is_action_pressed("backward")) and stamina>25 and not sprintLock:
		isSprint = true #check for sprint
	else: isSprint = false
	
	
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed 
			velocity.z = direction.z * speed * movementModifier(stamina)
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta*2.0)
		velocity.z = lerp(velocity.z, direction.z * speed * movementModifier(stamina), delta*2.0)
		
	#HEAD BOB
	t_BOB += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headBOB(t_BOB) 
	
	#FOV CHANGE
	var target_fov = BASE_FOV
	if isSprint:
		target_fov += FOV_CHANGE #ZOOMS OUT CAMERA WHEN SPRINTING
	if sprintLock:
		target_fov -= FOV_CHANGE #ZOOMS IN CAMERA WHEN TIRED
	camera.fov = lerp(camera.fov, float(target_fov), delta * 8.0)
	
	#STAMINA MANAGEMENT
	if not isSprint: 
		if (stamina<100):
			stamina+=delta*10
			if stamina>50: 
				sprintLock = false
	else: 
		stamina-=delta * 13
		if stamina<25:
			sprintLock = true
			

		
	move_and_slide() #godot's built in move and slide function 

func _headBOB(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP * movementModifier(stamina)/2
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP * movementModifier(stamina)/2
	return pos

func movementModifier(stamina):
	if isSprint: 
		return 1.5 
	if stamina<25:
		return 0.9 
	else: return 1 

#ITEM SWAP WHEN THE PLAYER IS EQUIPPING A NEW ITEM 
func _itemSwap(item: InventoryItem):
	if ($Inventory.itemEquipped==null): #if user is not holding an item 
		$Inventory.itemEquipped = item.itemData #set the item equipped to the item data of the parameter
		#instantiate an EQUIPPED ITEM 
		var itemScene = preload("res://scenes/equipped_item.tscn")
		var instance = itemScene.instantiate()
		instance.itemData = item.itemData
		instance.inventory = $Inventory
		instance.player = self
		$Head.add_child(instance) #add it as a child of the head so always in FOV 
		var offset = Vector3(1, -0.7, -0.5) #offset slightly
		instance.transform.origin = offset
	else: #if the user is holding an item 
		var previousItem = $Inventory.itemEquipped #store previously used item for further use
		$Inventory.itemEquipped = item.itemData #set new item to the item equipped 
		$Head/EquippedItem.itemData = item.itemData #update item information
		$Head/EquippedItem.updateMesh()
		$Inventory.addItems(previousItem) #return previous item to the inventory
		
		
func drop_item():
	if ($Inventory.itemEquipped!=null):
		var droppedItemData = $Inventory.itemEquipped #store the item to be dropped's data
		$Inventory.itemEquipped = null #set item equipped to null value 
		$Head/EquippedItem.queue_free() #delete the held item
		#EJECTION CODE (turn into world item) 
		var itemScene = preload("res://scenes/world_item.tscn")
		var instance = itemScene.instantiate()
		instance.itemData = droppedItemData
		get_parent().add_child(instance)
		instance.global_position = global_position 
	
