extends Node2D

enum { STOPPED, PLAYING, PAUSED, STOP, PLAY, PAUSE }

const DISABLED = true
const ENABLED = false
const MIN_AUDIO_LEVEL = -24

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
				_music(PAUSE)
			else:
				gui.set_button_text("Pause", "Pause")
				state = PLAYING
				_music(PLAY)
		
		"Music":
			if state == PLAYING:
				if gui.music > MIN_AUDIO_LEVEL:
					print("Music changed. Level: %d" % gui.music)
					_music(PLAY)
				else:
					_music(STOP)
		
		"Sound":
			# copy gui.sound value to data
			if gui.sound > MIN_AUDIO_LEVEL:
				print("Sound changed. Level: %d" % gui.sound)
			else:
				print("Sound off")
		
		"About":
			gui.set_button_state("About", DISABLED)

func _start_game():
	print("Game playing")
	state = PLAYING
	music_position = 0.0
	_music(PLAY)

func _game_over():
	gui.set_button_states(ENABLED)
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
