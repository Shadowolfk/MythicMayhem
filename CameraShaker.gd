extends Camera3D


@export var randomStrength: float = 30
@export var shakeFade: float = 5

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func apply_shake():
	shake_strength = randomStrength
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shakeFade * delta)
		h_offset = randomOffset()/10
		v_offset = randomOffset()/10
	
	pass

func randomOffset():
	return rng.randf_range(-shake_strength, shake_strength)
	
