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

var gui
var state = STOPPED
var music_position = 0.0
var grid = []
var cols
var shape: ShapeData
var next_shape: ShapeData
var pos = 0
var count = 0

func _ready():
	gui = $GUI
	gui.connect("button_pressed", self, "_button_pressed")
	gui.set_button_states(ENABLED)
	cols = gui.grid.get_columns()
	gui.reset_stats()
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
			yield(get_tree().create_timer(3.0), "timeout")
			_game_over()
		
		"Pause":
			if state == PLAYING:
				gui.set_button_text("Pause", "Resume")
				state = PAUSED
				if _music_is_on():
					_music(PAUSE)
			else:
				gui.set_button_text("Pause", "Pause")
				state = PLAYING
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
	gui.set_button_states(ENABLED)
	if _music_is_on():
		_music(STOP)
	state = STOPPED
	print("Game stopped")


func add_to_score(rows):
	gui.lines += rows
	var score = 10 * int(pow(2, rows - 1))
	print("Added %d to score" % score)
	gui.score += score
	update_high_score()


func update_high_score():
	if gui.score > gui.high_score:
		gui.high_score = gui.score


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
