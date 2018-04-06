##############################################################################
#Main Scene für das Spiel. Wird beim Öffnen des Programms sofort gestartet.  #
#und das Startmenü wird angezeigt, als die einzige Szene mit visible == true #
##############################################################################

#@author Adrian Wagener
#@author Ivelin Ivanov

extends CanvasItem

#Variablen zum Steuern des Öffnens und Schliessens der Arbeitsplatte und Tutorial
var game_active = false
var tutorial_active = false
var first_start = true

func _ready():
	#Signalweiterleitungen zwischen den Subszenen
	signals_arbeitsplatte()
	get_node("Vorratsschrank").connect("microplate_selected", get_node("Messgeraet"), "microplate_selected")
	get_node("Startmenu/Popup_Prepare").connect("biomolecules_prepared", get_node("Vorratsschrank"), "_on_biomolecules_prepared")
	get_node("Startmenu/Popup_Prepare").connect("reagents_prepared", get_node("Vorratsschrank"), "_on_reagents_prepared")

#Alle Signale von und zur Arbeitsplatte sind hier ausgelagert, da _ready()
#nur einmal beim Starten ausgeführt wird, die Arbeitsplatte aber bei jedem
#Wechsel zwischen ihr und der Tutorial neu aufgebaut wird.
func signals_arbeitsplatte():
	get_node("Vorratsschrank").connect("microplate_selected", get_node("Arbeitsplatte"), "microplate_selected")
	get_node("Vorratsschrank").connect("show_microplate", get_node("Arbeitsplatte"), "show_microplate")
	get_node("Vorratsschrank").connect("show_buffer", get_node("Arbeitsplatte"), "show_buffer")
	get_node("Vorratsschrank").connect("show_biomolecule", get_node("Arbeitsplatte"), "show_biomolecule")
	get_node("Vorratsschrank").connect("show_reagent", get_node("Arbeitsplatte"), "show_reagent")
	get_node("Vorratsschrank").connect("buffer_selected", get_node("Arbeitsplatte/StoffeArbeitsplatte"), "material_selected")
	get_node("Vorratsschrank").connect("reagent_selected", get_node("Arbeitsplatte/StoffeArbeitsplatte"), "material_selected")
	get_node("Vorratsschrank").connect("biomolecule_selected", get_node("Arbeitsplatte/StoffeArbeitsplatte"), "material_selected")


#Spiel starten
func game_start_new():
	#Tutorial Szene wird gelöscht, da ansonsten die _process(ready) Funktionen
	#auf der "richtigen" Arbeitsplatte und die Instanz im Tutorial gleichzeitig
	#laufen und sich gegenseitig beeinflussen, da sie auf die gleichen Variablen
	#zugreifen.
	if (first_start):
		remove_child(get_node("Tutorial"))
		remove_child(get_node("Arbeitsplatte"))
		first_start = false
	var arbeitsplatte = load("res://Scene/Arbeitsplatte/Arbeitsplatte.tscn").instance()
	add_child(arbeitsplatte)
	move_child(get_node("UI"), get_child_count())
	game_active = true
	signals_arbeitsplatte()
	get_node("Arbeitsplatte").hide()
	get_node("Vorratsschrank").show()
	get_node("Startmenu").hide()
	get_node("UI").show()


#Derzeit ohne Funktion, für das Vorbereiten der Spieleparameter durch
#den Assistenten gedacht. Soll ein Menü zur Parameterauswahl öffnen.
func game_prepare():
	pass


#Tutorial starten
func tutorial():
	if (first_start):
		remove_child(get_node("Tutorial"))
		remove_child(get_node("Arbeitsplatte"))
		first_start = false
	var tutorial = load("res://Scene/Tutorial/Tutorial.tscn").instance()
	add_child(tutorial)
	move_child(get_node("UI"), get_child_count())
	tutorial_active = true
	get_node("Vorratsschrank").hide()
	get_node("Startmenu").hide()
	get_node("UI").show()
	get_node("Tutorial").show()


#Hilfefenster anzeigen
func help():
	get_node("UI/Navigation/Menu/Menu_Buttons/Popup_Hilfe").popup_centered()


#Aboutfenster anzeigen mit Entwicklernamen, Version und Lizenz
func about():
	get_node("UI/Navigation/Menu/Menu_Buttons/Popup_About").popup_centered()


#Spiel beenden
func quit_game():
	get_tree().quit()


#Wechsel zur Arbeitsplatte während des Spielverlaufs
func switch_to_arbeitsplatte():
	get_node("Vorratsschrank").hide()
	get_node("Messgeraet").hide()
	get_node("Arbeitsplatte").show()


#Wechsel zum Messgerät während des Spielverlaufs
func switch_to_messgeraet():
	get_node("Vorratsschrank").hide()
	get_node("Messgeraet").show()
	get_node("Arbeitsplatte").hide()


#Wechsel zum Vorratsschrank während des Spielverlaufs
func switch_to_vorratsschrank():
	get_node("Vorratsschrank").show()
	get_node("Messgeraet").hide()
	get_node("Arbeitsplatte").hide()


#Wechsel zum Startmenü und gleichzeitiges Beenden des Spiels und der Tutorial
func switch_to_startmenu():
	if (game_active):
		remove_child(get_node("Arbeitsplatte"))
		game_active = false
	if (tutorial_active):
		remove_child(get_node("Tutorial"))
		tutorial_active = false
	for i in range(get_children().size()):
		get_child(i).hide()
	get_node("Startmenu").show()

