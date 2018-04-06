#UI Elemente, die während des gesamten Spiels szenenübergreifend angezeigt werden
#Wie Menü, Wechselbuttons für die Szenen und Notizblock

#@author Adrian Wagener

extends Control

signal vorratsschrank
signal arbeitsplatte
signal messgeraet
signal startmenu

func _ready():
	pass

func _on_Vorratsschrank_Button_pressed():
	if (global.maus == global.Pickable_Items.maus):
		emit_signal("vorratsschrank")

func _on_Arbeitsplatte_Button_pressed():
	emit_signal("arbeitsplatte")

func _on_Messgeraet_Button_pressed():
	if (global.maus == global.Pickable_Items.maus):
		emit_signal("messgeraet")

func _on_Popup_Startbildschirm_confirmed():
	emit_signal("startmenu")


func _on_Startbildschirm_pressed():
	emit_signal("startmenu")
