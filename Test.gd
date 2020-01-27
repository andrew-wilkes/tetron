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


func _input(event):
	if m:
		var new_pos = m.pos
		var dir = null
		if event.is_action_pressed("ui_down"):
			new_pos += m.cols
		if event.is_action_pressed("ui_left"):
			new_pos -= 1
		if event.is_action_pressed("ui_right"):
			new_pos += 1
		if event.is_action_pressed("ui_up"):
			new_pos -= m.cols
		if event.is_action_pressed("ui_page_down"):
			dir = m.LEFT
		if event.is_action_pressed("ui_page_up"):
			dir = m.RIGHT
		if new_pos != m.pos or dir != null:
			m.move_shape(new_pos, dir)
			get_tree().set_input_as_handled()
