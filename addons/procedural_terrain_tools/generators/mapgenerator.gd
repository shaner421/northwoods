extends Node
class_name mapgenerator



static func generate_map():
	var map_width:int = 100
	var map_height:int = 100
	var noise_scale:float = 0.2
	var noise_map = simplexnoise.generate_noise_map(map_width,map_height,noise_scale)
	return noise_map
	
	
