extends HBoxContainer

#DIESEN SKRIPT NICHT BENUTZEN!!!
#STATTDESSEN DEN "OBERSKRIPT" IN UI: ui.gd
#dieser hier wird demnächst entfernt

signal vorratsschrank
signal arbeitsplatte
signal messgeraet

func _ready():
	pass

func _on_Vorratsschrank_Button_pressed():
	emit_signal("vorratsschrank")

func _on_Arbeitsplatte_Button_pressed():
	emit_signal("arbeitsplatte")

func _on_Messgeraet_Button_pressed():
	emit_signal("messgeraet")

