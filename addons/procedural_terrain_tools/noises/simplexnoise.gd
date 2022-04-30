extends Node
class_name simplexnoise


var map_width:int = 0;
var map_height:int = 0;
var scale:float = 0.0;



static func generate_noise_map(map_width,map_height,scale) -> Array:
	var noise:Noise = Noise.new()
	noise.noise_type = 0;
	var noise_map:Array =[]
	
	
	if(scale<=0):
		scale=0.0001;
	
	for x in range(map_width):
		noise_map[x]=[]
		for y in range(map_height):
			var sample_x:float = x / scale
			var sample_y:float = y / scale
			var value:float = noise.get_noise_2d(sample_x,sample_y)
			
			noise_map[x][y] = value
			
	return noise_map;
