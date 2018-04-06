#Starmenü. Bei Knopfdruck werden Signals gesendet, die von Main empfangen werden

#@author Adrian Wagener

extends Control

signal scenario_select
signal game_start
signal game_prepare
signal tutorial
signal help
signal about
signal quit


func _ready():
	connect("scenario_select", get_node("Popup_Prepare"), "show_popup")

#Szenarioauswahl aktivieren
func _on_Spiel_starten_pressed():
	emit_signal("scenario_select")

#Szenarioauswahl beendet -> Spiel Starten
func _on_Popup_Prepare_game_start():
	emit_signal("game_start")

#Zeigt den Vorbereitungspopup fuer den Assistenten an.
func _on_Spiel_vorbereiten_pressed():
	emit_signal("game_prepare")

#Startet das Tutorial
func _on_Tutorial_pressed():
	emit_signal("tutorial")

#Zeigt den Hilfepopup an
func _on_Hilfe_pressed():
	emit_signal("help")

#Zeigt den Aboutpopup mit den Namen und der Lizenz an 
func _on_About_pressed():
	emit_signal("about")

#Verlaesst das Spiel OHNE Warnung
func _on_Spiel_beenden_pressed():
	emit_signal("quit")

