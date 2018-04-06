#Rack für Eppendorf Tubes

#@author Ivelin Ivanov
#@author Patrick Singh
#@author Olcay Ece

extends Node2D

signal tube_clicked_with_pipette(a)

var width = 16
var height = 5
var counter = 0
#Jeder Eintrag in diesem Array ist wiederum ein Array
#Die zweite Dimension wird bei Initialisieren erstellt
#Jeder Eintrag entspricht einem Slot im Rack
var rack_2d_array = []

#Eingabetextfeld für das Beschriften von Tubes
onready var line = LineEdit.new()

var currentSlot
var mouse_over = false


func _ready():
	line.set_scale(Vector2(0.178,0.64))
	line.rect_position = line.rect_position - Vector2(10,55)
	add_child(line)
	line.hide()
	init_array()


#2D Array initialisieren
func init_array():
	var rack_position = self.get_node("RackHintergrund").get_position()
	var x = rack_position.x + 3.2
	var y = rack_position.y + 2
	#Erst mal hardcodierte offsets, später könnte man diese Abhängig von der Größe des Racks machen
	var offsetX = get_node("RackHintergrund").rect_size.x / (width * 1.1)
	var offsetY = get_node("RackHintergrund").rect_size.y / height
	var coords = Vector2(x,y)
	rack_2d_array.resize(width)
	#Iterieren über die x Koordinate
	for i in range(width):
		rack_2d_array[i] = []
		rack_2d_array[i].resize(height)
		#Iterieren über die y Koordinate
		for k in range(height):
			#Jeder Slot ist ein eigenes neues Node, das ein Kind von Rack ist
			#Falls ein Tube hineingelegt wird, wird es zu einem Kind von dem Slot
			var currentSlot = RackSlot.new()
			currentSlot.x = k
			currentSlot.y = i
			add_child(currentSlot)
			#Skalierung notwendig, damit das Parent Node genau in der Mitte liegt
			#Was später das Drehen um die eigene Achse einfacher macht
			#Alternativ könnte man das Node nicht skalieren und nur in der Mitte
			#platzieren
			currentSlot.set_scale(Vector2(0.178,0.64))
			currentSlot.set_position(coords)
			var currentSlotTexture = TubeSlotTex.new()
			var tex = load("res://Texture/TubeSlot.png")
			currentSlotTexture.set_texture(tex)
			currentSlot.add_child(currentSlotTexture)
			rack_2d_array[i][k] = currentSlot
			coords.y += offsetY
		coords.y = y
		coords.x += offsetX


#Textfeld wird eingeblendet
func slot_shift_clicked(slot):
	if (slot.tube != null):
		line.show()
		get_node("TextEingabeInfo").popup()
		currentSlot = slot


#Hier wird unterschieden, ob ein leeres Slot angeklickt wurde
#oder ob schon ein Tube drin ist. Entsprechnd wird entweder das
#Tube wieder herausgeholt oder das neue hineineingelegt
func slot_clicked(slot):
	#Tube in der "Hand" bzw. am Mauszeiger
	if (global.maus == global.Pickable_Items.tube):
		#Slot ist leer, Tube wird hineingelegt
		if (slot.tube == null):
			slot.add_child(global.activeTube)
			slot.tube = global.activeTube
			slot.name = "Tube ID: %s" % slot.tube.id
			global.activeTube = null
			global.maus = global.Pickable_Items.maus
			var tubeTexture
			if (slot.tube.content_volume > 0):
				tubeTexture = load("res://Texture/TubeFull.png")
			else:
				tubeTexture = load("res://Texture/TubeEmpty.png")
			slot.get_child(0).set_texture(tubeTexture)
			get_parent().get_node("Tube").visible = false
			get_parent().get_node("Tube").set_z_index(0)
			Input.set_mouse_mode(0)
	#Tube im Slot, "Hand" leer, Tube herausholen
	elif (global.maus == global.Pickable_Items.maus && slot.tube != null && !line.visible):
		global.maus = global.Pickable_Items.tube
		global.activeTube = slot.tube
		slot.tube.show_tooltip(false)
		slot.remove_child(slot.tube)
		slot.tube = null
		var tubeTexture = load("res://Texture/TubeSlot.png")
		slot.get_child(0).set_texture(tubeTexture)
		get_parent().get_node("Tube").visible = true
		get_parent().get_node("Tube").set_z_index(1)
		Input.set_mouse_mode(1)
	#Tube ist im Slot, wird mit Pipette angeklickt -> signal an Pipettieren.gd wird gesendet
	elif (slot.tube != null && global.maus == global.Pickable_Items.pipette):
		slot.tube.used = true
		emit_signal("tube_clicked_with_pipette", slot.tube)
		var tubeTexture
		if(slot.tube.content_volume > 0):
			tubeTexture = load("res://Texture/TubeFull.png")
		else:
			tubeTexture = load("res://Texture/TubeEmpty.png")
		slot.get_child(0).set_texture(tubeTexture)


