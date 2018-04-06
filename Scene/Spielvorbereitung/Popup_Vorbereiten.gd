# Author: Adrian Wagener
# Dient dem Zweck des Einlesens der Parameter Datei. 
# Wurde in Godot 2.0 (vor der Portierung) implementiert, aber wegen
# mangelnder Zeit nicht auf 3.0 portiert

extends AcceptDialog

# Counter zum Zaehlen der insgesamt hinzugefuegten Elemente
var counter = 0
var zeilenende
# Datei, aus der die Parameter ausgelesen werden sollen
var files = File.new()
# Grunddateipfad:
var file_path = "res://Vorratsschrank/"

func _ready():
	pass

# Funktion, die von den MenuButtons aufgerufen wird
func init_and_load(material, popup):
	pass

# Liest die Datei ein
func read_file(file, path, popup, material):
	pass

# Wird von den MenuButtons aufgerufen, wenn eines derer Items angeklickt wird
func item_pressed(ID, material, popup):
	pass