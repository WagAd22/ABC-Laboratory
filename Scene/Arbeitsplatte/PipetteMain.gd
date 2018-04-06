#Oberklasse mit gemeinsamen Werten für alle Pipetten

#@author Ivelin Ivanov


extends Node2D

var maxVolume
var minVolume
var volumen
var inhalt = []
var spitzeAn
var spitzeFarbe
var step
var volumeLabel


func get_inhaltMenge():
	var menge = 0
	for i in range(inhalt.size()):
		menge = menge + inhalt[i][1]
	return menge