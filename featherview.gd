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
		
