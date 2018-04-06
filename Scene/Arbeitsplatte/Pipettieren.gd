#Funktionalität der Pipetten und deren Interaktionen mit anderen Objekten
#Hier wird die Hauptfunktionalität des Pipettierens modelliert

#@author Benedikt Dreher
#@author Patrick Singh
#@author Ivelin Ivanov

extends Node2D

signal spitze_entsorgt
signal cav_slot_clicked

#Variablen zur korrekten Zuordnung der Mausposition
#Benötigt aufgrund von Änderungen von Input in Godot3
var pipetteMouseOver = null
var rackMouseOver = false
var spitzenBoxMouseOver = -1
var muelleimerMouseOver = false
var bufMouseOver = false
var bioMouseOver = false
var reaMouseOver = false
var cavMouseOver = false
var activePipette = null
var mikroplattenSlot = null

#Dictionary mit den Anfangspositionen der Pipetten, um diese beim Ablegen
#wieder an der richtigen Stelle und nur dort ablegen zu können
var initialPipettePositions = {
	"Pipette10" : 0,
	"Pipette20" : 0,
	"Pipette200" : 0,
	"Pipette1000" : 0
	}

func _ready():
	#Signale verbinden
	get_node("PipettenRack").connect("on_Koerper10_mouse_entered", self, "_on_Koerper10_mouse_entered")
	get_node("PipettenRack").connect("on_Koerper20_mouse_entered", self, "_on_Koerper20_mouse_entered")
	get_node("PipettenRack").connect("on_Koerper200_mouse_entered", self, "_on_Koerper200_mouse_entered")
	get_node("PipettenRack").connect("on_Koerper1000_mouse_entered", self, "_on_Koerper1000_mouse_entered")
	get_node("PipettenRack").connect("on_Koerper_mouse_exited", self, "_on_Koerper_mouse_exited")
	get_node("PipettenRack").connect("on_Pipettenrack_Control_mouse_entered", self, "_on_Pipettenrack_Control_mouse_entered")
	get_node("PipettenRack").connect("on_Pipettenrack_Control_mouse_exited", self, "_on_Pipettenrack_Control_mouse_exited")
	
	#Pipettenpositionen auslesen und speichern
	initialPipettePositions["Pipette10"] = get_node("PipettenRack/PipetteMain/Pipette10").get_position()
	initialPipettePositions["Pipette20"] = get_node("PipettenRack/PipetteMain/Pipette20").get_position()
	initialPipettePositions["Pipette200"] = get_node("PipettenRack/PipetteMain/Pipette200").get_position()
	initialPipettePositions["Pipette1000"] = get_node("PipettenRack/PipetteMain/Pipette1000").get_position()

