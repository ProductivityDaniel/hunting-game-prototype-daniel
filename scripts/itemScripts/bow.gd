extends Node
var charge = 0.0
const MINCHARGE = 1
const MAXCHARGE = 5
signal fireArrow(velocity)
var inventory
var player
var hasArrow

func _process(delta: float) -> void:
	hasArrow = inventory.items.any(func(i): return i.itemData.item_name == "Arrow")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var camera = player.get_node("Head/Camera")
	if (Input.is_action_pressed("use") and hasArrow):
		charge+=delta
		if charge>MAXCHARGE: charge = MAXCHARGE
		var velocity = charge/MAXCHARGE 
		camera.fov = 75 + velocity*20
	if (not Input.is_action_pressed("use") and charge>MINCHARGE):
		charge = 0
		camera.fov = lerp(camera.fov, float(75), delta * 8.0)
		for i in inventory.items:
				if i.itemData.item_name == "Arrow":
					inventory.removeItems(i)
					var origin = camera.global_transform.origin
					var direction = -camera.global_transform.basis.z  # Forward in -Z
					var space_state = get_viewport().world_3d.direct_space_state
					var ray_params = PhysicsRayQueryParameters3D.new()
					ray_params.from = origin 
					ray_params.to = origin + direction * 100
					ray_params.exclude = [player] 
					var result = space_state.intersect_ray(ray_params)
					if result:
						var hitPosition = result.position
						var item_scene = preload("res://scenes/world_item.tscn")
						var instance = item_scene.instantiate()
						instance.global_position = hitPosition
						instance.itemData = preload("res://items/arrow.tres")
						instance.look_at(player.global_transform.origin)
						player.get_parent().add_child(instance)
					else:
						print("Missed")
					
	if (not Input.is_action_pressed("use") and charge<MINCHARGE) or Input.is_action_just_pressed("equip"):
		charge = 0
		camera.fov = lerp(camera.fov, float(75), delta * 8.0)
		
