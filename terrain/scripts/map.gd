@tool
extends MeshInstance3D

class_name Map

@export var noise:FastNoiseLite

@export var chunk_size = 400

@export var chunk_amount = 1

@export var amplitude:int = 10

@export var g:Gradient
var _generate:bool = false
#here we define our export variables
@export var generate:bool = false :
	get:
		return _generate
	set(_value):
		_generate = false
		generate_map()

var _clear:bool = false
#here we define our export variables
@export var clear:bool = false :
	get:
		return _clear
	set(_value):
		_clear = false

var x:int = 0
var z:int = 0

#var mat = load("res://terrain/shaders/terrain.tres")

#func _init(noise:FastNoiseLite,x:int,z:int,chunk_size:int):
#	self.noise = noise
#	self.chunk_size = chunk_size
##	self.x = x
#	self.z = z

func generate_map() -> void:
	var sub_size:int = chunk_size
	var p:PlaneMesh = PlaneMesh.new()
	p.size = (Vector2(chunk_size,chunk_size))
	p.subdivide_width = sub_size
	p.subdivide_depth = sub_size
	self.mesh = p
	var noise_settings:Noise_Settings = Noise_Settings.new(noise,chunk_size,sub_size,chunk_amount)
	noise_settings.generate_map()
	var m:StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_texture = noise_settings.get_noise_image_texture(g)
	
	self.material_override = m
	
	
	
	

