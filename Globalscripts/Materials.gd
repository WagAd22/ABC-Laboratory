extends Node

enum Type_Of_Material {
	buffer,
	biomolecule,
	reagent
}

class Material:
	var name
	var molecular_weight
	var mass_concentration
	var abs_max
	var ext_max
	var type

class Biomolecule extends Material:
	func _init():
		type = "biomolecule"
	func setup(name, molecular_weight, mass_concentration, abs_max, ext_max):
		self.name = name
		self.molecular_weight = molecular_weight
		self.mass_concentration = mass_concentration
		self.abs_max = abs_max
		self.ext_max = ext_max

class Buffer extends Material:
	var salt_concentration
	var buffer_concentration
	var ph_value
	var other_additives
	func _init():
		molecular_weight = 0
		mass_concentration = 0
		type = "buffer"
	func setup(name, salt_concentration, buffer_concentration, ph_value):
		self.name = name
		self.salt_concentration = salt_concentration
		self.buffer_concentration = buffer_concentration
		self.ph_value = ph_value

class Reagent extends Material:
	var emission_maximum
	var kd
	var nachweisgrenze
	var FI_geb
	var A_frei
	var A_geb
	var farbe
	func _init():
		type = "reagent"
	func setup(name, molecular_weight, mass_concentration, kd, abs_max, ext_max, emission_maximum,
		nachweisgrenze, FI_geb, A_frei, A_geb, farbe):
		self.name = name
		self.molecular_weight = molecular_weight
		self.mass_concentration = mass_concentration
		self.kd = kd
		self.abs_max = abs_max
		self.ext_max = ext_max
		self.emission_maximum = emission_maximum
		self.nachweisgrenze = nachweisgrenze
		self.FI_geb = FI_geb
		self.A_frei = A_frei
		self.A_geb = A_geb
		self.farbe = farbe