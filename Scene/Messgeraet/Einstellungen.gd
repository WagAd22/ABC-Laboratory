#Node zum Anzeigen und Verwalten der Einstellungsoptionen vom Messgerät
#Sowie zum anschliessenden Berechnen der Ergebnisse und Speichern in .csv

#@author Adrian Wagener
#@author Benedikt Dreher

extends Node

# Nodes
var selected_item_mess
var messmethode_options
var anregung_emission
var anregung_emission_wellenlaenge
var absorption_wellenlaenge
var intervall
var intervall_spinbox
var optionbutton_well
var well_options
var farbe_options
# Popups
var konfiguration
var wells
var kinetik
var filedialog
# File
var file_student = File.new()
var file_assistant = File.new()
# Array
var buchstaben_h = ["", "A", "B", "C", "D", "E", "F", "G", "H"]
var buchstaben_p = ["", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P"]
var FI_Werte = []
# Standardmaessig nur 1 messzyklus eingestellt
var messzyklen = 1

# Flags
#Wird benutzt, um die Berechnungen im _process nur dann auszuführen,
#wenn alle Optionen ausgewählt wurden
var timer_flag = false

func _ready():
	konfiguration = get_node("ConfirmationDialog")
	wells = get_node("ConfirmationDialog2")
	kinetik = get_node("ConfirmationDialog3")
	filedialog = get_node("FileDialog")
	intervall = get_node("ConfirmationDialog3/MarginContainer/VBoxContainer/HBoxContainer2/Intervall")
	intervall_spinbox = get_node("ConfirmationDialog3/MarginContainer/VBoxContainer/HBoxContainer2/SpinBox_Intervall")
	well_options = get_node("ConfirmationDialog/MarginContainer/VBoxContainer/HBoxContainer2/OptionButton_Wells")
	farbe_options = get_node("ConfirmationDialog/MarginContainer/VBoxContainer/HBoxContainer3/OptionButton")
	# GUI
	intervall.hide()
	intervall_spinbox.hide()
	
	# Initialisiere die GUI-Werte
	init_wells()
	init_farbe()
	init_messmethode()
	init_wellenlaenge()
	init_wellenlaenge_Anregung_Emission()
	init_wellenlaenge_Absorption()
	init_filedialog()
	

func _process(delta):
	var selected_mess_methode = messmethode_options.get_selected()
	
	if(selected_mess_methode != selected_item_mess):
		selected_item_mess = messmethode_options.get_selected() 
		global.messen_flag = true
	
	# Damit es nur einmal ausgefuehrt wird
	if(global.messen_flag):
		global.messen_flag = false
		if(selected_mess_methode > 0):
			update_messmethode(0)
		if(messmethode_options.get_item_text(selected_mess_methode) == "Absorption"):
			update_messmethode(1)
	
	# Berechnungen
	if(timer_flag):
		#Neuer Random Seed, um jedes mal ein anderes Rauschen zu bekommen
		randomize()
		#Das Array aus der Mikrotiterplatte auf der Arbeitsplatte holen,
		#um die Inhalte auszulesen
		var wells = get_node("/root/Main/Arbeitsplatte/Mikrotiterplatte").plate_2d_array
		var selectedWells = get_parent().selectedWells
		var size_x = wells.size()
		var size_y = wells[0].size()
		
		FI_Werte = []
		FI_Werte.resize(messzyklen)
		#Für jeden Messzyklus
		for m in range(messzyklen):
			FI_Werte[m] = []
			FI_Werte[m].resize(size_x)
			for i in range(size_x):
				FI_Werte[m][i] = []
				FI_Werte[m][i].resize(size_y)
		
		# Well Durchmesser wird standardmäßig als 6.8 angenommen.
		var well_durchmesser = 6.8 # millimeter
		for m in range(messzyklen):
			randomize()
			for i in range(size_x):
				for j in range(size_y):
					# Berechnungen nur für die ausgewählten Wells durchführen
					if(selectedWells[i][j]):
						var cav = wells[i][j].cavity
						
						# Leere Wells erhalten den Wert -1
						if(cav.content_volume == 0):
							FI_Werte[m][i][j] = -1
							continue
						else:
							# Wenn es kein Reagenz oder kein Biomolekül in der Kavität gibt,
							# erhält sie den Wert -2, der durch Rauschen ersetzt wird.
							if(cav.vRea == 0.0 || cav.vBio == 0.0):
								FI_Werte[m][i][j] = -2
								continue
								
						# Finde die Stoffmengenkonzentration von Ligand und Rezeptor.
						var c_ligand = (((cav.reagent.mass_concentration * global.SKALIERUNGS_FAKTOR) / cav.reagent.molecular_weight) * cav.vRea) / cav.content_volume
						var c_rezeptor = (((cav.biomolecule.mass_concentration * global.SKALIERUNGS_FAKTOR) / cav.biomolecule.molecular_weight) * cav.vBio) / cav.content_volume
						
						# Berechne die Schichtdicke
						var schichtdicke = Berechnungen.compute_schichtdicke(
							cav.content_volume,
							well_durchmesser,
							0)
						# Berechne die Absorption
						var absorption = Berechnungen.compute_absorption(
							float(c_ligand),
							schichtdicke,
							cav.reagent.ext_max)
						
						# Absorption | FL_Intensität | FL_Polarisation
						var messmethode = messmethode_options
						
						# Schwarze Platte mit Absorption - soll Unfug kommen.
						if (global.microPlateColor == "black" && messmethode.get_item_text(messmethode.get_selected_id()) == "Absorption"):
							absorption = absorption * rand_range(0.1,3.5)
							
						var FI_Wert = 0
						
						# Absorption
						if(messmethode.get_item_text(messmethode.get_selected_id()) == "Absorption"):
							FI_Wert = absorption
						else:
							var saettigung = Berechnungen.compute_saettigung(
								float(c_rezeptor),
								float(c_ligand),
								cav.reagent.kd[1])
							
							# Fluoreszenzintensität
							if(messmethode.get_text() == "Fluoreszenz"):
								var FI_geb = cav.reagent.FI_geb
								
								FI_Wert = Berechnungen.compute_FI(
									absorption,
									FI_geb,
									saettigung)
							else:
								# Fluoreszenz-Polarisation
								if(messmethode.get_text() == "Fluoreszenz-Polarisation"):
									FI_Wert = Berechnungen.compute_FA(
										cav.reagent.A_frei,
										cav.reagent.A_geb,
										saettigung)
						
						# Speichern des erhaltenenen Fluoreszenzwertes.
						FI_Werte[m][i][j] = FI_Wert
					else:
						# Nicht ausgewählte Wells erhalten 0 als Wert.
						FI_Werte[m][i][j] = 0
		
		# Maximum in FI_Werte finden
		var max_val = []
		max_val.resize(messzyklen)
		for m in range(messzyklen):
			max_val[m] = 1
			for i in range(size_x):
				for j in range(size_y):
					max_val[m] = max(max_val[m], FI_Werte[m][i][j])
		
		for m in range(messzyklen):
			for i in range(size_x):
				for j in range(size_y):
					# Nicht ausgewählte Wells
					if (FI_Werte[m][i][j] == -1):
						FI_Werte[m][i][j] = 0
					else:
						# Nicht korrekt befüllte Wells
						if (FI_Werte[m][i][j] == -2):
							FI_Werte[m][i][j] = rand_range(0,40000)
						else:
							# Normalisieren der Werte
							FI_Werte[m][i][j] = Berechnungen.normalize_FI(FI_Werte[m][i][j], max_val[m])
		timer_flag = false
		
	# Intelligente Mikrotiterplattenauswahl
	if (global.plate_changed and global.microPlateType == "96"):
		global.plate_changed = false
		update_messmethode(1)
		# ID 0 == 96er Platte
		well_options.select(0)
		if (global.microPlateColor == "black"):
			# ID 0 == schwarz
			farbe_options.select(0)
		if(global.microPlateColor == "transparent"):
			# ID 1 == transparent
			farbe_options.select(1)
	if (global.plate_changed and global.microPlateType == "384"):
		# ID 1 == 384er Platte
		well_options.select(1)
		if (global.microPlateColor == "black"):
			# ID 0 == schwarz
			farbe_options.select(0)
		if(global.microPlateColor == "transparent"):
			# ID 1 == transparent
			farbe_options.select(1)

#######################################################################################
#################################### Init Methods #####################################
#######################################################################################

# Fuegt die Verfuegbaren Well-Optionen hinzu
func init_wells():
	well_options.add_item("96", 0) # ID = 0
	well_options.add_item("384", 1) # ID = 1
	# Die Optionen sollen nicht anklickbar sein -> Intelligente Mikrotiterplattenauswahl
	well_options.set_item_disabled(0,true)
	well_options.set_item_disabled(1,true)

# Fuegt die Verfuegbaren Farb-Optionen hinzu
func init_farbe():
	farbe_options.add_item("Schwarz", 0) # ID = 0
	farbe_options.add_item("Transparent", 1) # ID = 1
	# Die Optionen sollen nicht anklickbar sein -> Intelligente Mikrotiterplattenauswahl
	farbe_options.set_item_disabled(0,true)
	farbe_options.set_item_disabled(1,true)

# Fuegt die Verfuegbaren Messtmethoden hinzu
func init_messmethode():
	messmethode_options = get_node("ConfirmationDialog/MarginContainer/VBoxContainer/HBoxContainer4/OptionButton_Messen")
	messmethode_options.add_item("Absorption", 0) # ID = 0
	messmethode_options.add_item("Fluoreszenz", 1) # ID = 1
	messmethode_options.add_item("Fluoreszenz-Polarisation", 2) # ID = 2
	
	selected_item_mess = 0

func init_wellenlaenge():
	anregung_emission_wellenlaenge = get_node("ConfirmationDialog/MarginContainer/VBoxContainer/HBoxContainer5/OptionButton_WL_Anregung_Emission2")
	anregung_emission_wellenlaenge.add_item("280-320", 0)
	anregung_emission_wellenlaenge.add_item("380-440", 1)
	anregung_emission_wellenlaenge.add_item("490-525", 2)
	anregung_emission_wellenlaenge.add_item("530-560", 3)

func init_wellenlaenge_Anregung_Emission():
	anregung_emission = get_node("ConfirmationDialog/MarginContainer/VBoxContainer/HBoxContainer5/OptionButton_WL_Anregung_Emission")
	anregung_emission.add_item("Anregung/Emission", 0)

func init_wellenlaenge_Absorption():
	absorption_wellenlaenge = get_node("ConfirmationDialog/MarginContainer/VBoxContainer/HBoxContainer5/OptionButton_WL_Absorption")
	absorption_wellenlaenge.hide()
	absorption_wellenlaenge.add_item("280", 0)
	absorption_wellenlaenge.add_item("490", 1)
	absorption_wellenlaenge.add_item("520", 2)

func init_filedialog():
	# Wir wollen nur .csv Datein speichern
	filedialog.add_filter(".csv")
	# ID: 2 - ACCESS_FILESYSTEM, damit der Benutzer Zugriff auf das Filesystem vom PC hat
	filedialog.set_access(2) 
	# Pfad, wo das File Directory startet
	filedialog.set_current_dir(".")
	# Name der Datei: messergebnisse.csv
	filedialog.set_current_file("messergebnisse")

#######################################################################################
################################### Update Methods ####################################
#######################################################################################
func update_messmethode(ID):
	# Wenn die Platte transparent ist, soll auch die Absorption ausgewählt werden können
	if(ID == 1):
		anregung_emission_wellenlaenge.hide()
		anregung_emission.hide()
		absorption_wellenlaenge.show()
	else:
		anregung_emission_wellenlaenge.show()
		anregung_emission.show()
		absorption_wellenlaenge.hide()

# Schaltet je nach Prädikat das Intervall auf sichtbar oder versteckt um
func toggle_kinetik(enabled):
	if(enabled):
		intervall.show()
		intervall_spinbox.show()
	else:
		intervall.hide()
		intervall_spinbox.hide()

# Wenn mehr als 1 Zyklus angegeben wird, soll der Intervall angezeigt werden
func _on_SpinBox_Zyklen_value_changed(value):
	messzyklen = value
	if(value > 1):
		toggle_kinetik(true)
	else:
		toggle_kinetik(false)


#######################################################################################
#################################### Switch Popups ####################################
#######################################################################################

func _on_Messgeraet_draw():
	konfiguration.popup_centered()

# Wenn die Konfiguartion bestaetigt wurde, soll zur Wellsauswahl gewechselt werden
func _on_ConfirmationDialog_confirmed():
	wells.popup_centered()

# Wenn die Wellsauswahl bestaetigt wurde, soll zur Kinetik gewechselt werden
func _on_ConfirmationDialog2_confirmed():
	kinetik.popup_centered()

# Wenn die Kinetik bestaetigt wurde, soll zum FileDialog gewechselt werden
func _on_ConfirmationDialog3_confirmed():
	filedialog.popup_centered()
	timer_flag = true

# Wenn der Speichern Button geklickt wurde, soll eine neue Datei erstellt werden und diese auch befuellt werden
# Sowohl für den User, als auch fuer den Assistenten
func _on_FileDialog_confirmed():
	var file_name = filedialog.get_current_path()
	file_student.open(file_name + ".csv", file_student.WRITE_READ)
	# Befuellen der CSV Datei
	fill_student_file(file_student, false)
	# Schließe die Datei nach dem Befuellen
	file_student.close()
	
	# Datei für den Assistenten
	var file_name_assistent = file_name + "_assistent"
	file_assistant.open(file_name_assistent + ".csv", file_assistant.WRITE_READ)
	fill_student_file(file_assistant, true)
	file_assistant.close()

func _on_OptionButton_WL_Anregung_Emission2_item_selected(ID):
	global.messen_anregung = ID
	
func _on_OptionButton_WL_Absorption_item_selected(ID):
	global.messen_anregung = ID

#######################################################################################
##################################### Write File  #####################################
#######################################################################################
# Schreibe die Datei
func fill_student_file(file, is_assistent):
	var buchstaben = buchstaben_h
	var maxrange_i = 9
	var maxrange_j = 13
	var end_j = 12
	if(global.microPlateType == "384"):
		buchstaben = buchstaben_p
		maxrange_i = 17
		maxrange_j = 25
		end_j = 24
	
	if(is_assistent):
		# TODO: Alle nötigen Sachen für den Assistenten reinschreiben. Spitzenverbrauch usw
		file.store_string("Spitzen Weiss:; %d ; \n" % global.mSpitzenWeiss)
		file.store_string("Spitzen Gelb:; %d ; \n" % global.mSpitzenGelb)
		file.store_string("Spitzen Blau:; %d ; \n" % global.mSpitzenBlau)
		file.store_string("Tubes: %d ; \n" % global.mTubes)
	
	# Wir fuehren je nach Messzyklen auch mehrere Berechnungsschritte durch
	for m in range(0,messzyklen):
		for i in range(0,maxrange_i):
			# Jede Zeile ausser der ersten soll mit einem Buchstaben in der 1. Zelle beginnen
			if(i != 0):
				file.store_string("%s" % buchstaben[i] + ";")
			for j in range(0,maxrange_j):
				# Die 1. Zeile soll die mit den Zahlen befuellt werden
				if(i == 0):
					# Die 1. Zelle soll leer gespeichert werden
					if(j == 0):
						file.store_string("" + ";")
					# Bei der letzten Zelle sollen wir eine Zeile weiter springen
					elif(j == end_j):
						file.store_string("%d" % j + ";" + "\n")
					# Fuelle jede Zelle mit der passenden Zahl
					else:
						file.store_string("%d" % j + ";")
				else:
					# Neue Zeile
					if(j == end_j and i != 0):
						file.store_string("\n")
					# Fuelle jede passende Zelle mit einem neuen Wert
					else:
						# Wenn das Well auch ausgewählt ist, schreibe den richtigen 
						# Wert in die passende Zelle
						if(get_parent().selectedWells[j][i-1]):
							file.store_string("%d" % float(FI_Werte[m][j][i-1]) + ";")
						else:
							# Sonst ein x
							file.store_string("x;")
		file.store_string("\n")
		file.store_string("\n")
