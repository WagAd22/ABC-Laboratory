#Popup Menü für die Auswahl der Mikrotiterplatte

#@author Adrian Wagener

extends MenuButton

# Popup
var popup
signal microplate_selected

func _ready():
	popup=get_popup()
	popup.connect("id_pressed", self, "_on_id_pressed")
	popup.add_check_item("96 Schwarz") 		# ID 0
	popup.add_check_item("96 Transparent")	# ID 1
	popup.add_check_item("384 Schwarz") 	# ID 2
	popup.add_check_item("384 Transparent")	# ID 3
	connect("microplate_selected", get_parent().get_parent(), "_on_Plate_menu_microplate_selected")

func _on_id_pressed(ID):
	# Wenn es ein Check-Item ist (mit Checkbox)
	if(popup.is_item_checkable(ID)):
		# Wenn die Checkbox ausgewaehlt wurde, soll bei erneutem Klick die Checkbox abgewaehlt werden
		if(popup.is_item_checked(ID)):
			popup.set_item_checked(ID, false)
		else:
			# Wir Pruefen, ob keine andere Checkbox angeklickt ist, denn man darf nur 1 Mikrotiterplatte auswaehlen
			if(!get_parent().get_parent().check_all_items(popup, ID)):
			# Dann soll beim Klick die Checkbox ausgewaehlt werden und die passende Microplate gebunden werden
				popup.set_item_checked(ID, true)
				if(ID == 0):
					global.microPlateType = "96"
					global.microPlateColor = "black"
				if(ID == 1):
					global.microPlateType = "96"
					global.microPlateColor = "transparent"
				if(ID == 2):
					global.microPlateType = "384"
					global.microPlateColor = "black"
				if(ID == 3):
					global.microPlateType = "384"
					global.microPlateColor = "transparent"
				global.plate_changed = true
				emit_signal("microplate_selected")