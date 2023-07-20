extends CharacterBody3D


signal hpchange(hpvalue)
@onready var player = $"."
@onready var camera = $Camera3D
@export var SPEED = 8.4
@export var JUMP_VELOCITY = 15
var rp = true
@onready var clicktimer = $ClickTimer
# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var gravity = 20
var canclick = true
var hp = 150
var max_hp = 150
@onready var ray = $Camera3D/RayCast3D
@onready var hitdelaytimer = $Hitdelaytimer
@onready var envir = "res://environment.tscn"
@onready var gray = $Camera3D/Grapcast
var collision_point = null
var grappling
var cangrapple = true
@onready var coinshot = $Camera3D/coinshot
var hookpoint
@onready var graptimer = $GrapTimer
@onready var righthand = $Armature/Skeleton3D/Cube018/Cube018
@onready var grappart = $grappart
@onready var coincast = $Camera3D/coincast
var candash = true
@onready var dashpartic = $dashpart
var grapcd = 0
var direction = Vector3.ZERO
@export var friction = 2

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

func _process(delta):
	grapcd = max(0, grapcd - delta)
	$Control/GrapCooldownabar.value = grapcd


func _physics_process(delta):
	if not is_multiplayer_authority(): return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta * 2

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("altclick"):
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
				
	if Input.is_action_just_pressed("click"):
		if canclick == true:
			if coincast.is_colliding():
					var hit_player = coincast.get_collider()
					hit_player.midasshotdamage.rpc_id(hit_player.get_multiplayer_authority())
					grapcd -= 2
					coinshot.visible = true
					canclick = false
					
					await get_tree().create_timer(.1).timeout
					coinshot.visible = false
					
					await get_tree().create_timer(.25).timeout
					canclick = true
			else: 
			
				coinshot.visible = true
				await get_tree().create_timer(.1).timeout
				coinshot.visible = false
		
		
		pass

	if Input.get_action_strength("grap"):
		if grapcd <= 0:
			if gray.is_colliding():
				find_point()
			if not collision_point == null:
				if not grappling == true:
					grappling = true
					
				if grappling == true:
					grappart.visible = true
					line(righthand.global_position, collision_point)
					var dir = camera.global_position.direction_to(collision_point)
					velocity = dir * 17

					
			
			move_and_slide()
	
	
	if grappling == false:
		hookpoint = false
		collision_point = null
		grappart.visible = false
		
	if Input.is_action_just_released("grap"):
		grappling = false
		cangrapple = false
		if grapcd <= 0:
			grapcd = 10


	if Input.is_action_just_pressed("shift"):
		if candash == true:
			SPEED = 30
			dashpartic.visible = true
			await get_tree().create_timer(.1).timeout
			SPEED = 8.4
			dashpartic.visible = false
			candash = false
			await get_tree().create_timer(3).timeout
			candash = true
	
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("Backword") - Input.get_action_strength("Forward")
	var h_input = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	if direction:
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("Run")
	else:
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("Idle")
	if is_on_floor():
		velocity = velocity.lerp(direction * SPEED, friction * delta)
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
		hit_player.midaspunchdamage.rpc_id(hit_player.get_multiplayer_authority())


func find_point():
	if not hookpoint:
		collision_point = gray.get_collision_point()
		hookpoint = true




func die():
	hp = max_hp
	position = Vector3.ZERO
	$Control/ProgressBar.value = hp




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






func _on_hpchange(hpvalue):
	$Control/ProgressBar.value = hpvalue
	pass # Replace with function body.
