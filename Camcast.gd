extends RayCast3D

@onready var camsprite = $Camsprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if not is_multiplayer_authority(): return
	if Input.is_action_just_pressed("grap"):
		camsprite.show()
