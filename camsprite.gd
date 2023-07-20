extends Node3D

@onready var raycast = get_parent()
@onready var raycastowner = get_parent().get_owner()
@onready var cam = preload("res://camera.tscn")


var c = null
var thereisacam = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	global_transform.origin = raycast.get_collision_point()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
		
	if Input.is_action_just_pressed("altclick"):
		
		if thereisacam == false:
			c = cam.instantiate()
			print("fy")
			c.global_transform = global_transform
			get_tree().get_root().add_child(c)
			hide()
			thereisacam = true
			return
		else:
			c.global_transform = global_transform
			hide()

	



			
			
		
func _process(delta):
	global_transform.origin = raycast.get_collision_point()
	rotation = raycastowner.rotation
