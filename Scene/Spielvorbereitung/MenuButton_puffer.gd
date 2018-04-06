# Author: Adrian Wagener
# Dient dem Zweck des Einlesens der Parameter Datei. 
# Wurde in Godot 2.0 (vor der Portierung) implementiert, aber wegen
# mangelnder Zeit nicht auf 3.0 portiert

extends MenuButton

# Popup
var popup

func _ready():
	# Popup an Variable binden
	popup = get_popup()
	# Initialisieren
#	get_node("/root/Main/Startmenu/Popup_Vorbereiten").init_and_load("puffer", popup)
	
# Wenn ein Item angeklickt wird
func _on_item_pressed(ID):
	get_node("/root/Main/Startmenu/Popup_Vorbereiten").item_pressed(ID, "puffer", popup)