extends CharacterBody3D


signal hpchange(hpvalue)
@onready var player = $"."
@onready var camera = $Camera3D
@onready var cam2 = $SubViewport/daedcamholder/daedcam
@export var SPEED = 7.7
@export var JUMP_VELOCITY = 15
var rp = true
@onready var clicktimer = $ClickTimer
# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var gravity = 15

var canclick = true
var hp = 60
var max_hp = 60

@onready var hitdelaytimer = $Hitdelaytimer
@onready var envir = "res://environment.tscn"
@onready var gray = $Camera3D/camera_cast
var collision_point = null
var grappling
var cangrapple = true
@onready var cdbar = $Control/CamCooldownabar
var hookpoint
@onready var ultlabel = $Control/RichTextLabel
@onready var righthand = $Armature/Skeleton3D/Cube018/Cube018
@onready var dashpart = $CPUParticles3D
@onready var capsprite = $Camera3D/camera_cast/Camsprite
var direction = Vector3.ZERO
@export var friction = 2
@onready var view = $Camera3D/Sprite3D
@onready var snipe = $Camera3D/SnipeShot
var isfloating = false
@onready var ray = $Camera3D/SnipeCast
@onready var jumptimer = $Juimer
var canjump = true
var canregen = true
@onready var regenstar = $reganstart
var supermaxhp = 60
var mat = load("res://mat.tres")
var bloody = load("res://blood.tres")
@export var smoke : PackedScene



func _enter_tree():
	set_multiplayer_authority(str(name).to_int())


func _ready():
	if not is_multiplayer_authority(): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	cdbar.show()
	ultlabel.show()
	$Control/ProgressBar.show()
	camera.current = true
	

func _unhandled_input(event):
	if not is_multiplayer_authority(): return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		cam2.rotate_x(-event.relative.y * .005)
		cam2.rotation.x = clamp(cam2.rotation.x, -PI/2, PI/2)
		$SubViewport/daedcamholder.rotate_y(-event.relative.x * .005)




func _physics_process(delta):
	if not is_multiplayer_authority(): return
	# Add the gravity.
	if not is_on_floor():
		
		
		if isfloating == true:
			var vel_y = velocity.y - gravity * delta
			velocity.y = vel_y
			velocity = velocity.lerp(direction * SPEED, friction * delta)
		else:
			var vel_y= velocity.y - gravity * delta * 5
			velocity.y = vel_y
			velocity = velocity.lerp(direction * SPEED, friction * delta)

			
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():

		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("click"):
		shootdaed()

	
	if Input.is_action_just_pressed("shift") and is_on_floor():
		
		if canjump == true:
			deploysmoke.rpc()
			velocity.y = JUMP_VELOCITY * 2
			isfloating = true
			canjump = false
			jumptimer.start()

		return
		
	if Input.is_action_just_pressed("shift") and not is_on_floor():
		if isfloating == true:
			isfloating = false

	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("Backword") - Input.get_action_strength("Forward")
	var h_input = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	if direction:
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("running")
	else:
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("idling")
	
	

	if is_on_floor():
		velocity = velocity.lerp(direction * SPEED, friction * delta)

	if is_on_floor() and velocity.y <= 0:
		isfloating = false

	
	
	move_and_slide()
	


func _on_click_timer_timeout():
	canclick = true



@rpc("any_peer")
func daehs():
	hp -= 80
	max_hp -= 80
	print(hp)
	$Control/ProgressBar.value = hp
	if hp <= 0:
		die()
	hpchange.emit(hp)
	canregen = false
	regenstar.start()
	blood.rpc()

@rpc("any_peer")
func daebs():
	hp -= 40
	max_hp -= 40
	print(hp)
	$Control/ProgressBar.value = hp
	if hp <= 0:
		die()
	hpchange.emit(hp)
	canregen = false
	regenstar.start()
	blood.rpc()


@rpc("any_peer")
func midaspunchdamage():
	hp -= 150
	print(hp)
	$Control/ProgressBar.value = hp
	if hp <= 0:
		die()
	hpchange.emit(hp)
	canregen = false
	regenstar.start()
	blood.rpc()

@rpc("any_peer")
func midasshotdamage():
	hp -= 5
	print(hp)
	$Control/ProgressBar.value = hp
	if hp <= 0:
		die()
	hpchange.emit(hp)
	canregen = false
	regenstar.start()
	blood.rpc()


