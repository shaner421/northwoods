extends Node

var map_width:int = 10
var map_height:int = 10
var noise_scale:float = 0.0

func generate_map():
	var noise_map:Array = simplexnoise.generate_noise_map(map_width,map_height,noise_scale)
	
	
