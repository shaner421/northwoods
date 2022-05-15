@tool
extends Node3D

class_name Chunk


var g:Gradient = Gradient.new()
var chunk_size:int
var sub_size:int
var amplitude:int
var x:int = 0
var z:int = 0


var noise_settings:Noise_Settings

var vertices:PackedVector3Array = []
var normals:PackedVector3Array = []

func _init(noise_settings:Noise_Settings,x:int,z:int,chunk_size:int,amplitude:int):
	self.noise_settings = noise_settings
	self.chunk_size = chunk_size
	self.x = x
	self.z = z
	self.amplitude = amplitude
	
func generate_quad(x,y):
	
	var vert1 = Vector3(x,noise_settings.get_noise(x,y),-y)
	var vert2 = Vector3(x,noise_settings.get_noise(x,y+1),-y-1)
	var vert3 = Vector3(x+1,noise_settings.get_noise(x+1,y+1),-y-1)
	vertices.push_back(vert1)
	vertices.push_back(vert2)
	vertices.push_back(vert3)
	
	#second half of triangles
	
	vert1 = Vector3(x,noise_settings.get_noise(x,y),-y)
	vert2 = Vector3(x+1,noise_settings.get_noise(x+1,y+1),-y-1)
	vert3 = Vector3(x+1,noise_settings.get_noise(x+1,y),-y)
	
	vertices.push_back(vert1)
	vertices.push_back(vert2)
	vertices.push_back(vert3)
	

func generate_mesh() -> void:
	for x in chunk_size:
		for y in chunk_size:
			generate_quad(self.x*chunk_size+x,self.z*chunk_size+y)
			
	
	var st:SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var color_map:PackedColorArray = []
	color_map.resize(vertices.size())
	for i in vertices.size():
		var vertex = vertices[i]
		var val = vertex.y
		vertex.y = vertex.y*amplitude
		color_map[i] = g.interpolate(val)
		
		
		st.set_color(Color(val,val,val))
		#st.set_normal(normals[i])
		#st.set_smooth_group(true)
		st.add_vertex(vertex)
	var amesh:ArrayMesh = ArrayMesh.new()
	st.generate_normals()
	st.generate_tangents()
	st.commit(amesh)
	
	var m = StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.albedo_texture = noise_settings.get_noise_image_texture(g)
	var meshi = MeshInstance3D.new()
	meshi.material_override = m
	meshi.mesh = amesh
	
	
	add_child(meshi)

func clear_chunk()-> void:
	for i in range(get_child_count()):
		get_child(i).queue_free()

func create_2darray(w, h) -> Array:
	var map:Array = []

	for x in range(w):
		var col:Array = []
		col.resize(h)
		map.append(col)

	return map
