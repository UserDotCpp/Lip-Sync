extends CanvasLayer

@export var voice_logic_path : NodePath
@onready var voice_logic = get_node(voice_logic_path)



# Called when the node enters the scene tree for the first time.
func _ready():
	$semi_open_value/scrolling_bar.value = voice_logic.semi_open_mouth_frequency_value
	$semi_open_value.text = str($semi_open_value/scrolling_bar.value)
	$hold_frames/frames_bar.value = voice_logic.hold_x_frames
	$hold_frames.text = str($hold_frames/frames_bar.value)
	$mic_audio_volum/mic_audio_volum_slider.value = voice_logic.get_node("mic").volume_db
	$mic_audio_volum/number.text = str(voice_logic.get_node("mic").volume_db)

func _on_scrolling_bar_scrolling():
	$semi_open_value.text = str($semi_open_value/scrolling_bar.value)
	voice_logic.semi_open_mouth_frequency_value = $semi_open_value/scrolling_bar.value

func _on_frames_bar_scrolling():
	$hold_frames.text = str($hold_frames/frames_bar.value)
	voice_logic.hold_x_frames = $hold_frames/frames_bar.value

var next_line_counter = 1

func _on_play_next_line_pressed():
	if !(voice_logic.get_node(str(next_line_counter)).playing):
		if next_line_counter <= 5:
			next_line_counter += 1
		else:
			next_line_counter = 1
		voice_logic.get_node(str(next_line_counter)).play()

func _on_blinking_on_off_toggled(button_pressed):
	if button_pressed:
		voice_logic.get_node("blink_timer").start()
	else:
		voice_logic.get_node("blink_timer").stop()

func _on_mic_toggled(button_pressed):
	if button_pressed:#microphone
		$AudioVisualizer.change_visualization(2)
		$play_next_line.disabled = true
		voice_logic.min_audio_value_allowed = float($min_audio_value_allowed/min_audio_text.text)
		voice_logic.get_node("mic").playing = true
		$min_audio_value_allowed/Button.disabled = false
		voice_logic.spectrum = AudioServer.get_bus_effect_instance(2,0)
	else:#pre recorded stuff
		$AudioVisualizer.change_visualization(1)
		$play_next_line.disabled = false
		$min_audio_value_allowed/Button.disabled = true
		voice_logic.spectrum = AudioServer.get_bus_effect_instance(1,0)
		voice_logic.get_node("mic").playing = false
		voice_logic.min_audio_value_allowed = 0

func _on_min_audio_value_allowed_button_pressed():
	voice_logic.min_audio_value_allowed = float($min_audio_value_allowed/min_audio_text.text)

func _on_mic_audio_volum_slider_drag_ended(value_changed):
	if value_changed:
		voice_logic.get_node("mic").volume_db = $mic_audio_volum/mic_audio_volum_slider.value
		$mic_audio_volum/number.text = str(voice_logic.get_node("mic").volume_db) 
