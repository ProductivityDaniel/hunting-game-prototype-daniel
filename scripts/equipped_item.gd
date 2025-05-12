#equipped item: is to serve as an intermediate between item behaviour and everything else
extends MeshInstance3D
@export var itemData: Resource = null
@onready var player 
@onready var inventory 

func _ready() -> void:
	mesh = itemData.mesh #apply mesh onto the equipped item 
	material_override = itemData.material #apply material 
	if itemData.behaviour!=null: #if the item has behaviour, instantiate the scene containing the behaviour
		var instance = itemData.behaviour.instantiate()
		instance.inventory = inventory
		instance.player = player
		add_child(instance)
		
		

func updateMesh(): #function to update mesh and stuff whenever called 
	mesh = itemData.mesh
	material_override = itemData.material
	
