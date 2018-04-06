#Hauptnode für den Vorratsschrank, leitet die Signale an den Popup Menüs weiter

#@author Adrian Wagener
#@author Ivelin Ivanov

extends Node2D

var popup 
var popupmenu

var first_time = true

signal microplate_selected
signal buffer_selected(a)
signal biomolecule_selected(a)
signal reagent_selected(a)

signal show_microplate(a)
signal show_buffer(a)
signal show_biomolecule(a)
signal show_reagent(a)


# Ueberprueft ob ein anderes Item ausser dem Item mit ID vom Popupmenu gechecked ist
func check_all_items(popup, ID):
	for i in range (0, popup.get_item_count()):
		if(i != ID and popup.is_item_checked(i)):
			return true
	return false

#Je nach Szenarioauswahl die richtigen Biomoleküle an das Popup Menü weitergeben
func _on_biomolecules_prepared(biomolecules):
	for i in range(biomolecules.size()):
		get_node("Biomolekuel/Biomolekuel_menu").popup.add_check_item(biomolecules[i].name)

#Je nach Szenarioauswahl die richtigen Reagenzien an das Popup Menü weitergeben
func _on_reagents_prepared(reagents):
	for i in range(reagents.size()):
		get_node("Reagenz/Reagenz_menu").popup.add_check_item(reagents[i].name)


#Signale nach Auswahl des Puffers an die Main Szene weiterleiten
func _on_Puffer_popup_id_pressed(buffer):
	emit_signal("buffer_selected", buffer)
	emit_signal("show_buffer", true)

#Signale nach Auswahl des Reagenzes an die Main Szene weiterleiten
func _on_Reagenz_popup_id_pressed(reagent):
	emit_signal("reagent_selected", reagent)
	emit_signal("show_reagent", true)

#Signale nach Auswahl der Biomolekül an die Main Szene weiterleiten
func _on_Biomolekuel_popup_id_pressed(biomolecule):
	emit_signal("biomolecule_selected", biomolecule)
	emit_signal("show_biomolecule", true)

#Signale nach Auswahl der Biomolekül an die Main Szene weiterleiten
func _on_Plate_menu_microplate_selected():
	emit_signal("microplate_selected")
	emit_signal("show_microplate", true)

#Beim ersten Anzeigen des Schrankes nach dem Spielstart,
#Die Mikrotiterplatte und die Behälter mit den Stoffen
#auf der Arbeitsplatte verstecken, bis die richtigen ausgewählt wurden
func _on_Vorratsschrank_draw():
	if (first_time):
		first_time = false
		emit_signal("show_microplate", false)
		emit_signal("show_buffer", false)
		emit_signal("show_biomolecule", false)
		emit_signal("show_reagent", false)
