@tool
extends Node3D

class_name Chunk

@export var noise:FastNoiseLite

@export var chunk_size = 400

@export var g:Gradient = Gradient.new()

@export var amplitude:int = 10

var _generate:bool = false
#here we define our export variables
@export var generate:bool = false :
	get:
		return _generate
	set(_value):
		_generate = false
		generate_chunk()

var _clear:bool = false
#here we define our export variables
@export var clear:bool = false :
	get:
		return _clear
	set(_value):
		_clear = false
		clear_chunk()

var x:int = 0
var z:int = 0

var mesh

var mat = load("res://terrain/shaders/terrain.tres")


#func _init(noise:FastNoiseLite,x:int,z:int,chunk_size:int):
#	self.noise = noise
#	self.chunk_size = chunk_size
#	self.x = x
#	self.z = z


func generate_chunk() -> void:
	var sub_size = chunk_size

	var plane:PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(chunk_size,chunk_size)
	
	
	plane.subdivide_depth = sub_size
	plane.subdivide_width = sub_size
	var st:SurfaceTool = SurfaceTool.new()
	st.create_from(plane,0)
	
	var array_plane:ArrayMesh = st.commit()
	
	var dt:MeshDataTool = MeshDataTool.new()
	
	dt.create_from_surface(array_plane,0)
	
	var color_map = []
	color_map.resize(dt.get_vertex_count())
	
	var noise_settings:Noise_Settings = Noise_Settings.new(noise,chunk_size+2,sub_size,1)
	noise_settings.generate_map()
	
	
	for y in range(0,sqrt(dt.get_vertex_count())):
		for x in range(0,sqrt(dt.get_vertex_count())):
			var vertex:= dt.get_vertex(x+sqrt(dt.get_vertex_count())*y)
			var val = noise_settings.get_noise(x,y)
			
			vertex.y = val*amplitude
			var color:Color = g.interpolate(val)
			color_map[x+sqrt(dt.get_vertex_count())*y] = color
			dt.set_vertex(x+sqrt(dt.get_vertex_count())*y,vertex)
			dt.set_vertex_color(x+sqrt(dt.get_vertex_count())*y,g.interpolate(val))



	array_plane.clear_surfaces()
	dt.commit_to_surface(array_plane)
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.create_from(array_plane,0)
	st.generate_normals()
	st.generate_tangents()
	
	var meshi:MeshInstance3D = MeshInstance3D.new()
	
	meshi.mesh = st.commit()
	#meshi.material_override = mat
	meshi.position = Vector3(x * chunk_size,meshi.position.y,z* chunk_size)
	
	var m:StandardMaterial3D = StandardMaterial3D.new()
	#m.albedo_texture = noise_settings.get_noise_image_texture_from_colormap(g,color_map)
	m.vertex_color_use_as_albedo = true
	meshi.material_override = m
	
	add_child(meshi)
	meshi.owner = get_tree().edited_scene_root
	meshi.name = "chunk at "+ str(x)+", "+str(z)
	mesh = meshi
	
func clear_chunk()-> void:
	for i in range(get_child_count()):
		get_child(i).queue_free()
