extends TextureRect

var mouse_over = false

func _ready():
	connect("mouse_entered", self, "_mouse_over", [true])
	connect("mouse_exited",self,"_mouse_over", [false])
	
	
#	set_process_unhandled_input(true)
	set_process_input(true)


#func _unhandled_input(event):
#func _input(event):
#   # Mouse in viewport coordinates
#	if (mouse_over && event is InputEventMouseButton && event.is_pressed()):
#		if event.button_index == BUTTON_RIGHT:
#			print("TISCH Mouse Click/Unclick at: ", event.position)
#			get_tree().set_input_as_handled()

func _mouse_over(over):
	self.mouse_over = over