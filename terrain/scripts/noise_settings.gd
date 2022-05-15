extends Node
class_name Noise_Settings

var noise:FastNoiseLite
var noise_raw:Array = [[]]
var noise_map:Array = [[]]
var chunk_size:int
var sub_size:int
var chunk_amount:int

func _init(n:FastNoiseLite,cs:int,ss:int,ca:int):
	noise = n
	chunk_size = cs
	sub_size = ss
	chunk_amount = ca

func generate_map()-> void:
	
	
	#this just calls a helper method that lets me define a size for my 2d array of floats
	noise_map = create_2darray(chunk_size*chunk_amount,  chunk_size*chunk_amount)
	#the meat of the generate function, it creates a 2d array of noise values for each vertex.y
	for x in chunk_size * chunk_amount:
		for y in chunk_size * chunk_amount:
			
			var val:float = noise.get_noise_2d(x,y)
			val *= 1.2
			val = (val + 1 )/2
			#val = clamp(val,0,1)
			#
			noise_map[x][y] = val
			
			


func get_length()-> int:
	return noise_map.size()

func get_noise(x:int,y:int)-> float:
	return noise_map[x][y]
	
func get_noise_br(x:int,y:int)-> float:
	return noise_map[x][y]

func get_noise_r(x:int,y:int)-> float:
	return noise_map[x][y]

func get_noise_image_texture(g:Gradient)-> ImageTexture:
	var imgt = ImageTexture.new()
	var color_map:PackedColorArray = []
	color_map.resize(noise_map.size()*noise_map.size())
	
	for x in noise_map.size():
		for y in noise_map.size():
			var val:Color = g.interpolate(get_noise(x,y))
			
			color_map[x+noise_map.size()*y]= val
	
	var byte_array:PackedByteArray = []
	byte_array.resize(noise_map.size()*noise_map.size()*3)
	for i in color_map.size():
		var c:Color = color_map[i]
		
		byte_array[3*i] = int(c.r8)
		byte_array[3*i+1] = int(c.g8)
		byte_array[3*i+2] = int(c.b8)
	
	var img:Image = Image.new()
	img.create_from_data(noise_map.size(),noise_map.size(),false,Image.FORMAT_RGB8,byte_array)
	imgt.create_from_image(img)
	
	return imgt

func get_noise_image_texture_from_colormap(g:Gradient,color_map:PackedColorArray)-> ImageTexture:
	var imgt = ImageTexture.new()

	var byte_array:PackedByteArray = []
	byte_array.resize(noise_map.size()*noise_map.size()*3)
	for i in color_map.size():
		var c:Color = color_map[i]
		
		byte_array[3*i] = int(c.r8)
		byte_array[3*i+1] = int(c.g8)
		byte_array[3*i+2] = int(c.b8)
	
	var img:Image = Image.new()
	img.create_from_data(noise_map.size(),noise_map.size(),false,Image.FORMAT_RGB8,byte_array)
	imgt.create_from_image(img)
	
	return imgt

func create_2darray(w, h) -> Array:
	var map:Array = []

	for x in range(w):
		var col:Array = []
		col.resize(h)
		map.append(col)

	return map
