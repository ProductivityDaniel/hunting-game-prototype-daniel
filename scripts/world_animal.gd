extends CharacterBody3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@export var animalData: Animal
@onready var animalMesh = $MeshInstance3D
@onready var animalHitbox = $CollisionShape3D
var health
var behaviour

func _ready() -> void:
	animalMesh.mesh = animalData.mesh
	animalHitbox.shape = animalData.mesh.create_convex_shape(true)
	animalMesh.material_override = animalData.material
	health = animalData.health
	behaviour = animalData.behaviour.new()

func _hurt(amount: int) -> void:
	health-=amount
	print("ouchie")
	if (health<0):
		_dead()
		
func _dead():
	pass
	
func _physics_process(delta: float) -> void:
	behaviour.wander(delta)
