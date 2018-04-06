#Haupt Node für die Arbeitsplatte. Von hier werden alle untergeordneten
#Nodes gesteuert und die Signale weitergereicht

#@author Ivelin Ivanov

extends Node2D

func _ready():
	#Signale von Muelleimer nach der Pipettierszene senden und zurück
	get_node("Muelleimer").connect("eimer_mouse_over", get_node("Pipettieren"), "_on_Muelleimer_mouse_over")
	get_node("Pipettieren").connect("spitze_entsorgt", get_node("Muelleimer"), "_spitze_entsorgt")
	
	#Signale von den Stoffen nach der Pipettierszene senden
	get_node("StoffeArbeitsplatte").connect("buffer_mouse_over", get_node("Pipettieren"), "_on_StoffeArbeitsplatte_buf_mouse_over")
	get_node("StoffeArbeitsplatte").connect("biomolecule_mouse_over", get_node("Pipettieren"), "_on_StoffeArbeitsplatte_bio_mouse_over")
	get_node("StoffeArbeitsplatte").connect("reagent_mouse_over", get_node("Pipettieren"), "_on_StoffeArbeitsplatte_rea_mouse_over")
	
	#Signale von der Mikrotiterplatte nach der Pipettierszene senden und zurück
	microplate_signals()
	
	#Signale vom Rack nach der Pipettierszene und zurück
	get_node("TubeRack").connect("tube_clicked_with_pipette", get_node("Pipettieren"), "_tube_clicked_with_pipette")


#wird jedes Frame ausgeführt. Wird benötigt, um die Position von
#angehobenen Gegenständen ständig an die aktuelle Mausposition
#anzupassen. Festkodierte Offsets, je nach Größe des Gegenstandes
func _process(delta):
	var mouse_position = get_global_mouse_position()
	if (global.maus == global.Pickable_Items.pipette):
		get_node("Pipettieren/PipettenRack/PipetteMain/"
		+ get_node("Pipettieren").activePipette.get_name()).set_position(mouse_position + Vector2(0,0))
	elif (global.maus == global.Pickable_Items.rack):
		get_node("TubeRack").set_position(mouse_position + Vector2(- get_node("TubeRack/RackHintergrund").rect_size / 2))
	elif (global.maus == global.Pickable_Items.mikroplatte):
		get_node("Mikrotiterplatte").set_position(mouse_position + Vector2(- get_node("Mikrotiterplatte/PlatteHintergrund").rect_size / 2))
	elif (global.maus == global.Pickable_Items.muelleimer):
		get_node("Muelleimer").set_position(mouse_position)
	elif (global.maus == global.Pickable_Items.pipettenrack):
		get_node("Pipettieren/PipettenRack").set_position(mouse_position
		 - Vector2(get_node("Pipettieren/PipettenRack/Pipettenrack_Control").rect_position) - Vector2(230, 60))
	elif (global.maus == global.Pickable_Items.tube):
		get_node("Tube").set_position(mouse_position)
	elif (global.maus == global.Pickable_Items.buffer):
		get_node("StoffeArbeitsplatte/Puffer").set_position(mouse_position - Vector2(50,50))
	elif (global.maus == global.Pickable_Items.biomolecule):
		get_node("StoffeArbeitsplatte/Biomolekuel").set_position(mouse_position - Vector2(50,50))
	elif (global.maus == global.Pickable_Items.reagent):
		get_node("StoffeArbeitsplatte/Reagenz").set_position(mouse_position - Vector2(50,50))
	elif (global.maus == global.Pickable_Items.tubevorratsbox):
		get_node("TubeVorratsbox").set_position(mouse_position - Vector2(80,100))
	elif (global.maus == global.Pickable_Items.spboxw):
		get_node("Pipettieren/SpitzenboxWeiss").set_position(mouse_position - Vector2(55,45))
	elif (global.maus == global.Pickable_Items.spboxg):
		get_node("Pipettieren/SpitzenboxGelb").set_position(mouse_position - Vector2(55,45))
	elif (global.maus == global.Pickable_Items.spboxb):
		get_node("Pipettieren/SpitzenboxBlau").set_position(mouse_position - Vector2(55,45))

#Mikrotiterplatte erst entfernen und dann mit den richtigen Parametern neu erstellen,
#wie vom Vorratsschrank übergeben
func microplate_selected():
	remove_child(get_node("Mikrotiterplatte"))
	var mikroplatte = load("res://Scene/Arbeitsplatte/Mikrotiterplatte.tscn").instance()
	add_child(mikroplatte)
	#Die Signals der Mikrotiterplatte neu verbinden, da sie nach remove_child()
	#nicht mehr existieren
	microplate_signals()



func microplate_signals():
	get_node("Mikrotiterplatte").connect("kav_slot_mouse_over", get_node("Pipettieren"), "_on_Mikroplatte_kav_slot_mouse_over")
	get_node("Pipettieren").connect("cav_slot_clicked", get_node("Mikrotiterplatte"), "slot_clicked")


#Mikrotiterplatte verstecken und wieder anzeigen,
#nach Signal vom Vorratsschrank
func show_microplate(yes):
	if (yes):
		get_node("Mikrotiterplatte").show()
	else:
		get_node("Mikrotiterplatte").hide()

#Puffer verstecken und wieder anzeigen,
#nach Signal vom Vorratsschrank
func show_buffer(yes):
	if (yes):
		get_node("StoffeArbeitsplatte/Puffer").show()
	else:
		get_node("StoffeArbeitsplatte/Puffer").hide()

#Biomolekül verstecken und wieder anzeigen,
#nach Signal vom Vorratsschrank
func show_biomolecule(yes):
	if (yes):
		get_node("StoffeArbeitsplatte/Biomolekuel").show()
	else:
		get_node("StoffeArbeitsplatte/Biomolekuel").hide()

#Reagenz verstecken und wieder anzeigen,
#nach Signal vom Vorratsschrank
func show_reagent(yes):
	if (yes):
		get_node("StoffeArbeitsplatte/Reagenz").show()
	else:
		get_node("StoffeArbeitsplatte/Reagenz").hide()
