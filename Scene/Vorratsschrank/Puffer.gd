#Popup Menü für die Auswahl des Puffers

#@author Adrian Wagener

extends MenuButton

# Popup
var popup
signal buffer_selected(a)

func _ready():
	popup=get_popup()
	popup.connect("id_pressed", self, "_on_id_pressed")
	popup.add_check_item(global.alle_buffer[0].name) # ID 0
	connect("buffer_selected", get_parent().get_parent(), "_on_Puffer_popup_id_pressed")

func _on_id_pressed(ID):
	# Wenn es ein Check-Item ist (mit Checkbox)
	if(popup.is_item_checkable(ID)):
		# Wenn die Checkbox ausgewaehlt wurde, soll bei erneutem Klick die Checkbox abgewaehlt werden
		if(popup.is_item_checked(ID)):
			popup.set_item_checked(ID, false)
		else:
			# Wir Pruefen, ob keine andere Checkbox angeklickt ist, denn man darf nur 1 Puffer auswaehlen
			if(!get_parent().get_parent().check_all_items(popup, ID)):
			# Dann soll beim Klick die Checkbox ausgewaehlt werden und das passende Puffer gebunden werden
				popup.set_item_checked(ID, true)
				if(ID == 0):
					global.puffer = global.alle_buffer[0].name
					emit_signal("buffer_selected", global.alle_buffer[0])
				global.changed = true
				global.changed_puffer = true

