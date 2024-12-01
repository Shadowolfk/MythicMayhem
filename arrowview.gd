extends RigidBody3D


var ownerplayer = null
const SPEED = 30

func _ready():
	$Timer.start()
	apply_impulse(transform.basis.x * SPEED, -transform.basis.x * SPEED)

func _physics_process(delta):

	
	pass







func _on_area_3d_2_body_entered(body):
	queue_free()
	
	pass # Replace with function body.


func _on_timer_timeout():
	queue_free()
	
	pass # Replace with function body.
