#Popup für Szenarioauswahl

#@author Adrian Wagener
#@author Ivelin Ivanov

extends AcceptDialog

signal game_start
signal biomolecules_prepared(a)
signal reagents_prepared(a)

# Auswahl
var szenario_auswahl
var proteinkonzentration
# Labels
var Szenario1
var Szenario2a
var Szenario2b
var Szenario3
# Container
var vboxcontainer 

#Arrays mit Biomolekülen
var bio1 = []
var bio2a = []
var bio2b = []
var bio3 = []

#Arrays mit Reagenzien
var rea1 = []
var rea2a = []
var rea2b = []
var rea3 = []

func _ready():
	# Binden der Nodes an Variablen
	szenario_auswahl = get_node("MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Grundszenario")
	proteinkonzentration = get_node("MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Szenario_Proteinkonzentration")
	vboxcontainer = get_node("MarginContainer/ScrollContainer/VBoxContainer")
	Szenario1 = get_node("MarginContainer/ScrollContainer/VBoxContainer/Szenario1")
	Szenario2a = get_node("MarginContainer/ScrollContainer/VBoxContainer/Szenario2_a")
	Szenario2b = get_node("MarginContainer/ScrollContainer/VBoxContainer/Szenario2_b")
	Szenario3 = get_node("MarginContainer/ScrollContainer/VBoxContainer/Szenario3")
	
	# Szenario Auswahl hinzufügen
	szenario_auswahl.add_item("1. Bestimmung des Extinktionskoeffizienten eines Moleküls", 0)
	szenario_auswahl.add_item("2. Bestimmung der Proteinkonzentration einer unbekannten Probe", 1)
	szenario_auswahl.add_item("3. Bestimmung der Bindung eines Biomoleküls an ein Reagenz", 2)
	proteinkonzentration.add_item("a)", 0)
	proteinkonzentration.add_item("b)", 1)
	
	# GUI 
	proteinkonzentration.hide()
	
	# Szenario1 muss nicht versteckt werden, da es automatisch als 1. angezeigt wird
	Szenario2a.hide()
	Szenario2b.hide()
	Szenario3.hide()
	
	###Stoffe für Szenarien vorbereiten
	var reaIL8 = Materials.Reagent.new()
	reaIL8.setup("IL8 (Reagenz)", 8381.76, 0.85, 10, 280, 7240, 320, 1, 1, 1, 1, "gelb")
	#Szenario 1
	bio1.append(global.alle_biomolekuele[0])
	bio1.append(global.alle_biomolekuele[1])
	rea1.append(global.alle_reagenze[0])
	rea1.append(global.alle_reagenze[1])
	rea1.append(global.alle_reagenze[2])
	
	#Szenario 2a
	bio2a.append(global.alle_biomolekuele[0])
	rea2a.append(reaIL8)
	
	#Szenario 2b
	bio2b.append(global.alle_biomolekuele[1])
	rea2b.append(reaIL8)
	
	#Szenario 3
	bio3.append(global.alle_biomolekuele[0])
	rea3.append(global.alle_reagenze[0])
	rea3.append(global.alle_reagenze[1])
	rea3.append(global.alle_reagenze[2])

func _process(delta):
	# Dynamische Anzeige der Szenarioauswahl
	if(szenario_auswahl.get_selected_id() == 0):
		Szenario1.show()
	else:
		Szenario1.hide()
	if(szenario_auswahl.get_selected_id() == 1):
		proteinkonzentration.show()
		if(proteinkonzentration.get_selected_id() == 0):
			Szenario2a.show()
			Szenario2b.hide()
		if(proteinkonzentration.get_selected_id() == 1):
			Szenario2a.hide()
			Szenario2b.show()
	else:
		proteinkonzentration.hide()
		Szenario2a.hide()
		Szenario2b.hide()
	if(szenario_auswahl.get_selected_id() == 2):
		Szenario3.show()
	else:
		Szenario3.hide()

# Wenn die Auswahl des Szenarios gewählt wurde
func _on_Popup_Prepare_confirmed():
	global.szenario_picked = true
	#Signale an Vorratsschrank mit Stoffen senden
	if(szenario_auswahl.get_selected_id() == 0):
		global.szenario = "1"
		emit_signal("reagents_prepared", rea1)
		emit_signal("biomolecules_prepared", bio1)
	if(szenario_auswahl.get_selected_id() == 1):
		if(proteinkonzentration.get_selected_id() == 0):
			global.szenario = "2a"
			emit_signal("reagents_prepared", rea2a)
			emit_signal("biomolecules_prepared", bio2a)
			global.alle_reagenze = rea2a
		if(proteinkonzentration.get_selected_id() == 1):
			global.szenario = "2b"
			emit_signal("reagents_prepared", rea2b)
			emit_signal("biomolecules_prepared", bio2b)
			global.alle_reagenze = rea2b
	if(szenario_auswahl.get_selected_id() == 2):
		global.szenario = "3"
		emit_signal("reagents_prepared", rea3)
		emit_signal("biomolecules_prepared", bio3)
	emit_signal("game_start")

func show_popup():
	if(!global.szenario_picked):
		popup_centered()
	else:
		emit_signal("game_start")