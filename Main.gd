extends CenterContainer

enum { STOPPED, PLAYING, PAUSED, STOP, PLAY, PAUSE }
enum { ROTATE_LEFT, ROTATE_RIGHT }

const DISABLED = true
const ENABLED = false
const MAX_LEVEL = 100
const START_POS = 5
const END_POS =  25
const TICK_SPEED = 1.0
const FAST_MULTIPLE = 10
const WAIT_TIME = 0.15
const REPEAT_DELAY = 0.05
const FILE_NAME = "user://tetron.json"

var gui
var state = STOPPED
var music_position = 0.0
var grid = []
var cols
var shape: ShapeData
var next_shape: ShapeData
var pos = 0
var count = 0
var bonus = 0

func _ready():
	gui = $GUI
	gui.connect("button_pressed", self, "_button_pressed")
	gui.set_button_states(ENABLED)
	cols = gui.grid.get_columns()
	gui.reset_stats()
	load_game()
	randomize()


func clear_grid():
	grid.clear()
	grid.resize(gui.grid.get_child_count())
	for i in grid.size():
		grid[i] = false
	gui.clear_all_cells()


func move_shape(new_pos, dir = null):
	remove_shape_from_grid()
	# Rotate shape and store undo direction
	dir = rotate(dir)
	# If we can place the shape then update the position, else undo rotation
	var ok = place_shape(new_pos)
	if ok:
		pos = new_pos
	else:
		rotate(dir)
	add_shape_to_grid()
	return ok


# warning-ignore:unused_argument
func rotate(dir):
	match dir:
		ROTATE_LEFT:
			shape.rotate_left()
			dir = ROTATE_RIGHT
		ROTATE_RIGHT:
			shape.rotate_right()
			dir = ROTATE_LEFT
	return dir


func add_shape_to_grid():
	place_shape(pos, true, false, shape.color)


func remove_shape_from_grid():
	place_shape(pos, true)


func lock_shape_to_grid():
	place_shape(pos, false, true)


func place_shape(index, add_tiles = false, lock = false, color = Color(0)):
	var ok = true
	var size = shape.coors.size()
	var offset = shape.coors[0]
	var y = 0
	while y < size and ok:
		for x in size:
			if shape.grid[y][x]:
				var grid_pos = index + (y + offset) * cols + x + offset
				#print(grid_pos)
				if lock:
					grid[grid_pos] = true
				else:
					var gx = index % cols + x + offset
					if gx < 0 or gx >= cols or grid_pos >= grid.size() or grid_pos >= 0 and grid[grid_pos]:
						ok = !ok
						break
					if add_tiles and grid_pos >= 0:
						gui.grid.get_child(grid_pos).modulate = color
		y += 1
	return ok


func _button_pressed(button_name):
	match button_name:
		"NewGame":
			gui.set_button_states(DISABLED)
			_start_game()
		
		"Pause":
			if state == PLAYING:
				gui.set_button_text("Pause", "Resume")
				state = PAUSED
				pause() # Also, set pause mode of GUI to Process
				if _music_is_on():
					_music(PAUSE)
			else:
				gui.set_button_text("Pause", "Pause")
				state = PLAYING
				pause(false)
				if _music_is_on():
					_music(PLAY)
		
		"Music":
			# copy gui.music value to data
			if state == PLAYING:
				if _music_is_on():
					print("Music changed. Level: %d" % gui.music)
					_music(PLAY)
				else:
					_music(STOP)
		
		"Sound":
			# copy gui.sound value to data
			if _sound_is_on():
				$SoundPlayer.volume_db = gui.sound
				print("Sound changed. Level: %d" % gui.sound)
			else:
				print("Sound off")
		
		"About":
			gui.set_button_state("About", DISABLED)


func _start_game():
	print("Game playing")
	state = PLAYING
	music_position = 0.0
	if _music_is_on():
		_music(PLAY)
	clear_grid()
	gui.reset_stats(gui.high_score)
	new_shape()


func new_shape():
	if next_shape:
		shape = next_shape
	else:
		shape = Shapes.get_shape()
	next_shape = Shapes.get_shape()
	gui.set_next_shape(next_shape)
	pos = START_POS
	add_shape_to_grid()
	normal_drop()
	level_up()


