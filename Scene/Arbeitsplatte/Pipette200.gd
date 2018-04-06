#200µL Pipette

#@author Patrick Singh

extends "res://Scene/Arbeitsplatte/PipetteMain.gd"

func _ready():
	minVolume = 20
	maxVolume = 200
	volumen = maxVolume
	step = 1
	spitzeAn = false
	spitzeFarbe = "gelb"
	volumeLabel = get_node("Label")
	volumeLabel.text = String(volumen)