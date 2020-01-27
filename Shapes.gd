extends GridContainer

var _shapes = []
var _index = 0

func get_shape() -> ShapeData:
	if _index == 0:
		_shapes.shuffle()
		_index = _shapes.size()
	_index -= 1
	var s = ShapeData.new()
	s.name = _shapes[_index].name
	s.color = _shapes[_index].color
	s.coors = _shapes[_index].coors
	s.grid = _shapes[_index].grid
	return s


func _ready():
	for shape in get_children():
		var data = ShapeData.new()
		data.name = shape.name
		data.color = shape.modulate
		
		var size = shape.columns
		var s2 = size / 2
		data.coors = range(-s2, s2 + 1)
		
		# Remove the zero coordinate for even-sized grids
		if size % 2 == 0:
			data.coors.remove(s2)
		#print(data.coors) # For testing purposes
		data.grid = _get_grid(size, shape.get_children())
		_shapes.append(data)


func _get_grid(n, cells):
	var grid = []
	var row = []
	var i = 0
	for cell in cells:
		row.append(cell.modulate.a > 0.1)
		i += 1
		if i == n:
			grid.append(row)
			i = 0
			row = []
	return grid
