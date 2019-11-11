extends PanelContainer

var grid
var next

const CELL_BG1 = Color(.1, .1, .1)
const CELL_BG2 = Color(0)

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
