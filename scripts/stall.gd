extends StaticBody3D
@onready var sellArea = $Area3D
signal turnIntoCoin

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sellArea.monitoring = true
	sellArea.area_entered.connect(Callable(self, "_sellObject"))

func _sellObject(item: WorldItem):
	if item.itemData.item_name != "Dente":
		self.turnIntoCoin.connect(Callable(item, "_turnIntoCoin"))
		emit_signal("turnIntoCoin")
	
