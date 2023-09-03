extends RigidBody3D
var moving = true
var ownerplayer = null
var hera = preload("res://heracl.tscn")
@onready var tppoint = $Node3D

const  SPEED = 30
# Called when the node enters the scene tree for the first time.
func _ready():

	if moving == true:
		apply_impulse(transform.basis.x * SPEED, -transform.basis.x * SPEED)


		
	
	pass # Replace with function body.
func _process(delta):

	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if moving == false:
		linear_velocity = Vector3(0,0,0)
	
	pass


func _on_spearea_body_entered(body):
	if visible:
		body.herspear.rpc_id(body.get_multiplayer_authority())
		ownerplayer.notify_player1()
	pass # Replace with function body.

func _on_spearea_2_body_entered(body):
	moving = false
	
	pass # Replace with function body.`





func _on_visible():
	sleeping = true
	apply_impulse(transform.basis.x * SPEED, -transform.basis.x * SPEED)
	moving = true
	pass # Replace with function body.
