#Mülleimer

#@author Ivelin Ivanov

extends Node2D

signal eimer_mouse_over(a)

var mouse_over = false

#Anzahl entsorgter Spitzen in global speichern,
#um sie für das Messgerät leichter verfügbar zu machen
#da dort das Speichern der Assistentendatei stattfindet
func _spitze_entsorgt(a):
	if (a == "weiss"):
		global.mSpitzenWeiss += 1
	if (a == "gelb"):
		global.mSpitzenGelb += 1
	if (a == "blau"):
		global.mSpitzenBlau += 1


func _on_Eimer_mouse_entered():
	mouse_over = true
	if (global.maus == global.Pickable_Items.pipette):
		emit_signal("eimer_mouse_over", true)


func _on_Eimer_mouse_exited():
	mouse_over = false
	if (global.maus == global.Pickable_Items.pipette):
		emit_signal("eimer_mouse_over", false)

#Input Event Handler um den Mülleimer anzuheben und zu bewegen
func _input(event):
	if (mouse_over && event is InputEventMouseButton && event.is_pressed()):
		if (event.button_index == BUTTON_RIGHT && global.maus == global.Pickable_Items.tube):
			global.maus = global.Pickable_Items.maus
			global.activeTube = null
			global.mTubes += 1
			get_parent().get_node("Tube").visible = false
			get_parent().get_node("Tube").set_z_index(0)
			Input.set_mouse_mode(0)
		if (Input.is_action_pressed("ctrl") && event.button_index == BUTTON_LEFT && global.maus == global.Pickable_Items.maus):
			global.maus = global.Pickable_Items.muelleimer
			Input.set_mouse_mode(1)
			set_z_index(1)
		if (event.button_index == BUTTON_RIGHT && global.maus == global.Pickable_Items.muelleimer):
			global.maus = global.Pickable_Items.maus
			Input.set_mouse_mode(0)
			set_z_index(0)