extends CharacterBody3D


signal hpchange(hpvalue)
@onready var player = $"."
@onready var camera = $Camera3D
@export var SPEED = 7
@export var JUMP_VELOCITY = 30
var rp = true
@onready var clicktimer = $ClickTimer
# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var gravity = 15

var canclick = true
var hp = 100
var max_hp = 100
@onready var righthand = $Armature/Skeleton3D/Cube018/Cube018

@onready var envir = "res://environment.tscn"

var collision_point = null
var grappling
var cangrapple = true
@onready var cdbar = $Control/CamCooldownabar
var hookpoint
@onready var ultlabel = $Control/RichTextLabel

@onready var dashpartic = $CPUParticles3D
signal first_time
var direction = Vector3.ZERO
@export var friction = 5
var firsttime = false
@onready var snipe = $Camera3D/SnipeShot

@onready var ray = $Camera3D/SnipeCast
@onready var jumptimer = $Juimer
var bullet = preload("res://herarrow.tscn")
var canregen = true
@onready var regenstar = $reganstart
var supermaxhp = 100
@onready var arrowspawn = $Camera3D/arrowspawn
var shots = 2
var spear = true
var spearr = preload("res://spear.tscn")
var s = spearr.instantiate()
var silly = false
signal sperible
var candash = true
var damagecounter = 75



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



func _physics_process(delta):
	if not is_multiplayer_authority(): return
	$Control/CamCooldownabar.value = damagecounter
	# Add the gravity.
	if not is_on_floor():
		var vel_y= velocity.y - gravity * delta * 5
		velocity.y = vel_y
		velocity = velocity.lerp(direction * SPEED, friction * delta)

			
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():

		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("click"):
		if shots > 0:
			shoot_arrow()
			shots -= 1
			if shots == 0:
				$shottimer.start()
		pass
	if Input.is_action_just_pressed("altclick"):
		if spear == true:
			shoot_spear()
			spear = false
		else:
			var distance = abs($".".global_position - s.global_position)
			
			if distance < Vector3(2,2,2):
				s.hide()
				spear = true
				silly = false
			pass
	
	if Input.is_action_just_pressed("grap"):
		if damagecounter == 75:
			if silly == true:
				global_position = s.global_position
				damagecounter -= 75
				$Control/CamCooldownabar.value = damagecounter
	if Input.is_action_just_pressed("shift"):
		if candash == true:
			gravity = 0
			SPEED = 60
			dashpartic.visible = true
			await get_tree().create_timer(.1).timeout
			SPEED = 8.4
			gravity = 15
			dashpartic.visible = false
			candash = false
			await get_tree().create_timer(3).timeout
			candash = true
		pass

	
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
	
	move_and_slide()



func _on_click_timer_timeout():
	canclick = true



@rpc("any_peer")
func daehs():
	hp -= 80
	max_hp -= 40
	print(hp)
	$Control/ProgressBar.value = hp
	if hp <= 0:
		die()
	hpchange.emit(hp)
	canregen = false
	regenstar.start()

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

@rpc("any_peer")
func midasshotdamage():
	hp -= 10
	print(hp)
	$Control/ProgressBar.value = hp
	if hp <= 0:
		die()
	hpchange.emit(hp)
	canregen = false
	regenstar.start()


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

func die():
	max_hp = supermaxhp
	hp = max_hp
	position = Vector3.ZERO
	$Control/ProgressBar.value = hp
	s.hide()
	spear = true
	silly = false

func _on_hpchange(hpvalue):
	$Control/ProgressBar.value = hpvalue
	pass # Replace with function body.



func shoot_spear():
	silly = true
	s.global_transform = $Camera3D/Speawn.global_transform
	
	if firsttime == false:
		get_tree().get_root().add_child(s)
		emit_signal("first_time")
		s.ownerplayer = self
	s.show()


func shoot_arrow():
	
	var a = bullet.instantiate()
	a.global_transform = arrowspawn.global_transform
	
	get_tree().get_root().add_child(a)
	a.ownerplayer = self
	pass
		
	


func _on_hpregentimer_timeout():
	if canregen == true:
		if not hp == max_hp:
			hp += 35
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


func _on_shottimer_timeout():
	shots = 2
	pass # Replace with function body.


func _on_first_time():
	firsttime = true
	pass # Replace with function body.

func notify_player1():
	
	if not damagecounter == 75:
		damagecounter += 50
		if damagecounter > 75:
			damagecounter = 75
		$Control/CamCooldownabar.value = damagecounter
	else:
			
			return
		
func notify_player2():
	if not damagecounter == 75:
		damagecounter += 25
		if damagecounter > 75:
			damagecounter = 75
		$Control/CamCooldownabar.value = damagecounter
	else:
			
			return
