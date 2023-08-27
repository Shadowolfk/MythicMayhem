extends Node
const midas = preload("res://player.tscn")
const daed = preload("res://daed.tscn")
var char = 1
# Called when the node enters the scene tree for the first time.
func _ready():


	pass




func add_player():
	if char == 1:
		print("Mid")
		var player = midas.instantiate()

		add_child(player)

	if char == 2:
		print("dae")
		var player = daed.instantiate()
		add_child(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




func _on_button_pressed():
	char = 1 
	add_player()
	pass # Replace with function body.
