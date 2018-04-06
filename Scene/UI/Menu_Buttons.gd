# @author Adrian Wagener
# Kontroll Skript, welches die Animation vom Menu über einen Counter regelt

extends Control

signal startmenu

func _ready():
	pass

# Bevor das Spiel beendet wird, erscheint ein Popup, um sicher zu gehen, dass es gewollt ist.
func _on_Spiel_beenden_pressed():
	# Damit der Popup recht mittig auf dem Bildschirm erscheint:
	get_node("Popup_Spiel_beenden").popup_centered()

# Confirmation für Spiel_beenden
func _on_Popup_Spiel_beenden_confirmed():
	get_tree().quit()

# Wechsel zum Startbildschirm erfordert auch ein Popup
func _on_Startbildschirm_pressed():
	#get_node("Popup_Startbildschirm").popup_centered()
	# Die obere Zeile auskommentieren und folgende 2 Zeilen einkommentieren
	get_node("../../..").get_node("AnimationPlayer").play("Animation_Menu_Flight_Out")
	get_node("..").btn_pressed += 1

# Wenn beim Wechsel zum Startbildschirm ein Popup erscheinen soll, dann folgende 3 Zeilen auskommentieren
# Confirmation für Startbildschirm
#func _on_Popup_Startbildschirm_confirmed():
#	get_tree().change_scene("res://Scene/Scene_Startmenu.tscn")

# Popup für die Steuerung
func _on_Steuerung_pressed():
	get_node("Popup_Steuerung").popup_centered()

# Popup für die Hilfe
func _on_Hilfe_pressed():
	get_node("../Menu_Buttons/Popup_Hilfe").popup_centered()

# Popup für das About Fenster
func _on_About_pressed():
	get_node("../Menu_Buttons/Popup_About").popup_centered()

# Spielt die "Flight_Out" Animation, wenn man ein Popup aus dem Menu wegklickt. 
# Kann man auskommentieren, wenn das nicht gewollt ist.
func hide_menu():
	get_node("../../..").get_node("AnimationPlayer").play("Animation_Menu_Flight_Out")
	get_node("..").btn_pressed += 1