#Behandlung von Input Events. Anheben und Ablegen von Pipetten, Spitzen anlegen und entsorgen
#Pipettieren aus Gefäßen, Pipettenvolumen einstellen, Spitzenboxen bewegen
func _input(event):
	#Mausclick wird registriert
	if (event is InputEventMouseButton && event.is_pressed()):
		#Mauszeiger frei
		if (global.maus == global.Pickable_Items.maus && event.button_index == BUTTON_LEFT):
			#Maus über Pipette - anheben
			if (pipetteMouseOver != null):
				global.maus = global.Pickable_Items.pipette
				activePipette = get_node("PipettenRack/PipetteMain/" + pipetteMouseOver)
				Input.set_mouse_mode(1)
				activePipette.set_z_index(1)
				get_node("PipettenRack/Pipettenrack_Control").visible = true
			#Maus über Spitzenbox - anheben
			if (Input.is_action_pressed("ctrl")):
				if (spitzenBoxMouseOver == 0):
					global.maus = global.Pickable_Items.spboxw
					Input.set_mouse_mode(1)
					get_node("SpitzenboxWeiss").set_z_index(1)
				if (spitzenBoxMouseOver == 1):
					global.maus = global.Pickable_Items.spboxg
					Input.set_mouse_mode(1)
					get_node("SpitzenboxGelb").set_z_index(1)
				if (spitzenBoxMouseOver == 2):
					global.maus = global.Pickable_Items.spboxb
					Input.set_mouse_mode(1)
					get_node("SpitzenboxBlau").set_z_index(1)
		#Pipette angehoben
		elif (global.maus == global.Pickable_Items.pipette):
			#Pipette über Rack -> wieder ablegen
			if (rackMouseOver && event.button_index == BUTTON_RIGHT):
				global.maus = global.Pickable_Items.maus
				activePipette.set_position(initialPipettePositions[activePipette.get_name()])
				activePipette.set_z_index(0)
				activePipette = null
				Input.set_mouse_mode(0)
				get_node("PipettenRack/Pipettenrack_Control").visible = false
			elif (event.button_index == BUTTON_LEFT && event.is_pressed()):
				#Pipette über Spitzenbox und ohne Spitze -> Spitze anlegen
				if (activePipette.spitzeAn == false):
					if (spitzenBoxMouseOver == 0 && activePipette.get_name() == "Pipette10"):
						setSpitze(true)
					elif (spitzenBoxMouseOver == 1
					&& (activePipette.get_name() == "Pipette20" || activePipette.get_name() == "Pipette200")):
						setSpitze(true)
					elif (spitzenBoxMouseOver == 2 && activePipette.get_name() == "Pipette1000"):
						setSpitze(true)
				#Stoffe aufnehmen
				if (bufMouseOver):
					stoff_aufnehmen(get_parent().get_node("StoffeArbeitsplatte").buffer)
				if (bioMouseOver):
					stoff_aufnehmen(get_parent().get_node("StoffeArbeitsplatte").biomolecule)
				if (reaMouseOver):
					stoff_aufnehmen(get_parent().get_node("StoffeArbeitsplatte").reagent)
				if (cavMouseOver):
					pipettieren(mikroplattenSlot.cavity)
					emit_signal("cav_slot_clicked", mikroplattenSlot)
			#Spitze entsorgen
			elif (event.button_index == BUTTON_RIGHT && muelleimerMouseOver == true && activePipette.spitzeAn == true):
				setSpitze(false)
				emit_signal("spitze_entsorgt", activePipette.spitzeFarbe)
			#Volumen mit Mausrad einstellen, nur bei leeren Pipetten
			elif (activePipette.get_inhaltMenge() == 0):
				if (event.button_index == BUTTON_WHEEL_UP && activePipette.volumen < activePipette.maxVolume):
					if (Input.is_action_pressed("ctrl") && activePipette.volumen <= (activePipette.maxVolume - activePipette.step*10)):
						activePipette.volumen = activePipette.volumen + (activePipette.step * 10)
					elif (Input.is_action_pressed("shift") && activePipette.volumen <= (activePipette.maxVolume - activePipette.step*100)):
						activePipette.volumen = activePipette.volumen + (activePipette.step * 100)
					else:
						activePipette.volumen = activePipette.volumen + activePipette.step
					activePipette.volumeLabel.text = String(activePipette.volumen)
				if (event.button_index == BUTTON_WHEEL_DOWN && activePipette.volumen > activePipette.minVolume):
					if (Input.is_action_pressed("ctrl") && activePipette.volumen >= (activePipette.minVolume + activePipette.step*10)):
						activePipette.volumen = activePipette.volumen - (activePipette.step * 10)
					elif (Input.is_action_pressed("shift") && activePipette.volumen >= (activePipette.minVolume + activePipette.step*100)):
						activePipette.volumen = activePipette.volumen - (activePipette.step * 100)
					else:
						activePipette.volumen = activePipette.volumen - activePipette.step
					activePipette.volumeLabel.text = String(activePipette.volumen)
		#Eine Spitzenbox ist angehoben -> wieder ablegen
		if (event.button_index == BUTTON_RIGHT):
			if (global.maus == global.Pickable_Items.spboxw):
				get_node("SpitzenboxWeiss").set_z_index(0)
				global.maus = global.Pickable_Items.maus
				Input.set_mouse_mode(0)
			if (global.maus == global.Pickable_Items.spboxg):
				get_node("SpitzenboxGelb").set_z_index(0)
				global.maus = global.Pickable_Items.maus
				Input.set_mouse_mode(0)
			if (global.maus == global.Pickable_Items.spboxb):
				get_node("SpitzenboxBlau").set_z_index(0)
				global.maus = global.Pickable_Items.maus
				Input.set_mouse_mode(0)


