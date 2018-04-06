#10µL Pipette

#@author Patrick Singh

extends "res://Scene/Arbeitsplatte/PipetteMain.gd"

func _ready():
	minVolume = 1
	maxVolume = 10
	volumen = maxVolume
	step = 0.1
	spitzeAn = false
	spitzeFarbe = "weiss"
	volumeLabel = get_node("Label")
	volumeLabel.text = String(volumen)