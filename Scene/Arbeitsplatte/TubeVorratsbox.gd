#Vorratsbox für Eppendorf Tubes. Tubes entnehmen und wieder zurücklegen
#Die ID wird immer hochgezählt, auch bei zurückgelegten Tubes wird sie
#nicht zurückgesetzt

#@author Ivelin Ivanov
#@author Patrick Singh

extends Node2D

var last_tube_id = 1
var mouse_over = false

#
func _input(event):
	if mouse_over and event is InputEventMouseButton && event.is_pressed():
		if (!Input.is_action_pressed("ctrl")
		&& event.button_index == BUTTON_LEFT && global.maus == global.Pickable_Items.maus):
			global.maus = global.Pickable_Items.tube
			global.activeTube = load("res://Script/Tube.gd").new()
			global.activeTube._setup()
			global.activeTube.id = last_tube_id
			last_tube_id += 1
			get_parent().get_node("Tube").visible = true
			get_parent().get_node("Tube").set_z_index(1)
			Input.set_mouse_mode(1)
		if (Input.is_action_pressed("ctrl")
		&& event.button_index == BUTTON_LEFT && global.maus == global.Pickable_Items.maus):
			global.maus = global.Pickable_Items.tubevorratsbox
			Input.set_mouse_mode(1)
			set_z_index(1)
		if (event.button_index == BUTTON_RIGHT && global.maus == global.Pickable_Items.tubevorratsbox):
			global.maus = global.Pickable_Items.maus
			Input.set_mouse_mode(0)
			set_z_index(0)
		if (event.button_index == BUTTON_RIGHT && global.maus == global.Pickable_Items.tube):
			global.activeTube = null
			global.maus = global.Pickable_Items.maus
			get_parent().get_node("Tube").visible = false
			get_parent().get_node("Tube").set_z_index(0)
			Input.set_mouse_mode(0)



func _on_Vorratsbox_mouse_entered():
	mouse_over = true


func _on_Vorratsbox_mouse_exited():
	mouse_over = false
