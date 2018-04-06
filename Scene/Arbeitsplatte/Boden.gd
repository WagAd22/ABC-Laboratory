extends TextureRect

var mouse_over = false

func _ready():
	connect("mouse_entered", self, "_mouse_over", [true])
	connect("mouse_exited",self,"_mouse_over", [false])


	set_process_input(true)



func _mouse_over(over):
	self.mouse_over = over