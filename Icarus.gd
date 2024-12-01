extends CharacterBody3D

#icarus
signal hpchange(hpvalue)
@onready var player = $"."
@onready var camera = $Camera3D
@export var SPEED = 7.7

@export var JUMP_VELOCITY = 15
var rp = true
@onready var clicktimer = $ClickTimer
# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var gravity = 15

var canclick = true
var hp = 75
var max_hp = 75

@onready var hitdelaytimer = $Hitdelaytimer
@onready var envir = "res://environment.tscn"

var collision_point = null
var grappling
var cangrapple = true
@onready var cdbar = $Control/CamCooldownabar
var hookpoint
@onready var ultlabel = $Control/RichTextLabel
@onready var righthand = $Armature/Skeleton3D/Cube018/Cube018
@onready var dashpart = $CPUParticles3D

var direction = Vector3.ZERO
@export var friction = 2

@onready var snipe = $Camera3D/SnipeShot
var isfloating = false
@onready var ray = $Camera3D/SnipeCast
@onready var jumptimer = $Juimer
var canjump = true
var canregen = true
@onready var regenstar = $reganstart
var supermaxhp = 75
var mat = load("res://mat.tres")
var bloody = load("res://blood.tres")
var fast_feathers = false
var wingmeter = 100
var feather = preload("res://feather.tscn")
var featherview = preload("res://featherview.tscn")
var canshoot = true
var canrebuildfeathersfromwax = true
var feathersfast = false
var cansprint = true
var isbuffed = false
var damagecounter = 100

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())


func _ready():
	if not is_multiplayer_authority(): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	cdbar.show()
	ultlabel.show()
	$Control/ProgressBar.show()
	camera.current = true
	$Control/ProgressBar2.show()

func _unhandled_input(event):
	if not is_multiplayer_authority(): return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)



func _physics_process(delta):
	if not is_multiplayer_authority(): return
	# Add the gravity.


	if canrebuildfeathersfromwax == true:
		if wingmeter >= 100:
			wingmeter = 100
			
		elif wingmeter < 0:
			wingmeter = 0
		else:
			wingmeter += .33
		
		
	$Control/ProgressBar2.value = wingmeter
	
	if not is_on_floor():
	
		var vel_y= velocity.y - gravity * delta * 5
		velocity.y = vel_y
		velocity = velocity.lerp(direction * SPEED, friction * delta)

	if is_on_floor():
		canjump = true
			
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() == false):
		if canjump == true:
			if wingmeter >= 33:
				wingmeter -= 33
				velocity.y = JUMP_VELOCITY 
				canjump = false
	#shoot
	if Input.get_action_strength("click"):
		canrebuildfeathersfromwax = false
		if canshoot == true:
			if wingmeter > 5:
				canshoot = false
				wingmeter -= 5
				shoot_feather_controller()
				await get_tree().create_timer(.1).timeout
				canshoot = true
		pass
	else: 
		canrebuildfeathersfromwax = true

	if Input.get_action_strength("shift") and wingmeter > 0 and cansprint == true:
		canrebuildfeathersfromwax = false
		wingmeter -= .33
		SPEED = 10.5
		feathersfast = true

		camera.fov = lerp(camera.fov, float(90), delta * 8)
		gravity = 0
	else:
		gravity = 15
		SPEED = 7.7

		camera.fov = lerp(camera.fov, float(75), delta * 8)
	
	if wingmeter == 0:
		cansprint = false
		$Timer.start()

	if Input.get_action_strength("grap") and damagecounter == 100:
		damagecounter = 0
		wingmeter = 100
		isbuffed = true
		$bufftimer.start()
		$Control/CamCooldownabar.value = damagecounter
	
	if isbuffed == true:
		wingmeter = 100
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
	wingmeter = 100
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






func _on_shift_timeout():

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
	

func shoot_feather_controller():
	var accuracy_x = 0.25
	var accuracy_y = 0.25
	var inaccuracy_x : float = randf_range(-accuracy_x / 2.0, accuracy_x / 2.0)
	var inaccuracy_y : float = randf_range(-accuracy_y / 2.0, accuracy_y / 2.0)
		# Get direction vector
	

		# Apply inaccuracy for X axis
	var direction : Vector3 = -$Camera3D/SnipeCast.global_transform.basis.z.normalized()
	direction = direction.rotated(Vector3.UP, inaccuracy_x)
		# Apply inaccuracy for Y axis
	direction = direction.rotated(Vector3.RIGHT, inaccuracy_y)
	shootfeather(direction)
	shootfeatherview.rpc(direction)
	pass


func shootfeather(dir):
	var bullet = feather.instantiate()
	bullet.set_linear_velocity(dir * 50)
	get_parent().add_child(bullet, true)
	bullet.ownerplayer = self
	bullet.global_transform = $Camera3D/featherspawn.global_transform
	pass

@rpc("call_local")
func shootfeatherview(dir):
	var bullet = featherview.instantiate()

	bullet.set_linear_velocity(dir * 50)
	get_parent().add_child(bullet, true)
	bullet.ownerplayer = self
	bullet.global_transform = $Camera3D/featherspawn.global_transform
	pass



func notify_player1():
	$AudioStreamPlayer.play()
	$Camera3D/hitdetect.visible = true
	await get_tree().create_timer(.1).timeout
	$Camera3D/hitdetect.visible = false
	if isbuffed == false:
		if not damagecounter == 100:
			damagecounter += 10
			if damagecounter > 100:
				damagecounter = 100
			$Control/CamCooldownabar.value = damagecounter
	else:
		return


func _on_timer_timeout():
	cansprint = true
	pass # Replace with function body.


func _on_bufftimer_timeout():
	isbuffed = false
	pass # Replace with function body.