#Pipettieren in und aus Tubes und Mikrotiterplatten Wells
func pipettieren(behaelter):
	#Pipette nicht leer - in Behälter reinpipettieren
	if (activePipette.get_inhaltMenge() != 0):
		activePipette.inhalt = behaelter.add(activePipette.inhalt)
	else:
		activePipette.inhalt = behaelter.remove(activePipette.volumen)
	if (activePipette.get_inhaltMenge() == 0):
		activePipette.volumeLabel.add_color_override("font_color", Color(0,0,0,1))
	elif (activePipette.get_inhaltMenge() >= activePipette.volumen):
		activePipette.volumeLabel.add_color_override("font_color", Color(0,1,0,1))
	else:
		activePipette.volumeLabel.add_color_override("font_color", Color(1,0,0,1))


#Stoff aus Gefäß aufnehmen
func stoff_aufnehmen(stoff):
	if (activePipette.get_inhaltMenge() == 0 && activePipette.spitzeAn):
		activePipette.inhalt = [[stoff, activePipette.volumen]]
		activePipette.volumeLabel.add_color_override("font_color", Color(0,1,0,1))


#Spitze anlegen
func setSpitze(var set):
	activePipette.spitzeAn = set
	activePipette.get_child(0).get_child(0).visible = set


#Empfangen von Signalen von den einzelnen Pipetten
func _on_Koerper10_mouse_entered():
	pipetteMouseOver = "Pipette10"
func _on_Koerper20_mouse_entered():
	pipetteMouseOver = "Pipette20"
func _on_Koerper200_mouse_entered():
	pipetteMouseOver = "Pipette200"
func _on_Koerper1000_mouse_entered():
	pipetteMouseOver = "Pipette1000"
func _on_Koerper_mouse_exited():
	pipetteMouseOver = null


#Empfangen von Signalen vom Pipettenrack/Ständer
func _on_Pipettenrack_Control_mouse_entered():
	rackMouseOver = true
func _on_Pipettenrack_Control_mouse_exited():
	rackMouseOver = false


#Empfangen von Signalen von den Spitzenboxen
func _on_SpitzenboxWeiss_mouse_entered():
	spitzenBoxMouseOver = 0
func _on_SpitzenboxGelb_mouse_entered():
	spitzenBoxMouseOver = 1
func _on_SpitzenboxBlau_mouse_entered():
	spitzenBoxMouseOver = 2
func _on_Spitzenbox_mouse_exited():
	spitzenBoxMouseOver = -1


#Empfangen von Signal vom Mülleimer
func _on_Muelleimer_mouse_over(a):
	muelleimerMouseOver = a

#Empfangen von Signalen von den Stoffbehältern
func _on_StoffeArbeitsplatte_buf_mouse_over(a):
	bufMouseOver = a
func _on_StoffeArbeitsplatte_bio_mouse_over(a):
	bioMouseOver = a
func _on_StoffeArbeitsplatte_rea_mouse_over(a):
	reaMouseOver = a

#Empfangen von Signalen von der Mikrotiterplatte
#a: slot, b: ob die Maus sich über diesen Slot befindet
func _on_Mikroplatte_kav_slot_mouse_over(a, b):
	mikroplattenSlot = a
	cavMouseOver = b

#Signal vom Eppendorftube Rack
func _tube_clicked_with_pipette(a):
	pipettieren(a)
