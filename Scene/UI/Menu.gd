# @author Adrian Wagener
# Kontroll Skript, welches die Animation vom Menu über einen Counter regelt

extends Button

var btn_pressed = 0

func _ready():
	set_process_input(true)

func _on_Menu_pressed():
	btn_pressed += 1
	
	if(btn_pressed%2 == 1):
		get_node("../..").get_node("AnimationPlayer").play("Animation_Menu_Flight_In")
	else:
		get_node("../..").get_node("AnimationPlayer").play("Animation_Menu_Flight_Out")
		
