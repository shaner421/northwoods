extends Node
class_name simplexnoise


const map_width:int = 0;
const map_height:int = 0;
const scale:float = 0.0;



static func generate_noise_map(map_width,map_height,scale) -> Array:
	
	var noise:FastNoiseLite = FastNoiseLite.new()
	noise.noise_type = 0
	var noise_map = []
	
	
	if(scale<=0):
		scale=0.0001;
	
	for x in range(map_width):
		noise_map.append([])
		for y in range(map_height):
			noise_map[x].append([])
			var sample_x:float = x / scale
			var sample_y:float = y / scale
			var value:float = noise.get_noise_2d(sample_x,sample_y)
			
			noise_map[x][y] = value
			
	return noise_map;
