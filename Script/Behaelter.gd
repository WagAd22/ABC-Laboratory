extends Node

#Oberklasse für alle Arten von befüllbaren Behältern
#Kapazität in Mikrolitern
var capacity
#Momentanen Inhalt in Mikrolitern
var content_volume
#Volumen der einzelnen Biomoleküle
var vBio
#Volumen des Reagenz
var vRea
#Volumen des Puffers
var vBuf
#Biomoleküle
var biomolecule
#Reagenz
var reagent
#Puffer
var buffer
#Behältertyp
enum Type {
	tube,
	cavity,
	reservoir
}
var id = 0
#Labels
var tooltip_label
var tooltip_panel
var custom_name = ""
var used

func _setup():
	capacity = 0
	content_volume = 0.0
	vBio = 0.0
	vRea = 0.0
	vBuf = 0.0
	used = false
	tooltip_panel = Panel.new()
	tooltip_label = Label.new()
	self.add_child(tooltip_panel)
	tooltip_panel.add_child(tooltip_label)
#	tooltip_label.add_color_override("font_color", Color(0,0,0,1))
#	tooltip_label.set_scale(Vector2(1,1))
	tooltip_panel.set_size(Vector2(220, 70))
	tooltip_panel.set_visible(false)

func show_tooltip(enable):
	if (!enable):
		tooltip_panel.set_visible(false)
		return
	var mouse_pos = tooltip_panel.get_global_mouse_position()
	tooltip_panel.set_position(Vector2(mouse_pos.x + 20, mouse_pos.y + 20))
	var bio_concentration = 0.0
	var rea_concentration = 0.0
	if (content_volume == 0):
		bio_concentration = 0
		rea_concentration = 0
	else:
		if (biomolecule != null):
			var b_con = float(biomolecule.mass_concentration) / float(biomolecule.molecular_weight)
			bio_concentration = b_con * (vBio / content_volume)
		if (reagent != null):
			var r_con = float(reagent.mass_concentration) / float(reagent.molecular_weight)
			rea_concentration = r_con * (vRea / content_volume)
	var text = get_parent().name
	if (custom_name != ""):
		text += " (%s)" % custom_name
	text += "\nFüllstand gesamt: %.1f µL"
	text = text % content_volume
	text += "\nKonz. Biom.: %f mg/mL"
	text = text % bio_concentration
	text += "\nKonz. Reag.: %f mg/mL"
	text = text % rea_concentration
	tooltip_label.set_text(text)
	tooltip_panel.set_visible(true)



#content ist ein Array, dessen Einträge aus jeweils dem Stoff und der Menge bestehen
#content[x][0] ist der Stoff selber, content[x][1] ist die Menge
func add(content):
	var remaining_capacity = capacity - content_volume
	var cont = content
	var ratio = float(remaining_capacity) / float(total_volume(cont))
	var rest_content = []
	rest_content.resize(content.size())
	if (ratio > 1):
		ratio = 1
	for i in range(content.size()):
		var current_material = content[i][0]
		var current_volume = content[i][1]
		var rest = round((1 - ratio) * current_volume)
		var material_to_be_added = ratio * current_volume
		if (content[i][0].type == "buffer"):
			vBuf += material_to_be_added
			buffer = current_material
		elif (content[i][0].type == "reagent"):
			vRea += material_to_be_added
			reagent = current_material
		elif (content[i][0].type == "biomolecule"):
			vBio += material_to_be_added
			biomolecule = current_material
		rest_content[i] = [current_material, rest]
	content_volume = total_volume(to_array())
	if (ratio >= 1):
		rest_content.resize(0)
	return rest_content

func remove(volume):
	var content_array = []
	if (content_volume == 0):
		return content_array
	var ratio = float(volume) / float(content_volume)
	if (ratio > 1):
		ratio = 1
	print(ratio)
#	content_array.resize(3)
	if (biomolecule != null):
		#Biomolekül entnehmen
		content_array.append([biomolecule, round(ratio * vBio)])
		vBio = vBio - (ratio * vBio)
	if (reagent != null):
		#Reagenz entnehmen
		content_array.append([reagent, round(ratio * vRea)])
		vRea = vRea - (ratio * vRea)
	if (buffer != null):
		#Puffer entnehmen
		content_array.append([buffer, round(ratio * vBuf)])
		vBuf = vBuf - (ratio * vBuf)
	#Wenn komplett entnommen, alles im Vessel zurücksetzen
	if (ratio >= 1):
		reset()
	content_volume = total_volume(to_array())
	return content_array

func total_volume(content_array):
	var volume = 0
	for i in range(content_array.size()):
		volume = volume + content_array[i][1]
	return int(volume)

func to_array():
	var array = []
	if (biomolecule != null):
		array.append([biomolecule, vBio])
	if (reagent != null):
		array.append([reagent, vRea])
	if (buffer != null):
		array.append([buffer, vBuf])
	return array
	#return [[biomolecule, vBio], [reagent, vRea], [buffer, vBuf]]

func reset():
	biomolecule = null
	reagent = null
	buffer = null
	vBio = 0
	vRea = 0
	vBuf = 0
	content_volume = total_volume(to_array())

func full():
	return (content_volume >= capacity)

