#Behälter für die Moleküle, Proteine und Puffer

#@author Ivelin Ivanov
#@author Olcay Ece

extends Node2D

signal buffer_mouse_over(a)
signal biomolecule_mouse_over(a)
signal reagent_mouse_over(a)

#Die Stoffe
var biomolecule
var buffer
var reagent

var buffer_mouse_over = false
var biomolecule_mouse_over = false
var reagent_mouse_over = false

#Labels für die Behälter
var label_bio = Label.new()
var panel_bio = Panel.new()
var label_rea = Label.new()
var panel_rea = Panel.new()
var label_buf = Label.new()
var panel_buf = Panel.new()

func _ready():
	#voreingestellte Stoffe, z.B. für die Tutorial Szene
	#Werden nach Szenarioauswahl durch die gewünschten ersetzt
	biomolecule = global.alle_biomolekuele[0]
	buffer = global.alle_buffer[0]
	reagent = global.alle_reagenze[0]
	
	#Labels initialisieren und richtig platzieren	
	get_node("Biomolekuel").add_child(panel_bio)
	get_node("Reagenz").add_child(panel_rea)
	get_node("Puffer").add_child(panel_buf)
	panel_bio.add_child(label_bio)
	panel_rea.add_child(label_rea)
	panel_buf.add_child(label_buf)
	
	panel_bio.set_size(Vector2(115, 50))
	panel_rea.set_size(Vector2(132, 50))
	panel_buf.set_size(Vector2(60, 15))
	
	label_bio.set_text(biomolecule.name)
	label_rea.set_text(reagent.name)
	label_buf.set_text(buffer.name)
	
	panel_buf.set_position(Vector2(20, -60))
	panel_rea.set_position(Vector2(0, -60))
	panel_bio.set_position(Vector2(0, -60))

#Input Event Handler, um die Behälter anzuheben und wieder abzulegen
func _input(event):
	if (event is InputEventMouseButton): 
		#Maus frei -> Behälter anheben
		if (Input.is_action_pressed("ctrl") && event.button_index == BUTTON_LEFT && global.maus == global.Pickable_Items.maus):
			if (buffer_mouse_over):
				global.maus = global.Pickable_Items.buffer
				Input.set_mouse_mode(1)
				set_z_index(1)
			if (biomolecule_mouse_over):
				global.maus = global.Pickable_Items.biomolecule
				Input.set_mouse_mode(1)
				set_z_index(1)
			if (reagent_mouse_over):
				global.maus = global.Pickable_Items.reagent
				Input.set_mouse_mode(1)
				set_z_index(1)
		#Behälter angehoben -> wieder ablegen
		if (event.button_index == BUTTON_RIGHT):
			if (global.maus == global.Pickable_Items.buffer):
				global.maus = global.Pickable_Items.maus
				Input.set_mouse_mode(0)
				get_node("Puffer").set_z_index(0)
			if (global.maus == global.Pickable_Items.biomolecule):
				global.maus = global.Pickable_Items.maus
				Input.set_mouse_mode(0)
				get_node("Biomolekuel").set_z_index(0)
			if (global.maus == global.Pickable_Items.reagent):
				global.maus = global.Pickable_Items.maus
				Input.set_mouse_mode(0)
				get_node("Reagenz").set_z_index(0)

#Empfänger des Signals aus dem Vorratsschrank, das nach dem Auswählen
#des entsprechenden Stoffes gesendet wird
func material_selected(mat):
	#übergebenes Puffer setzen und das Label aktualisieren
	if (mat.type == "buffer"):
		buffer = mat
		label_buf.set_text(buffer.name)
	#übergebene Biomolekül setzen und Label aktualisieren
	elif (mat.type == "biomolecule"):
		biomolecule = mat
		label_bio.set_text(biomolecule.name + "\nKonzentration:\n%f mg/mL" % (float(mat.mass_concentration) / float(mat.molecular_weight)))
	#übergebenes Reagenz setzen und Label aktualisieren
	elif (mat.type == "reagent"):
		reagent = mat
		if (global.szenario == "2a" || global.szenario == "2b"):
			label_rea.set_text(reagent.name + "\nKonzentration:\nUnbekannt")
		#Konzentration nur dann anzeigen, wenn nicht durch das Szenario verboten
		else:
			label_rea.set_text(reagent.name + "\nKonzentration:\n%f mg/mL" % (float(mat.mass_concentration) / float(mat.molecular_weight)))


#Signale von den Behältern empfangen und weiterleiten

func _on_Puffer_mouse_entered():
	buffer_mouse_over = true
	emit_signal("buffer_mouse_over", true)

func _on_Puffer_mouse_exited():
	buffer_mouse_over = false
	emit_signal("buffer_mouse_over", false)

func _on_Biomolekuel_mouse_entered():
	biomolecule_mouse_over = true
	emit_signal("biomolecule_mouse_over", true)

func _on_Biomolekuel_mouse_exited():
	biomolecule_mouse_over = false
	emit_signal("biomolecule_mouse_over", false)

func _on_Reagenz_mouse_entered():
	reagent_mouse_over = true
	emit_signal("reagent_mouse_over", true)

func _on_Reagenz_mouse_exited():
	reagent_mouse_over = false
	emit_signal("reagent_mouse_over", false)
