extends CharacterBody3D


signal hpchange(hpvalue)
@onready var player = $"."
@onready var camera = $Camera3D
var SPEED = 7.7
var JUMP_VELOCITY = 15
var rp = true
@onready var clicktimer = $ClickTimer
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20
var canclick = true
var hp = 60
var max_hp = 60
@onready var ray = $Camera3D/RayCast3D
@onready var hitdelaytimer = $Hitdelaytimer
@onready var envir = "res://environment.tscn"
@onready var gray = $Camera3D/Grapcast
var collision_point = null
var grappling
var cangrapple = true

var hookpoint
@onready var graptimer = $GrapTimer
@onready var righthand = $Armature/Skeleton3D/Cube018/Cube018
@onready var dashpart = $CPUParticles3D


func _enter_tree():
	set_multiplayer_authority(str(name).to_int())


func _ready():
	if not is_multiplayer_authority(): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	camera.current = true


func _unhandled_input(event):
	if not is_multiplayer_authority(): return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)



func _physics_process(delta):
	if not is_multiplayer_authority(): return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta * 2

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("click"):
		if canclick == true:
			if rp ==true:
				$AnimationPlayer.play("Punch1")
				rp = false
				canclick = false
				clicktimer.start()
				hitdelaytimer.start()
			else:
				$AnimationPlayer.play("Punch2")
				rp = true
				canclick = false
				clicktimer.start()
				hitdelaytimer.start()
				

	

	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backword")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if $AnimationPlayer.is_playing():
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			$AnimationPlayer.play("Run")
	else:
		if $AnimationPlayer.is_playing():
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			$AnimationPlayer.play("Idle")
	
	
	move_and_slide()


func _on_click_timer_timeout():
	canclick = true





@rpc("any_peer")
func midaspunchdamage():
	hp -= 150
	print(hp)
	$Control/ProgressBar.value = hp
	if hp <= 0:
		die()
	hpchange.emit(hp)

@rpc("any_peer")
func midasshotdamage():
	hp -= 10
	print(hp)
	$Control/ProgressBar.value = hp
	if hp <= 0:
		die()
	hpchange.emit(hp)

func _on_hitdelaytimer_timeout():
	if ray.is_colliding():
		var hit_player = ray.get_collider()



func die():
	hp = max_hp
	position = Vector3.ZERO
	$Control/ProgressBar.value = hp


func _on_hpchange(hpvalue):
	$Control/ProgressBar.value = hpvalue
	pass # Replace with function body.


