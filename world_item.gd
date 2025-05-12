#worlditem -> represents items dropped in the 3D world 
extends Area3D
class_name WorldItem

@export var itemData: Resource 
@onready var player = $"../Player"
@onready var label = $Label
@onready var mesh = $MeshInstance3D
@onready var collisionBox = $CollisionShape3D
@onready var playerInventory 
var playerInRange 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var meshHeight = mesh.get_aabb().size.y #get the height of the itemMesh
	var transform = mesh.scale.y #obtain the transform of the mesh 
	label.position.y = (meshHeight*transform)/2 + 0.1 #set the height of the label to an appropriate height
	connect("body_entered", Callable(self, "_onHover")) #connect to some basic area3D functions
	connect("body_exited", Callable(self, "_onExit"))
	label.text = itemData.item_name #update label text
	mesh.mesh = itemData.mesh #update item mesh
	mesh.material_override = itemData.material #update item material
	collisionBox = itemData.mesh #update item collision hitbox
	label.visible = false #label is inherently invisble 

func _onHover(body: Node) -> void: 
	if body.name == "Player":
		label.visible = true #show label when player is within range 
		playerInRange = body
		playerInventory = playerInRange.get_node_or_null("Inventory") #obtain the inventory of the player 
		
func _onExit(body: Node) -> void: #intuitive. 
	if body.name == "Player":
		label.visible = false
		playerInRange = null
		

func _process(delta: float) -> void:
	#im not totally sure how this code works, but it just constantly turns the label to look at the user
	var cam = get_viewport().get_camera_3d()
	if cam:
		label.look_at(cam.global_transform.origin, Vector3.UP)
		label.rotate_object_local(Vector3.UP, PI)
	
	#user pickup code 
	if Input.is_action_just_pressed("interact") and playerInRange == player:
			playerInventory.addItems(itemData) #runs the addItems function and deletes the world item 
			queue_free()
			
func _turnIntoCoin(): #this is code for the sell pad, it just transforms the items into coins to pick up. can be edited.
	for i in range(itemData.sellPrice):
		var dente = preload("res://items/dente.tres") 
		var itemScene = preload("res://scenes/world_item.tscn")
		var instance = itemScene.instantiate()
		instance.itemData = dente
		player.get_parent().add_child(instance)
		var offset = Vector3(randf_range(-0.3, 0.3), randf_range(0, 0.5), randf_range(-0.3, 0.3))
		instance.global_position = player.global_position + offset
	queue_free()
