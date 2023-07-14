extends CharacterBody3D


signal hpchange(hpvalue)
@onready var player = $"."
@onready var camera = $Camera3D
var SPEED = 5.0
const JUMP_VELOCITY = 12
var rp = true
@onready var clicktimer = $ClickTimer
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20
var canclick = true
var hp = 3
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
		SPEED = 7
	if is_on_floor():
		SPEED = 5
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
				

	if Input.get_action_strength("grap"):
		if cangrapple == true:
			if gray.is_colliding():
				find_point()
			if not collision_point == null:
				if not grappling == true:
					grappling = true
					
				if grappling == true:
					dashpart.visible = true
					line(righthand.global_position, collision_point)
					var dir = camera.global_position.direction_to(collision_point)
					velocity = dir * 15

					
			
			move_and_slide()
	
	
	if grappling == false:
		hookpoint = false
		collision_point = null
		dashpart.visible = false
		
	if Input.is_action_just_released("grap"):
		grappling = false
		cangrapple = false
		graptimer.start()

	
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
func receivedam():
	hp -= 1
	print(hp)
	if hp <= 0:
		hp = 3
		position = Vector3.ZERO
	hpchange.emit(hp)



func _on_hitdelaytimer_timeout():
	if ray.is_colliding():
		var hit_player = ray.get_collider()
		hit_player.receivedam.rpc_id(hit_player.get_multiplayer_authority())


func find_point():
	if not hookpoint:
		collision_point = gray.get_collision_point()
		hookpoint = true









func _on_grap_timer_timeout():
	print("u can shoot")
	cangrapple = true
	pass # Replace with function body.



func line(pos1: Vector3, pos2: Vector3, color = Color.DARK_KHAKI) -> MeshInstance3D:
	
	
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()	
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	get_tree().get_root().add_child(mesh_instance)
	
	await get_tree().create_timer(.1).timeout
	mesh_instance.queue_free()
	
	return mesh_instance



