extends CharacterBody3D

signal fighting
@onready var charsel = $"Char Select"


func _on_midas_pressed():
	set_script(load("res://midas.gd"))
	charsel.hide()

	fighting.emit()
	pass # Replace with function body.


func _on_daedalus_pressed():
	set_script(load("res://daed.gd"))
	charsel.hide()

	fighting.emit()
	pass # Replace with function body.
