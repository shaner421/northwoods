@tool
extends Node

@export var noise:FastNoiseLite

@export var chunk_size = 64

@export var chunk_amount = 1

@export var amplitude:int = 10

var _generate:bool = false
#here we define our export variables
@export var generate:bool = false :
	get:
		return _generate
	set(_value):
		_generate = false
		generate_world()

var _clear:bool = false
#here we define our export variables
@export var clear:bool = false :
	get:
		return _clear
	set(_value):
		_clear = false
		clear_map()
		
var noise_settings:Noise_Settings
# Called when the node enters the scene tree for the first time.

	
func generate_world()->void:
	
	noise_settings = Noise_Settings.new(noise,chunk_size,chunk_size,chunk_amount)
	noise_settings.generate_map()
	add_chunk(noise_settings,0,0)
	add_chunk(noise_settings,0,1)
	add_chunk(noise_settings,1,0)
	add_chunk(noise_settings,1,1)
	
func add_chunk(noise_settings:Noise_Settings,x:int,z:int):
	var chunk:Chunk = Chunk.new(noise_settings,x,z,chunk_size,amplitude)
	add_child(chunk)
	chunk.owner = get_tree().edited_scene_root
	chunk.generate_mesh()

func clear_map()-> void:
	for i in range(get_child_count()):
		get_child(i).queue_free()


