extends RigidBody3D


var ownerplayer = null
const SPEED = 30
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	pass


func _on_area_3d_body_entered(body):
	queue_free()
	pass # Replace with function body.


func _on_area_3d_2_body_entered(body):
	if body == ownerplayer:
		return
	else:
		body.icarushot.rpc_id(body.get_multiplayer_authority())
		ownerplayer.notify_player1()
		queue_free()
	pass # Replace with function body.


func _on_timer_timeout():
	queue_free()
	pass # Replace with function body.
