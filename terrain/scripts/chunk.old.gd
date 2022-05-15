
extends Node3D

class_name Chunkold



var g:Gradient = Gradient.new()
var chunk_size:int
var sub_size:int
var amplitude:int
var x:int = 0
var z:int = 0

var mesh
var noise_settings:Noise_Settings

func _init(noise_settings:Noise_Settings,x:int,z:int,chunk_size:int,amplitude:int):
	self.noise_settings = noise_settings
	self.chunk_size = chunk_size
	self.x = x
	self.z = z
	self.amplitude = amplitude
	


func generate_mesh() -> void:
	var meshsimplificationinc = 0
	var borderedsize = self.chunk_size
	var chunk_size = borderedsize-2
	var meshsize = borderedsize-2 * meshsimplificationinc
	var meshunsimplified = borderedsize-2
	
	var topleftx = (meshunsimplified-1)/-2
	var topleftz = (meshunsimplified-1)/2
	
	var verticesperline = (meshsize -1)/meshsimplificationinc +1
	
	var meshdata:MeshData = MeshData.new(verticesperline)
	
	var vertexindicesmap = create_2darray(borderedsize,borderedsize)
	var meshvertexindex = 0
	var bordervertexindex = -1
	
	for y in range(0,borderedsize):
		y+=meshsimplificationinc
		for x in range(0,borderedsize):
			x += meshsimplificationinc
			
			var isbordervertex = false
			if y==0 || y==borderedsize-1||x==0||x==borderedsize-1:
				isbordervertex = true
			
			if isbordervertex:
				vertexindicesmap[x][y] = bordervertexindex
				bordervertexindex = bordervertexindex-1
			else:
				vertexindicesmap[x][y] = meshvertexindex
				meshvertexindex = meshvertexindex+1
	
	for y in range(0,borderedsize):
		y+=meshsimplificationinc
		for x in range(0,borderedsize):
			x += meshsimplificationinc
			var vertexindex = vertexindicesmap[x][y]
			var percent:Vector2 = Vector2((x-meshsimplificationinc)/float(meshsize),(y-meshsimplificationinc)/float(meshsize))
			var height = noise_settings.get_noise(x,y)*amplitude
			
			var vertexposition:Vector3 = Vector3(topleftx + percent.x * meshunsimplified, height,topleftz - percent.y *meshunsimplified)
			meshdata.add_vertex(vertexposition,percent,vertexindex)
			if x<borderedsize-1 && y < borderedsize-1:
				var a = vertexindicesmap[x][y]
				var b = vertexindicesmap[x+meshsimplificationinc][y]
				var c = vertexindicesmap[x][y+meshsimplificationinc]
				var d = vertexindicesmap[x+meshsimplificationinc][y+meshsimplificationinc]
				meshdata.add_triangle(c,d,a)
				meshdata.add_triangle(b,a,d)
			vertexindex = vertexindex+1
	var amesh:ArrayMesh = meshdata.create_mesh()
	var meshi:MeshInstance3D = MeshInstance3D.new()
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

class MeshData:
	var vertices:Array[Vector3]
	var triangles:Array
	var uvs:Array[Vector2]
	
	var bordervertices:Array[Vector3]
	var bordertriangles:Array
	
	var triangleindex
	var bordertriangleindex
	
	func _init(verticesperline:int):
		vertices.resize(verticesperline*verticesperline)
		uvs.resize(verticesperline*verticesperline)
		triangles.resize((verticesperline-1*verticesperline-1)*6)
		
		bordervertices.resize(verticesperline * 4 + 4)
		bordertriangles.resize(24*verticesperline)
	
	func add_vertex(vertexposition:Vector3,uv:Vector2,vertexindex:int):
		if vertexindex<0:
			bordervertices[-vertexindex-1]=vertexposition
		else:
			vertices[vertexindex] = vertexposition
			uvs[vertexindex] = uv
	
	func add_triangle(a:int,b:int,c:int):
		if a<0||b<0||c<0:
			bordertriangles[bordertriangleindex] = a
			bordertriangles[bordertriangleindex+1] = b
			bordertriangles[bordertriangleindex+2] = c
			bordertriangleindex = bordertriangleindex+3
		else:
			triangles[triangleindex] = a
			triangles[triangleindex+1] =b
			triangles[triangleindex+2]=c
	
	func calculate_normals()->Array:
		var vertexnormals = []
		vertexnormals.resize(vertices.size())
		var trianglecount = triangles.size()/3
		
		for i in range(trianglecount):
			var normaltriangleindex = i*3
			var vertexindexa = triangles[normaltriangleindex]
			var vertexindexb = triangles[normaltriangleindex+1]
			var vertexindexc = triangles[normaltriangleindex+2]
			
			var trianglenormal:Vector3 = surface_normal_from_indices(vertexindexa,vertexindexb,vertexindexc)
			vertexnormals[vertexindexa] += trianglenormal
			vertexnormals[vertexindexb] += trianglenormal
			vertexnormals[vertexindexc] += trianglenormal
		
		var bordertrianglecount = bordertriangles.size()/3
		for i in range(bordertrianglecount):
			var normaltriangleindex = i*3
			var vertexindexa = triangles[normaltriangleindex]
			var vertexindexb = triangles[normaltriangleindex+1]
			var vertexindexc = triangles[normaltriangleindex+2]
			
			var trianglenormal:Vector3 = surface_normal_from_indices(vertexindexa,vertexindexb,vertexindexc)
			if vertexindexa>=0:
				vertexnormals[vertexindexa]+= trianglenormal
			if vertexindexb>=0:
				vertexnormals[vertexindexb]+= trianglenormal
			if vertexindexc>=0:
				vertexnormals[vertexindexc]+= trianglenormal
		
		for i in range(vertexnormals.size()):
			vertexnormals[i] = vertexnormals[i].normalized()
		
		return vertexnormals
	
	func surface_normal_from_indices(indexa:int,indexb:int,indexc:int)-> Vector3:
		var pointa:Vector3
		if indexa<0:
			pointa = bordervertices[-indexa -1]
		else:
			pointa = vertices[indexa]
		var pointb:Vector3
		if indexb<0:
			pointb = bordervertices[-indexb-1]
		else:
			pointb = vertices[indexb]
		var pointc:Vector3
		if indexc<0:
			pointc = bordervertices[-indexc-1]
		else:
			pointc = vertices[indexc]
		
		var sideab:Vector3 = pointb-pointa
		var sideac:Vector3 = pointc-pointa
		var abcrossac:Vector3 = sideac.cross(sideab)
		return abcrossac.normalized()

	func create_mesh()-> ArrayMesh:
		var amesh:ArrayMesh = ArrayMesh.new()
		var arrays:Array
		arrays.resize(9)
		arrays[int(ArrayMesh.ARRAY_VERTEX)] = vertices
		arrays[int(ArrayMesh.ARRAY_TEX_UV)] = uvs
		arrays[int(ArrayMesh.ARRAY_FORMAT_INDEX)] = triangles
		arrays[int(ArrayMesh.ARRAY_NORMAL)] = calculate_normals()
		
		amesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		return amesh
