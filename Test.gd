extends Control

var shape: ShapeData

func _on_PickShape_button_down():
	shape = Shapes.get_shape()
	$Shape.text = shape.name
	_show_grid()


func _on_RotateLeft_button_down():
	shape.rotate_left()
	_show_grid()


func _on_RotateRight_button_down():
	shape.rotate_right()
	_show_grid()


func _show_grid():
	$Grid.text = ""
	for row in shape.grid:
		for col in row:
			if col:
				$Grid.text += "x "
			else:
				$Grid.text += "_ "
		$Grid.text += "\n"

var m

func _on_AddShapeToGrid_button_down():
	m = $Main
	m.clear_grid()
	m.shape = Shapes.get_shape()
	m.pos = int($SpinBox.value)
	m.add_shape_to_grid()


func _on_RemoveShapeFromGrid_button_down():
	m.remove_shape_from_grid()


func _on_Lock_button_down():
	m.lock_shape_to_grid()
