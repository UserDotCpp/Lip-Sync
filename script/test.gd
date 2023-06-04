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
@export var blinking : bool

func _process(_delta):
	prev_hz = 0
	stored_frequency = []
	#the for goes tru all the frequency values inside this frame and it stores them inside stored_frequency
	for VU_INDEX in range(1,VU_COUNT+1): 
		hz = VU_INDEX * FREQ_MAX / VU_COUNT; 
		f = spectrum.get_magnitude_for_frequency_range(prev_hz,hz,1)

		current_f = f.length()* 600
		if f != Vector2(0,0):
			is_speaking = true
			stored_frequency.append(current_f)#snapped(current_f , 0.001))#frecuencia_pasada.append(current_f) #FULL DATA #stepify in godot 3, snapped godot 4
		prev_hz = hz

	if is_speaking:
		stored_frequency_lable.text = str(stored_frequency)
		aux = stored_frequency #taking this out may break all the code, dont know whyyyyyy
		aux.sort() #taking this out OLSO may break all the code, dont know whyyyyyy
		
		ordered_stored_frequency_lable.text = str(aux)
		#no se si son por el orden en el q aparecen en la frecuencia o cual es el mas grande entre los tres(dudo que sea lo ultimo) abria q googlear
		#root_note.text =str(aux[15])
		#format1.text = str(aux[14])
		#format2.text = str(aux[13])

		face_animations.play("open")
		if stored_frequency[15]>= semi_open_mouth_frequency_value:
			face_animations.play("semi_open")
		elif stored_frequency[15] <= mouth_closing_frequency_value:
			face_animations.play("close")
		is_speaking = false
	elif !blinking:
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
