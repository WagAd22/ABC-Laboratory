#Node für die mathematischen Funktionen, die zur Berechnung
#notwendig sind

#@author Benedikt Dreher

extends Node

func _ready():
	pass

# Absorption A
func compute_absorption(c_ligand, schichtdicke, ext):
	var absorption = c_ligand * schichtdicke * ext
	var rauschen = rand_range(1,absorption*0.1)
	return absorption + rauschen

# l
# form == 0: Rund, form == 1: Quad.
func compute_schichtdicke(well_volumen, well_durchmesser, form):
	var nenner
	
	# Runder Well
	if (form == 0):
		nenner = PI * pow(well_durchmesser/2, 2)
	# Quadratischer Well
	else:
		nenner = pow(well_durchmesser, 2)
		
	# l = V / nenner
	# Die Schichtdicke soll 15% kleiner angenommen werden, als berechnet
	# Formeln_zur_Simulation.pdf Seite 4 Mitte
	return (well_volumen / nenner) * (1 - 0.15)

# B
# In einzelne Schritte zur Übersichtlichkeit unterteilt
func compute_saettigung(c_rezeptor, c_ligand, Kd):
	var b1 = 0.5
	var b3 = (Kd + c_rezeptor + c_ligand)
	var b4 = c_rezeptor * c_ligand
	var b5 = pow(b3, 2) / 4 - b4
	var b2 = sqrt(b5)
	var b6 = (b1 * b3 - b2) / c_ligand
	return b6

# Fluoreszenzintensität FI_mess
func compute_FI(absorption, FI_geb, saettigung):
	var FI = absorption * (1 - saettigung + FI_geb * saettigung)
	var rauschen = rand_range(1,FI*0.1)
	return FI + rauschen

func normalize_FI(FI, FImax):
	return 40000 * (FI/FImax)

# G
func compute_geratefaktor(I1, I2):
	return I1 / I2

# P
func compute_polarisation(I1, I2, G):
	return (I2 - G * I1) / (I2 + G * I1)

# Anisotropie
func compute_anisotropie(P):
	return 2 * P / (3 - P)

# Fluoreszenz-Polarisarion FA
func compute_FA(FA_frei, FA_geb, saettigung):
	var FA = FA_frei * (1 - saettigung) + FA_geb * saettigung
	var rauschen = rand_range(1,FA*0.1)
	return FA + rauschen