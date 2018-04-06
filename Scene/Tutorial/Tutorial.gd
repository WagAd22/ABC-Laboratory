#Tutorialszene. Erzeugt eigene Instanzen der Arbeitsplatte und
#des Vorratsschrankes, damit die richtigen nicht verändert werden
#Wird nach Zurückkehren zum Startmenü wieder gelöscht

#@author Olcay Ece

extends Node2D

#Hilfsvariablen, um nicht jedes mal get_node(...) aufrufen zu müssen
#Kein Unterschied bei der Geschwindigkeit, aber bei der Lesbarkeit
#des Codes und beim Programmieren
var arbeitsplatte
var pipettieren
var tubeVorratsbox
var stoffeArbeitsplatte
var tubeRack
var mikrotiterplatte
var muelleimer
var state

func _ready():
	arbeitsplatte = get_node("Arbeitsplatte")
	pipettieren = get_node("Arbeitsplatte/Pipettieren")
	tubeVorratsbox = get_node("Arbeitsplatte/TubeVorratsbox")
	stoffeArbeitsplatte = get_node("Arbeitsplatte/StoffeArbeitsplatte")
	tubeRack = get_node("Arbeitsplatte/TubeRack")
	mikrotiterplatte = get_node("Arbeitsplatte/Mikrotiterplatte")
	muelleimer = get_node("Arbeitsplatte/Muelleimer")
	# FSM zurücksetzten
	state = 0
	# Dinge auf der Arbeitsplatte ausblenden
	pipettieren.hide()
	tubeVorratsbox.hide()
	stoffeArbeitsplatte.hide()
	tubeRack.hide()
	mikrotiterplatte.hide()
	muelleimer.hide()

# FSM wird jedes Frame ausgeführt und wechselt die States,
# nachdem die Bedingungen erfüllt wurden. Bei einer zukünftigen
# Erweiterung der Funktionalität ist es somit z.B. ganz leicht
# möglich, auch zurück zu vorherigen Schritten zu springen.
func _process(delta):
	# Erstes Popup bestätigen
	if(state == 1 && !get_node("Opening").is_visible_in_tree()):
		get_node("Task_1").show()
		muelleimer.show()
		pipettieren.show()
		state = 2
	# Spitze wegwerfen und Pipette zurücklegen
	if(state == 2 && global.mSpitzenWeiss > 0 && pipettieren.activePipette == null):
		state = 3
		get_node("Task_2").show()
		get_node("Task_1").hide()
		tubeVorratsbox.show()
		tubeRack.show()
	# Tube wegwerfen und in Tuberack legen
	if(state == 3 && global.mTubes >= 1 && tubeRack.rack_2d_array[0][0].tube != null):
		state = 4
		get_node("Task_3").show()
		get_node("Task_2").hide()
		stoffeArbeitsplatte.show()
	# Flüssigkeit in Tube füllen
	if(state == 4 && tubeRack.rack_2d_array[0][0].tube.content_volume >= 10):
		state = 5
		get_node("Task_4").show()
		get_node("Task_3").hide()
		mikrotiterplatte.show()
	# Flüssigkeit in Mikrotiterplatte füllen
	if(state == 5 && mikrotiterplatte.plate_2d_array[0][0].cavity.content_volume >= 10):
		state = 6
		get_node("Task_5").show()
		get_node("Task_4").hide()
	# Rotation des Tuberacks + Vorratsschrank aufrufen
	if(state == 6 && tubeRack.rotation_degrees == 180 && global.maus == global.Pickable_Items.maus):
		state == 7
		get_node("Task_6").show()
		get_node("Task_5").hide()
		get_node("Vorratsschrank").show()
		get_node("Arbeitsplatte").hide()

func show_opening():
	get_node("Opening").show()
	state = 1
# Beim klick auf den Tutorial-Button wird das Opening gezeigt
func _on_Tutorial_draw():
	show_opening()
	#Das UI teilweise verstecken, weil die entsprechende Elemente
	#hier nicht existieren, sondern nur im laufenden Spiel
	get_node("/root/Main/UI/Notizblock_Panel").hide()
	get_node("/root/Main/UI/Navigation/HButtonArray").hide()
	get_node("Vorratsschrank").hide()
	get_node("Arbeitsplatte").show()

#Vorher versteckte Elemente wieder sichtbar machen
func _on_Tutorial_tree_exiting():
	get_node("/root/Main/UI/Notizblock_Panel").show()
	get_node("/root/Main/UI/Navigation/HButtonArray").show()
