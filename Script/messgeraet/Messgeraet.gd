#Hauptnode für das Messgerät. Hier wird hauptsächlich die Darstellung
#der Mikrotiterplatte in ConfirmationDialog2 gesteuert. Es ist eine neue
#Instanz der gleichen Mikrotiterplatte wie auf der Arbeitsplatte
#Die Platte hier wird NUR zum Darstellen benutzt! Die Inhalte und Füllmengen
#der einzelnen Slots werden von der "richtigen" Mikrotiterplatte auf der
#Arbeitsplatte ausgelesen

#@author Ivelin Ivanov
#@author Adrian Wagener

extends Control

var active = false

signal redraw_all_wells
signal redraw_well_selected(a)
signal redraw_well(a)

#Array mit den ausgewählten Wells, die später für die Berechnungen später
#benötigt werden. Die Größe und die einzelnen Positionen entsprechen denen
#von der Mikrotiterplatte
var selectedWells = []
var currentSlot
var mouse_over_well = false
var slotProcessed = false

func _ready():
	connect_signals()
	microplate_selected()

#Input Event Handler um die Wells auszuwählen, die später ausgewertet werden sollen
func _input(event):
	#Schnellauswahl über Ctrl + A und schnellabwahl über Ctrl + S
	if (mouse_over_well && Input.is_action_pressed("ctrl") && event is InputEventKey && !slotProcessed):
		if (event.scancode == KEY_A):
			selectedWells[currentSlot.x][currentSlot.y] = true
			emit_signal("redraw_well_selected", currentSlot)
			slotProcessed = true
		if (event.scancode == KEY_S):
			selectedWells[currentSlot.x][currentSlot.y] = false
			emit_signal("redraw_well", currentSlot)
			slotProcessed = true
	#Auswahl von einzelnen Wells durch Anklicken
	elif (mouse_over_well && event is InputEventMouseButton && event.is_pressed()):
		if (event.button_index == BUTTON_LEFT):
			selectedWells[currentSlot.x][currentSlot.y] = true
			emit_signal("redraw_well_selected", currentSlot)
			slotProcessed = true
		elif (event.button_index == BUTTON_RIGHT):
			selectedWells[currentSlot.x][currentSlot.y] = false
			emit_signal("redraw_well", currentSlot)
			slotProcessed = true

#Kavität wurde mit der Maus überfahren
func _on_kslot_mouse_over(slot, active):
	mouse_over_well = active
	currentSlot = slot
	slotProcessed = false

#Bei jedem Anzeigen des Messgeräts die Mikrotiterplatte neu zeichnen, um
#immer die aktuell befüllten Wells angezeigt zu bekommen
func _on_Messgeraet_draw():
	active = true
	var array = get_node("/root/Main/Arbeitsplatte/Mikrotiterplatte").plate_2d_array
	var mikroplatte = get_node("Einstellungen/ConfirmationDialog2/Mikrotiterplatte")
	for i in range(array.size()):
		for k in range(array[i].size()):
			mikroplatte.plate_2d_array[i][k].cavity.content_volume = array[i][k].cavity.content_volume
	emit_signal("redraw_all_wells")

func _on_Messgeraet_hide():
	active = false

func microplate_selected():
	var mikroplatteOld = get_node("Einstellungen/ConfirmationDialog2/Mikrotiterplatte")
	var position = mikroplatteOld.get_position()
	get_node("Einstellungen/ConfirmationDialog2").remove_child(mikroplatteOld)
	var mikroplatteNew = load("res://Scene/Arbeitsplatte/Mikrotiterplatte.tscn").instance()
	mikroplatteNew.set_position(position)
	get_node("Einstellungen/ConfirmationDialog2").add_child(mikroplatteNew)
	var array = mikroplatteNew.plate_2d_array
	selectedWells.resize(array.size())
	for i in range(array.size()):
		selectedWells[i] = []
		selectedWells[i].resize(array[i].size())
		for k in range (array[i].size()):
			selectedWells[i][k] = false
	connect_signals()

func connect_signals():
	get_node("Einstellungen/ConfirmationDialog2/Mikrotiterplatte").connect("kav_slot_mouse_over", self, "_on_kslot_mouse_over")
	connect("redraw_all_wells", get_node("Einstellungen/ConfirmationDialog2/Mikrotiterplatte"), "redraw_all_wells")
	connect("redraw_well_selected", get_node("Einstellungen/ConfirmationDialog2/Mikrotiterplatte"), "redraw_well_selected")
	connect("redraw_well", get_node("Einstellungen/ConfirmationDialog2/Mikrotiterplatte"), "redraw_well")