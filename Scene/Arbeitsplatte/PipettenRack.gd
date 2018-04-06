#Script um die Signale von den Pipetten und dem Pipettenrack
#an das Pipettieren Node weiterzuleiten

#@author Ivelin Ivanov


extends Node2D

signal on_Koerper10_mouse_entered
signal on_Koerper20_mouse_entered
signal on_Koerper200_mouse_entered
signal on_Koerper1000_mouse_entered
signal on_Koerper_mouse_exited
signal on_Pipettenrack_Control_mouse_entered
signal on_Pipettenrack_Control_mouse_exited

var mouse_over = false


func _on_Koerper10_mouse_entered():
	emit_signal("on_Koerper10_mouse_entered")


func _on_Koerper_mouse_exited():
	emit_signal("on_Koerper_mouse_exited")


func _on_Pipettenrack_Control_mouse_entered():
	mouse_over = true
	emit_signal("on_Pipettenrack_Control_mouse_entered")


func _on_Pipettenrack_Control_mouse_exited():
	mouse_over = false
	emit_signal("on_Pipettenrack_Control_mouse_exited")


func _on_Koerper20_mouse_entered():
	emit_signal("on_Koerper20_mouse_entered")


func _on_Koerper20_mouse_exited():
	emit_signal("on_Koerper_mouse_exited")


func _on_Koerper200_mouse_entered():
	emit_signal("on_Koerper200_mouse_entered")


func _on_Koerper200_mouse_exited():
	emit_signal("on_Koerper_mouse_exited")


func _on_Koerper1000_mouse_entered():
	emit_signal("on_Koerper1000_mouse_entered")


func _on_Koerper1000_mouse_exited():
	emit_signal("on_Koerper_mouse_exited")
