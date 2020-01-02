extends Node2D

enum { STOPPED, PLAYING, PAUSED, STOP, PLAY, PAUSE }

const DISABLED = true
const ENABLED = false

var gui
var state = STOPPED
var music_position = 0.0

func _ready():
	gui = $GUI
	gui.connect("button_pressed", self, "_button_pressed")
	gui.set_button_states(ENABLED)


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


func _game_over():
	gui.set_button_states(ENABLED)
	if _music_is_on():
		_music(STOP)
	state = STOPPED
	print("Game stopped")


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
