extends Node3D

@onready var spectrum = AudioServer.get_bus_effect_instance(1,0)
@onready var stored_frequency_lable = $"Camera/CanvasLayer/audio frequency/stored_frequency"
@export var face_animations_path : NodePath
@onready var face_animations = get_node(face_animations_path) #@onready var face_animations = $face
@export var blinking : bool = false
#@export var mouth_closing_frequency_value : float = 8
@export var semi_open_mouth_frequency_value : float = 14
@export var hold_x_frames : int = 3

var is_speaking = false

func _ready():
	if blinking:
		$blink_timer.start()
	$Camera/CanvasLayer/semi_open_value/scrolling_bar.value = semi_open_mouth_frequency_value
	$Camera/CanvasLayer/semi_open_value.text = str($Camera/CanvasLayer/semi_open_value/scrolling_bar.value)
	$Camera/CanvasLayer/hold_frames/frames_bar.value = hold_x_frames
	$Camera/CanvasLayer/hold_frames.text = str($Camera/CanvasLayer/hold_frames/frames_bar.value)

const VU_COUNT = 16
const HEIGHT = 600
const FREQ_MAX = 11050.0
var current_f = 0
var prev_hz
var hz 
var f
var stored_frequency
var counter_min = 0.09
var counter_max = semi_open_mouth_frequency_value# semi_open_mouth_frequency_value #old was 0 , 14 with the mew staff
var salio_de_hablar
var cicles = 1
var lowest_max = 100
var holdedframes = 0
var frame_holded = false
var current
var hold_the_frame = false

func _process(_delta):
	prev_hz = 0
	stored_frequency = []
	#the for goes tru all the frequency values inside this frame and it stores them inside stored_frequency
	for VU_INDEX in range(1,VU_COUNT+1): 
		hz = VU_INDEX * FREQ_MAX / VU_COUNT;
		f = spectrum.get_magnitude_for_frequency_range(prev_hz,hz,1)
		
		#stored_frequency.append(Vector2(current_f,VU_INDEX))
		current_f = f.length()* HEIGHT
		if f != Vector2(0,0):
			is_speaking = true
			salio_de_hablar = true
			stored_frequency.append(Vector2(snapped(current_f , 0.01),VU_INDEX))#snapped(current_f , 0.001))#frecuencia_pasada.append(current_f) #FULL DATA #stepify in godot 3, snapped godot 4
		else:
			stored_frequency.append(Vector2(current_f,VU_INDEX))
		prev_hz = hz

	if is_speaking:
		if holdedframes > 0:
			holdedframes -= 1
			hold_the_frame = true
			#is_speaking = false #otherwise ,the stored_frequency list goes out of bounds coss it resets every frame to store the 16 VUs
			#return#for some reason the crash keeps hapening so u need to fix this
		else:
			hold_the_frame = false
		#-----------
		stored_frequency_lable.text = str(stored_frequency)
		stored_frequency.sort()

		current = stored_frequency[15].x

		$"Camera/CanvasLayer/audio frequency/picos/root_note".text = str(snapped(current , 0.0001))

		if !hold_the_frame:
			face_animations.play("open")
			if  current >= counter_max/cicles:#semi_open_mouth_frequency_value:#stored_frequency[15].x>= semi_open_mouth_frequency_value:#stored_frequency[15].x>= semi_open_mouth_frequency_value: #semi_open_mouth_frequency_value = 14
				face_animations.play("semi_open")
			#the 57% of the semi open value means that the peak is ither decreasing or not up there yet, so this means thats closed <-> 57/100 * num = res
			elif current <= 0.57 * counter_max/cicles:#mouth_closing_frequency_value:#stored_frequency[15].x <= mouth_closing_frequency_value: #mouth_closing_frequency_value = 8
				face_animations.play("close")
			holdedframes = hold_x_frames
		is_speaking = false

		if current <= lowest_max and current >= 1:
			lowest_max = current
		counter_max = counter_max + current
		counter_min = counter_min + stored_frequency[0].x
		cicles = cicles + 1
	elif !blinking:
		if salio_de_hablar:
			if cicles > 3:
				$"Camera/CanvasLayer/audio frequency/picos/closed_mouth".text = str(snapped(0.57 * counter_max/cicles , 0.0001))
				$"Camera/CanvasLayer/audio frequency/picos/promedio_min".text = str(snapped(counter_min/cicles , 0.0001))
				$"Camera/CanvasLayer/audio frequency/picos/cicles".text = str(cicles)
				$"Camera/CanvasLayer/audio frequency/picos/promedio_max".text = str(snapped(counter_max/cicles , 0.0001))
			counter_min = 0
			counter_max = semi_open_mouth_frequency_value
			cicles = 1
			salio_de_hablar = false
		face_animations.play("close")

func _physics_process(_delta):
	# Add the gravity.
	if Input.is_action_just_pressed("e") and !is_speaking:
		$voice/"1".play()
	if Input.is_action_just_pressed("q") and !is_speaking:
		$voice/"2".play()

func _on_blink_timer_timeout():
	#turn the Autostart on if u want the model to blink || 
	if !is_speaking:
		blinking = true
		face_animations.play("blink")

func _on_scrolling_bar_scrolling():
	$Camera/CanvasLayer/semi_open_value.text = str($Camera/CanvasLayer/semi_open_value/scrolling_bar.value)
	semi_open_mouth_frequency_value = $Camera/CanvasLayer/semi_open_value/scrolling_bar.value

func _on_frames_bar_scrolling():
	$Camera/CanvasLayer/hold_frames.text = str($Camera/CanvasLayer/hold_frames/frames_bar.value)
	hold_x_frames = $Camera/CanvasLayer/hold_frames/frames_bar.value

var next_line_counter = 1

func _on_play_next_line_pressed():
	if !(get_node(str("voice/",next_line_counter)).playing):
		if next_line_counter <= 5:
			next_line_counter += 1
		else:
			next_line_counter = 1
		get_node(str("voice/",next_line_counter)).play()

func _on_blinking_on_off_toggled(button_pressed):
	if button_pressed:
		$blink_timer.start()
	else:
		$blink_timer.stop()
