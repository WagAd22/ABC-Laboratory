#Popup Menü für die Auswahl der Biomolekül

#@author Adrian Wagener

extends MenuButton

# Popup
var popup
signal biomolecule_selected(a)

func _ready():
	popup=get_popup()
	popup.connect("id_pressed", self, "_on_id_pressed")
	connect("biomolecule_selected", get_parent().get_parent(), "_on_Biomolekuel_popup_id_pressed")

func _on_id_pressed(ID):
	# Wenn es ein Check-Item ist (mit Checkbox)
	if(popup.is_item_checkable(ID)):
		# Wenn die Checkbox ausgewaehlt wurde, soll bei erneutem Klick die Checkbox abgewaehlt werden
		if(popup.is_item_checked(ID)):
			popup.set_item_checked(ID, false)
		else:
			# Wir Pruefen, ob keine andere Checkbox angeklickt ist, denn man darf nur 1 Biomolekuel auswaehlen
			if(!get_parent().get_parent().check_all_items(popup, ID)):
			# Dann soll beim Klick die Checkbox ausgewaehlt werden und das passende Biomolekuel gebunden werden
				popup.set_item_checked(ID, true)
				if(ID == 0):
					global.biomolekuel = global.alle_biomolekuele[0]
				if(ID == 1):
					global.biomolekuel = global.alle_biomolekuele[1]
				emit_signal("biomolecule_selected", global.alle_biomolekuele[ID])
				global.changed = true
				global.changed_biomolekuele = true