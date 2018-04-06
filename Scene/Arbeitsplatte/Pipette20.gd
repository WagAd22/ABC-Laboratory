#20µL Pipette

#@author Patrick Singh

extends "res://Scene/Arbeitsplatte/PipetteMain.gd"

func _ready():
	minVolume = 2
	maxVolume = 20
	volumen = maxVolume
	step = 0.1
	spitzeAn = false
	spitzeFarbe = "gelb"
	volumeLabel = get_node("Label")
	volumeLabel.text = String(volumen)