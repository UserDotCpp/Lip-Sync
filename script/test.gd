extends Node3D

@onready var spectrum = AudioServer.get_bus_effect_instance(1,0)
@onready var stored_frequency_lable = $"Camera/CanvasLayer/audio frequency/stored_frequency"
@onready var ordered_stored_frequency_lable = $"Camera/CanvasLayer/audio frequency/ordered_stored_frequency"
#@onready var root_note = $"Camera/CanvasLayer/audio frequency/picos/root_note"
#@onready var format1 = $"Camera/CanvasLayer/audio frequency/picos/format1"
#@onready var format2 = $"Camera/CanvasLayer/audio frequency/picos/format2"
@export var face_animations_path : NodePath
@onready var face_animations = get_node(face_animations_path) #@onready var face_animations = $face

@export var mouth_closing_frequency_value : float = 8
@export var semi_open_mouth_frequency_value : float = 14
@export var hold_x_frames : int = 3

const VU_COUNT = 16
const HEIGHT = 600
const FREQ_MAX = 11050.0
var current_f = 0
var prev_hz
var hz 
var f
var stored_frequency
var aux = [1,2]

var is_speaking = false
@export var blinking : bool = false

var counter_min = 0
var counter_max = 0
var salio_de_hablar
var cicles = 0
var lowest_max = 100
var holdedframes = 0
var frame_holded = false
var current

func _ready():
	if blinking:
		$blink_timer.start()
	#holdedframes = hold_x_frames

func _process(_delta):
	prev_hz = 0
	stored_frequency = []
	#the for goes tru all the frequency values inside this frame and it stores them inside stored_frequency
	for VU_INDEX in range(1,VU_COUNT+1): 
		hz = VU_INDEX * FREQ_MAX / VU_COUNT; 
		f = spectrum.get_magnitude_for_frequency_range(prev_hz,hz,1)

		current_f = f.length()* HEIGHT
		if f != Vector2(0,0):
			is_speaking = true
			salio_de_hablar = true
			stored_frequency.append(Vector2(snapped(current_f , 0.001),VU_INDEX))#snapped(current_f , 0.001))#frecuencia_pasada.append(current_f) #FULL DATA #stepify in godot 3, snapped godot 4
		prev_hz = hz

	if is_speaking:
		if holdedframes > 0:
			print("hold")
			holdedframes -= 1
			frame_holded = true
			is_speaking = false
			return
		#-----------

		stored_frequency_lable.text = str(stored_frequency)
		aux = stored_frequency
		aux.sort()
		
		ordered_stored_frequency_lable.text = str(aux)
		
		current = stored_frequency[15].x
		
		#no se si son por el orden en el q aparecen en la frecuencia o cual es el mas grande entre los tres(dudo que sea lo ultimo) abria q googlear
		#$"Camera/CanvasLayer/audio frequency/picos/root_note".text = str(stored_frequency[15].x)
		$"Camera/CanvasLayer/audio frequency/picos/format1".text = str(current_f)
		
		print("frame")
		if frame_holded:
			face_animations.play("open")
			if  current >= semi_open_mouth_frequency_value:#stored_frequency[15].x>= semi_open_mouth_frequency_value:#stored_frequency[15].x>= semi_open_mouth_frequency_value: #semi_open_mouth_frequency_value = 14
				face_animations.play("semi_open")
			elif current <= mouth_closing_frequency_value:#stored_frequency[15].x <= mouth_closing_frequency_value: #mouth_closing_frequency_value = 8
				face_animations.play("close")

		holdedframes = hold_x_frames
		is_speaking = false

		if stored_frequency[15].x <= lowest_max and stored_frequency[15].x >= 1:
			lowest_max= stored_frequency[15].x
		counter_max = counter_max + stored_frequency[15].x
		counter_min = counter_min + stored_frequency[0].x
		cicles = cicles + 1
	elif !blinking:
		if salio_de_hablar:
			print("el promedio max = ",counter_max , " y siclos ", cicles)
			print(counter_max/cicles)
			print("el promedio min = ",counter_min , " y siclos ", cicles)
			print(counter_min/cicles)
			print("lowest_max ", lowest_max)
			salio_de_hablar = false
		face_animations.play("close")

func _physics_process(_delta):
	# Add the gravity.
	if Input.is_action_just_pressed("e") and !is_speaking:
		$voice.play()
	if Input.is_action_just_pressed("q") and !is_speaking:
		$voice2.play()

func _on_blink_timer_timeout():
	#turn the Autostart on if u want the model to blink
	if !is_speaking:
		blinking = true
		face_animations.play("blink")
