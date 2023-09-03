extends RigidBody3D


var ownerplayer = null
const SPEED = 30



func _physics_process(delta):
	apply_impulse(transform.basis.x * SPEED, -transform.basis.x * SPEED)
	
	pass






func _on_area_3d_body_entered(body):
	
	body.herarrow.rpc_id(body.get_multiplayer_authority())
	ownerplayer.notify_player2()
	queue_free()
	pass # Replace with function body.


func _on_area_3d_2_body_entered(body):
	queue_free()
	
	pass # Replace with function body.


func _on_timer_timeout():
	queue_free()
	
	pass # Replace with function body.
