#Mikrotiterplatte

#@author Ivelin Ivanov
#@author Benedikt Dreher

extends Node2D

signal kav_slot_mouse_over(a, b)

#Genau wie beim Eppendorf Rack, wird hier ein 2D Array erstellt,
#in dem dann jedes Slot eine Kavität als Kind beinhaltet. Auch wenn
#Die Kavitäten in Wirklichkeit eins mit der Platte sind, wurde dieser Ansatz
#genommen, um die im Grunde gleiche Funktionalität von Tubes und Kavitäten
#nur einmal programmieren zu müssen. 
var plate_2d_array = []

#Array für die Beschriftungen der Mikrotiterplatte. Nur die erste Spalte
#und erste Zeile werden verwendet.
var grid_labels = []
var width
var height

var mouse_over = false

func _ready():
	#Die Position wird benötigt, um die Beschriftungen und Slots richtig zu
	#positionieren
	var plate_position = self.get_node("PlatteHintergrund").get_position()
	var offsetX = 0
	var offsetY = 0
	var scale = 0
	#colorOverride für die Textfarbe, damit sie bei schwarzen und transparenten
	#Platten gleichermaßen sichtbar bleibt.
	var colorOverride
	if (global.microPlateType == "96"):
		#Hier wird durch 13 bzw. 9 anstatt durch 12 und 8 dividiert,
		#weil die Koordinatenlabels eine zusätzliche Zeile und Spalte
		#erzeugen. 
		offsetX = get_node("PlatteHintergrund").rect_size.x / 13
		offsetY = get_node("PlatteHintergrund").rect_size.y / 9
		width = 12
		height = 8
		scale = 1.5
	elif (global.microPlateType == "384"):
		#Hier genauso durch 25 anstatt 24 und 17 anstatt 16
		offsetX = get_node("PlatteHintergrund").rect_size.x / 25
		offsetY = get_node("PlatteHintergrund").rect_size.y / 17
		width = 24
		height = 16
		scale = 0.8
	#Plattenhintergrund auf schwarz oder transparent setzen
	if (global.microPlateColor == "transparent"):
		get_node("PlatteHintergrund").set_texture(load("res://Texture/Mikrotiterplatte_W.png"))
		colorOverride = 0
	elif (global.microPlateColor == "black"):
		get_node("PlatteHintergrund").set_texture(load("res://Texture/Mikrotiterplatte_B.png"))
		colorOverride = 1
	init_labels(plate_position.x + 1, plate_position.y + 1, offsetX, offsetY, scale, colorOverride)
	init_array(plate_position.x + offsetX, plate_position.y + offsetY, offsetX, offsetY, scale)


#Dictionary, um die Arrayindices in Buchstaben umzuwandeln, für die Beschriftung der Platte
var label_dict = {1 : "A", 2 : "B", 3 : "C", 4 : "D", 5 : "E", 6 : "F", 7 : "G", 8 : "H",
				9 : "I", 10 : "J", 11 : "K", 12 : "L", 13 : "M", 14 : "N", 15 : "O", 16 : "P"}


func init_labels(x, y, offsetX, offsetY, scale, co):
	var coords = Vector2(x,y)
	var number = 1
	grid_labels.resize(width+1)
	#Iterieren über die x Koordinate
	for i in range(grid_labels.size()):
		var column = []
		column.resize(height+1)
		var label = Label.new()
		label.set_name("Label_%d_%d" % [0,i])
		label.align = Label.ALIGN_LEFT
		add_child(label)
		#Nur für die erste Spalte über die y Koordinate iterieren
		if (i == 0):
			coords.y += offsetY
			for k in range(1, column.size()):
				var labelY = Label.new()
				labelY.set_name("Label_%d_%d" % [0,i])
				labelY.valign = Label.VALIGN_FILL
				add_child(labelY)
				labelY.set_text(label_dict[k])
				labelY.add_color_override("font_color", Color(co,co,co,1))
#				labelY.rect_size = Vector2(offsetX / 1, offsetY / 1)
				labelY.set_position(coords)
				labelY.set_scale(Vector2(0.17 * scale, 0.25 * scale))
				column[k] = labelY
				coords.y += offsetY
		else:
			label.set_text(str(number))
			number += 1
			label.add_color_override("font_color", Color(co,co,co,1))
#			label.rect_size = Vector2(offsetX / 1.5, offsetY / 1.5)
			label.set_position(coords)
			label.set_scale(Vector2(0.17 * scale, 0.25 * scale))
			column[0] = label
			coords.y += offsetY
		coords.y = y
		coords.x += offsetX
		grid_labels[i] = column
	return grid_labels