func _input(event):
	if state == PLAYING:
		if event.is_action_pressed("ui_page_up"):
			increase_level()
		if event.is_action_pressed("ui_down"):
			bonus = 2
			soft_drop()
		if event.is_action_released("ui_down"):
			bonus = 0
			normal_drop()
		if event.is_action_pressed("ui_accept"):
			hard_drop()
		if event.is_action_pressed("ui_left"):
			move_left()
			$LeftTimer.start(WAIT_TIME)
		if event.is_action_released("ui_left"):
			$LeftTimer.stop()
		if event.is_action_pressed("ui_right"):
			move_right()
			$RightTimer.start(WAIT_TIME)
		if event.is_action_released("ui_right"):
			$RightTimer.stop()
		if event.is_action_pressed("ui_up"):
			if event.shift:
				move_shape(pos, ROTATE_RIGHT)
			else:
				move_shape(pos, ROTATE_LEFT)
		if event.is_action_pressed("ui_cancel"):
			_game_over()
		if event is InputEventKey:
			get_tree().set_input_as_handled()


func level_up():
	count += 1
	if count % 10 == 0:
		increase_level()


func increase_level():
	if gui.level < MAX_LEVEL:
		gui.level += 1
		$Ticker.set_wait_time(TICK_SPEED / gui.level)


func normal_drop():
	$Ticker.start(TICK_SPEED / gui.level)


func soft_drop():
	$Ticker.stop()
	$Ticker.start(TICK_SPEED / gui.level / FAST_MULTIPLE)


func hard_drop():
	$Ticker.stop()
	$Ticker.start(TICK_SPEED / MAX_LEVEL)


func _game_over():
	$Ticker.stop()
	$LeftTimer.stop()
	$RightTimer.stop()
	gui.set_button_states(ENABLED)
	if _music_is_on():
		_music(STOP)
	if _sound_is_on():
		$SoundPlayer.play()
	state = STOPPED
	print("Game stopped")
	save_game()


func add_to_score(rows):
	gui.lines += rows
	var score = 10 * int(pow(2, rows - 1))
	print("Added %d to score" % score)
	gui.score += score
	update_high_score()


func update_high_score():
	if gui.score > gui.high_score:
		gui.high_score = gui.score


func move_left():
	if pos % cols > 0:
		move_shape(pos - 1)


func move_right():
	if pos % cols < cols - 1:
		move_shape(pos + 1)


func _music(action):
	if action == PLAY:
		$MusicPlayer.volume_db = gui.music
		if !$MusicPlayer.is_playing():
			$MusicPlayer.play(music_position)
		print("Music changed")
	else:
		music_position = $MusicPlayer.get_playback_position()
		$MusicPlayer.stop()
		print("Music stopped")


func _music_is_on():
	return gui.music > gui.min_vol


func _sound_is_on():
	return gui.sound > gui.min_vol


func _on_Ticker_timeout():
	var new_pos = pos + cols
	if move_shape(new_pos):
		gui.score += bonus
		update_high_score()
	else:
		if new_pos <= END_POS:
			_game_over()
		else:
			lock_shape_to_grid()
			check_rows()
			new_shape()


func check_rows():
	var i = grid.size() - 1
	var x = 0
	var rows = 0
	while i >= 0:
		if grid[i]:
			x += 1
			i -= 1
			if x == cols: # complete row found
				rows += 1
				x = 0
		else:
			# empty cell found
			i += x # set i to right-most column
			x = 0
			if rows > 0:
				remove_rows(i, rows)
			rows = 0
			i -= cols # move i to next row


func remove_rows(i, rows):
		add_to_score(rows)
		print("Rows: %d" % rows)
		var num_cells = rows * cols
		# Hide cells
		for n in num_cells:
			gui.grid.get_child(i + n + 1).modulate = Color(0)
		pause()
		if _sound_is_on():
			$SoundPlayer.play()
		yield(get_tree().create_timer(0.3), "timeout")
		pause(false)
		remove_shape_from_grid()
		# Move cells
		var to = i + num_cells
		while i >= 0:
			grid[to] = grid[i]
			gui.grid.get_child(to).modulate = gui.grid.get_child(i).modulate
			if i == 0: # Clear the top row
				grid[i] = false
				gui.grid.get_child(i).modulate = Color(0)
			i -= 1
			to -= 1
		add_shape_to_grid()


func pause(value = true):
	get_tree().paused = value



func _on_LeftTimer_timeout():
	$LeftTimer.wait_time = REPEAT_DELAY
	move_left()


func _on_RightTimer_timeout():
	$RightTimer.wait_time = REPEAT_DELAY
	move_right()


func save_game():
	var data = {
		"music": gui.music,
		"sound": gui.sound,
		"high_score": gui.high_score
	}
	var file = File.new()
	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(data))
	file.close()


func load_game():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		print(data)
		gui.settings(data)