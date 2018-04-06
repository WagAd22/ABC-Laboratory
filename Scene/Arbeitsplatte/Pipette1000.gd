#1000µL Pipette

#@author Patrick Singh

extends "res://Scene/Arbeitsplatte/PipetteMain.gd"

func _ready():
	minVolume = 100
	maxVolume = 1000
	volumen = maxVolume
	step = 1
	spitzeAn = false
	spitzeFarbe = "blau"
	volumeLabel = get_node("Label")
	volumeLabel.text = String(volumen)