#2D Array initialisieren, in dem die Kavitäten dann als Kinder der einzelnen Slots
#gespeichert werden.
func init_array(x, y, offsetX, offsetY, scale):
	var counter = 1
	var coords = Vector2(x,y)
	plate_2d_array.resize(width)
	#Iterieren über die x Koordinate
	for i in range(width):
		plate_2d_array[i] = []
		plate_2d_array[i].resize(height)
		#Iterieren über die y Koordinate
		for k in range(height):
			#Jedes Slot ist ein eigenes neues Node, dessen Kind eine Kavität wird
			var currentCavSlot = CavSlot.new()
			currentCavSlot.x = i
			currentCavSlot.y = k
			currentCavSlot.name = "Kavitaet %s%d" % [grid_labels[0][k+1].get_text(),i+1]
			add_child(currentCavSlot)
			currentCavSlot.set_scale(Vector2(0.17*scale,0.25*scale))
			currentCavSlot.set_position(coords)
			var cavSlotTex = CavSlotTex.new()
			var tex = load("res://Texture/CavityEmpty.png")
			cavSlotTex.set_texture(tex)
			currentCavSlot.add_child(cavSlotTex)
			var currentCavity = load("res://Script/Kavitaet.gd").new()
			currentCavity._setup()
			currentCavity.id = counter
			currentCavSlot.add_child(currentCavity)
			currentCavSlot.cavity = currentCavity
			plate_2d_array[i][k] = currentCavSlot
			coords.y += offsetY
			counter += 1
		coords.y = y
		coords.x += offsetX

#Nachdem ein Slot geklickt wurde, diesen neu zeichnen, für den Fall,
#das etwas hinein oder herauspipettiert wurde
func slot_clicked(slot):
	if (global.maus == global.Pickable_Items.pipette):
		redraw_well(slot)

#die eigentliche Funktion zum neu zeichnen
func redraw_well(slot):
	if (slot.cavity.content_volume > 0):
		slot.get_child(0).set_texture(load("res://Texture/CavityFull.png"))
	else:
		slot.get_child(0).set_texture(load("res://Texture/CavityEmpty.png"))

#Wird für das Messgerät benötigt, um die ausgewählten Wells anzuzeigen
func redraw_well_selected(slot):
	slot.get_child(0).set_texture(load("res://Texture/CavitySelected.png"))

#Wird für das Messgerät benötigt, um die Mikroplatte beim Öffnen des Messgeräts
#dort neu zu zeichnen, um sie aktuell zu halten
func redraw_all_wells():
	for i in range(plate_2d_array.size()):
		for k in range(plate_2d_array[i].size()):
			redraw_well(plate_2d_array[i][k])


#Signal zum Pipettieren.gd senden, dass ein Slot angesteuert wurde
#und eventuell pipettiert werden muss
func slot_on_mouseover(slot, active):
	var cavSlot = slot.cavity
	if (get_node("/root/Main").has_node("Arbeitsplatte") && get_node("/root/Main/Arbeitsplatte") != null && get_node("/root/Main/Arbeitsplatte").visible):
		cavSlot.show_tooltip(active)
	emit_signal("kav_slot_mouse_over", slot, active)


#Input Event handler um die Platte zu drehen, anzuheben und abzulegen
func _input(event):
	if (mouse_over):
		if (event is InputEventMouseButton):
			if (Input.is_action_pressed("ctrl") && event.button_index == BUTTON_LEFT && global.maus == global.Pickable_Items.maus):
				global.maus = global.Pickable_Items.mikroplatte
				move_child(get_node("Platte_Control"), get_child_count())
				z_index = 1
				Input.set_mouse_mode(1)
			elif (event.button_index == BUTTON_RIGHT && global.maus == global.Pickable_Items.mikroplatte):
				global.maus = global.Pickable_Items.maus
				move_child(get_node("Platte_Control"), 1)
				z_index = 0
				Input.set_mouse_mode(0)
		elif (global.maus == global.Pickable_Items.mikroplatte && Input.is_action_just_pressed("rotate")):
			rotation_degrees = fmod(rotation_degrees, 360) + 90


func _on_Platte_Control_mouse_entered():
	mouse_over = true


func _on_Platte_Control_mouse_exited():
	mouse_over = false
#Klasse, die die Slots modelliert
class CavSlot extends Node2D:
	var x
	var y
	var is_selected = false
	var cavity


#Klasse, die die Textur der Slots modelliert. Wird benötigt, weil sie
#ein Control ist und somit Input Events bearbeiten und erzeugen kann,
#z.B. beim Anklicken mit Pipette in der Hand
class CavSlotTex extends TextureRect:
	var mouse_over = false
	func _ready():
		connect("mouse_entered", self, "_mouse_entered")
		connect("mouse_exited", self, "_mouse_exited")
		set_process_input(true)
	func _mouse_entered():
		self.mouse_over = true
		set_scale(Vector2(1.35,1.35))
		get_parent().get_parent().slot_on_mouseover(get_parent(), true)
	func _mouse_exited():
		self.mouse_over = false
		set_scale(Vector2(1,1))
		get_parent().get_parent().slot_on_mouseover(get_parent(), false)
