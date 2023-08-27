extends Node3D

@onready var raycast = get_parent()
@onready var raycastowner = get_parent().get_owner()
@onready var cam = preload("res://camera.tscn")
@onready var daecam = $"../../../SubViewport/daedcam"
var oncam = false
@onready var view = $"../../Sprite3D"
var canusecam = true
var c = null
var thereisacam = false
@onready var camtimer = $"../../../CamTimer"
@onready var cd = $"../../../Control/CamCooldownabar"
# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	global_transform.origin = raycast.get_collision_point()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if not is_multiplayer_authority(): return

	if is_visible_in_tree():
		if canusecam == true:
			if Input.is_action_just_pressed("altclick"):

					
				if thereisacam == false:
					c = cam.instantiate()
					print("fy")
					c.global_transform = global_transform
					get_tree().get_root().add_child(c)
					hide()
					thereisacam = true
					daecam.global_transform = c.global_transform
					daecam.rotate_y(160)
					canusecam = false
					camtimer.start()
					return
				else:
					c.global_transform = global_transform
					daecam.global_transform = c.global_transform
					daecam.rotate_y(160)
					hide()
					canusecam = false
					camtimer.start()
	else :
		if Input.is_action_just_pressed("altclick"):
			if oncam == false:
				view.visible = true
				oncam = true
			else:
				view.visible = false
				oncam = false



			
			
		
func _process(delta):
	global_transform.origin = raycast.get_collision_point()
	rotation = raycastowner.rotation
	cd.value = camtimer.time_left

func _on_cam_timer_timeout():
	canusecam = true
	pass # Replace with function body.