#Anheben/Ablegen und Drehen. Die Slots werden hier nicht behandelt, weil sie eigene
#Nodes sind und somit eigene Input Events erzeugen und bearbeiten müssen. Siehe weiter unten
func _input(event):
	if (mouse_over):
		if (event is InputEventMouseButton):
			if (Input.is_action_pressed("ctrl") &&  event.button_index == BUTTON_LEFT && global.maus == global.Pickable_Items.maus):
				global.maus = global.Pickable_Items.rack
				move_child(get_node("Tuberack_Control"), get_child_count())
				z_index = 1
				Input.set_mouse_mode(1)
			elif (event.button_index == BUTTON_RIGHT && global.maus == global.Pickable_Items.rack):
				global.maus = global.Pickable_Items.maus
				move_child(get_node("Tuberack_Control"), 1)
				z_index = 0
				Input.set_mouse_mode(0)
		elif (global.maus == global.Pickable_Items.rack && Input.is_action_just_pressed("rotate")):
			rotation_degrees = fmod(rotation_degrees, 360) + 90
	if (event is InputEventKey && event.scancode == KEY_ENTER && line.visible):
		update_tube_id(line.text)
		line.hide()

#Eigene Beschriftung aktualisieren
func update_tube_id(text):
	currentSlot.tube.custom_name += text


func slot_on_mouseover(slot, active):
	if (slot.tube != null):
		if (active):
			slot.tube.show_tooltip(true)
		else:
			slot.tube.show_tooltip(false)


func _on_RackHintergrund_mouse_entered():
	mouse_over = true


func _on_RackHintergrund_mouse_exited():
	mouse_over = false

#Klasse, die die Slots modelliert
class RackSlot extends Node2D:
	var x
	var y
	var is_selected = false
	var tube

#Klasse, die die Textur der Slots modelliert. Wird benötigt, weil sie
#ein Control ist und somit Input Events bearbeiten und erzeugen kann,
#z.B. beim Anklicken mit Tube oder Pipette in der Hand
class TubeSlotTex extends TextureRect:
	var mouse_over = false
	func _ready():
		connect("mouse_entered", self, "_mouse_entered")
		connect("mouse_exited",self,"_mouse_exited")
	#Hier wird das Input Event behandelt
	func _input(event):
		if mouse_over and event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT && event.is_pressed() && Input.is_action_pressed("shift"):
				get_parent().get_parent().slot_shift_clicked(get_parent())
			if event.button_index == BUTTON_LEFT && event.is_pressed() && !Input.is_action_pressed("shift"):
				get_parent().get_parent().slot_clicked(get_parent())
	func _mouse_entered():
		self.mouse_over = true
		set_scale(Vector2(1.35,1.35))
		get_parent().get_parent().slot_on_mouseover(get_parent(), true)
	func _mouse_exited():
		self.mouse_over = false
		set_scale(Vector2(1,1))
		get_parent().get_parent().slot_on_mouseover(get_parent(), false)