@rpc("any_peer")
func herarrow():
	hp -= 25
	print(hp)
	$Control/ProgressBar.value = hp
	if hp <= 0:
		die()
	hpchange.emit(hp)
	canregen = false
	regenstar.start()
	blood.rpc()

@rpc("any_peer")
func herspear():
	hp -= 50
	print(hp)
	$Control/ProgressBar.value = hp
	if hp <= 0:
		die()
	hpchange.emit(hp)
	canregen = false
	regenstar.start()
	blood.rpc()
	
@rpc("any_peer")
func icarushot():
	hp -= 10
	print(hp)
	$Control/ProgressBar.value = hp
	if hp <= 0:
		die()
	hpchange.emit(hp)
	canregen = false
	regenstar.start()
	blood.rpc()

func die():
	max_hp = supermaxhp
	hp = max_hp
	position = Vector3.ZERO
	$Control/ProgressBar.value = hp


func _on_hpchange(hpvalue):
	$Control/ProgressBar.value = hpvalue
	pass # Replace with function body.


@rpc("authority", "call_local", "reliable")
func blood():
	$Armature/Skeleton3D/Cube/Cube.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube002/Cube002.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube018/Cube018.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube019/Cube019.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube020/Cube020.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube021/Cube021.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube022/Cube022.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube017/Cube017.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube016/Cube016.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube015/Cube015.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube013/Cube013.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube014/Cube014.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube002/Cube002.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube003/Cube003.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube008/Cube008.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube006/Cube006.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube007/Cube007.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube005/Cube005.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube009/Cube009.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube010/Cube010.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube011/Cube011.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube012/Cube012.set_surface_override_material(0, bloody)
	$Armature/Skeleton3D/Cube004/Cube004.set_surface_override_material(0, bloody)
	await get_tree().create_timer(.1).timeout
	$Armature/Skeleton3D/Cube/Cube.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube002/Cube002.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube018/Cube018.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube019/Cube019.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube020/Cube020.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube021/Cube021.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube022/Cube022.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube017/Cube017.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube016/Cube016.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube015/Cube015.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube013/Cube013.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube014/Cube014.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube002/Cube002.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube003/Cube003.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube008/Cube008.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube006/Cube006.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube007/Cube007.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube005/Cube005.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube009/Cube009.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube010/Cube010.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube011/Cube011.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube012/Cube012.set_surface_override_material(0, mat)
	$Armature/Skeleton3D/Cube004/Cube004.set_surface_override_material(0, mat)



@rpc("call_local")
func deploysmoke():
	var smokepartic = smoke.instantiate()
	smokepartic.global_transform = global_transform
	smokepartic.emitting = true
	get_tree().current_scene.add_child(smokepartic)


func _on_juimer_timeout():

	canjump = true
	pass # Replace with function body.


func _on_hpregentimer_timeout():
	if canregen == true:
		if not hp == max_hp:
			hp += 20
			$Control/ProgressBar.value = hp
			print(hp)
		else:
			
			return
		if hp > max_hp:
			hp = max_hp
			$Control/ProgressBar.value = hp
			print(hp)
			$Hpregentimer.stop()
	
	
	pass # Replace with function body.


func _on_reganstart_timeout():
	print("timeout")
	$Hpregentimer.start()
	canregen = true
	pass # Replace with function body.
	

func shootdaed():
		if canclick == true:
			if ray.is_colliding():
				var shape_index = ray.get_collider_shape()
				var collision_shape_name = ray.get_collider().shape_owner_get_owner(shape_index).name
				var hit_player = ray.get_collider()
				match collision_shape_name:
					"body":
						hit_player.daebs.rpc_id(hit_player.get_multiplayer_authority())
						$Camera3D/hitdetect.visible = true
						$AudioStreamPlayer.play()
						shotfired.rpc()
						canclick = false
						await get_tree().create_timer(.1).timeout
						$Camera3D/hitdetect.visible = false
						clicktimer.start()
					"head":
						hit_player.daehs.rpc_id(hit_player.get_multiplayer_authority())

						
						canclick = false
						$AudioStreamPlayer2.play()
						$Camera3D/hitdetect.visible = true
						shotfired.rpc()
						await get_tree().create_timer(.1).timeout
						$Camera3D/hitdetect.visible = false
						clicktimer.start()
						
			else:
				shotfired.rpc()
				canclick = false
				clicktimer.start()

@rpc("call_local")
func shotfired():
	snipe.visible = true
	await get_tree().create_timer(.1).timeout
	snipe.visible = false
