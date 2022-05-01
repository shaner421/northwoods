
extends MeshInstance3D

func draw_map(noise_map):
	var width:int = noise_map.size()
	var height:int = noise_map[0].size()
	var material:StandardMaterial3D = StandardMaterial3D.new()
	var img:Image = Image.new()
	img.create(width,height,false,4)
	
	
	var color_map = []
	color_map.resize(width * height*3)
	var black:Color = Color.BLACK
	for y in range(height):
		for x in range(width):
			img.set_pixel(x,y,black.lerp(Color.WHITE, noise_map[x][y]))
			
	
	var imgtexture:ImageTexture = ImageTexture.new()
	imgtexture.create_from_image(img)
	material.albedo_texture = imgtexture
	material.shading_mode = 0
	self.set_surface_override_material(0,material)
	
	self.scale_object_local(Vector3(width,1,height))

func _ready():
	draw_map(mapgenerator.generate_map())
	
