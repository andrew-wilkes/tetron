extends CenterContainer

var grid
var next

var music = 0
var sound = 0

const CELL_BG1 = Color(.1, .1, .1)
const CELL_BG2 = Color(0)

signal button_pressed(button_name)

func _ready():
	grid = find_node("Grid")
	next = find_node("Next")
	add_cells(grid, 200)
	clear_cells(grid, CELL_BG1)
	clear_cells(next, CELL_BG2)


func add_cells(node, n):
	var num_cells = node.get_child_count()
	while num_cells < n:
		node.add_child(node.get_child(0).duplicate())
		num_cells += 1


func clear_cells(node, color):
	for cell in node.get_children():
		cell.modulate = color


func _on_About_button_down():
	$AboutBox.popup_centered()
	emit_signal("button_pressed", "About")


func _on_NewGame_button_down():
	emit_signal("button_pressed", "NewGame")


func _on_Pause_button_down():
	emit_signal("button_pressed", "Pause")


func set_button_state(button, state):
	find_node(button).set_disabled(state)


func set_button_text(button, text):
	find_node(button).set_text(text)


func _on_AboutBox_popup_hide():
	set_button_state("About", false)


func set_button_states(playing):
	set_button_state("NewGame", playing)
	set_button_state("About", playing)
	set_button_state("Pause", !playing)


func _on_Music_value_changed(value):
	music = value
	emit_signal("button_pressed", "Music")


func _on_Sound_value_changed(value):
	sound = value
	emit_signal("button_pressed", "Sound")
