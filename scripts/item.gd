#item.gd -> a template of properties for all existing items
#this script serves as the template for all information stored for a certain item including what it looks like and stuff

extends Resource 
class_name Item 

@export var item_name: String #name of the item
@export var size: int #unused size variable. dont want to remove in fears of breaking something 
@export_multiline var description: String #description of the item, unused for the time being. 
@export var mesh: Mesh #3D mesh for item representation in 3D space 
@export var material: Material #texture of the 3D mesh 
@export var texture: Texture2D #2D texture for item representation in inventory 
@export var behaviour: PackedScene #BEHAVIOR NULL OR A SCENE TO BE RAN / REFERENCED LATER
@export var sellPrice: int #sell price of the item

#all of these items can be modified within the inspector 
