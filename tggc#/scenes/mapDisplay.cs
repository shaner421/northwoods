using Godot;
using System;

[Tool]

//this class displays a 2D representation of our noise in either color or heightmap modes
public class mapDisplay : MeshInstance
{
	//here we are just setting up our exportable variables and allowing us to update the 
	//terrain if values are changed, given that auto update is turned on
	public int mapWidth = 100;
	
	[Export]
	public int _mapWidth {get {return mapWidth;}set {mapWidth = value; update();}}

	public int mapHeight = 100;
	
	[Export]
	public int _mapHeight {get {return mapHeight;}set {mapHeight = value; update();}}
	
	public int octaves = 4;
	
	[Export]
	public int _octaves {get {return octaves;}set {octaves = value; update();}}

	public float persistence = 0.5f;
	
	[Export(PropertyHint.Range, "0,10,0.01")]
	public float _persistence {get {return persistence;}set {persistence = value; update();}}

	public float lacunarity = 2f;
	
	[Export(PropertyHint.Range, "0,10,0.01")]
	public float _lacunarity {get {return lacunarity;}set {lacunarity = value; update();}}
	
	public float s = 100;
	
	[Export(PropertyHint.Range, "0,1000,10")]
	public float _s {get {return s;}set {s = value; update();}}
	
	[Export]
	public bool auto_update = false;
	
	public bool gen = false;
	
	[Export]
	public bool _gen {get {return gen;}set {gen = value; generate(gen);}}
	
	
	public bool use_color = false;
	
	[Export]
	public bool _use_color {get {return use_color;}set {use_color = value; update();}}
	
	[Export]
	public Gradient land_clr_gradient;
	
	[Export]
	public Curve landCurve;
	
	public MeshInstance terrain3d;
	
	public bool generateTerrain3d = false;
	
	[Export]
	public bool _generateTerrain3d {get {return generateTerrain3d;}set {generateTerrain3d = value; generateTerrain();}}
	
	//this updates the terrain if a value is changed when auto update is turned on
	void update(){
		if(auto_update){
			generateStuff();
		}
		
	}
	
	//this generates or wipes the terrain when we click the generate button
	void generate(bool val){

		if(val){
			generateStuff();
		}else{
			wipeStuff();
		}
	}
	
	void generateTerrain(){
		if(generateTerrain3d){
			terrain3d = meshGenerator.generateTerrainMesh(mapGenerator.generateMap(mapWidth,mapHeight,s,octaves,persistence,lacunarity),20000,landCurve,0);
			terrain3d.Scale = new Vector3(0.0079f,0.0079f,-0.0079f);
			AddChild(terrain3d);
			//generates a new material to be added to the plane
			SpatialMaterial mat = new SpatialMaterial();
		
			ImageTexture imgt = mapGenerator.generateTexture(mapGenerator.generateMap(mapWidth,mapHeight,s,octaves,persistence,lacunarity),mapWidth,mapHeight,use_color,landCurve,land_clr_gradient);
			mat.AlbedoTexture = imgt;
			mat.FlagsUnshaded = true;
		
			//sets the plane's material to our noise map/color map and scales it based on the map's size
			terrain3d.SetSurfaceMaterial(0,mat);
			//terrain3d.ScaleObjectLocal(new Vector3(mapWidth,1,mapHeight));
		}else{
			terrain3d.QueueFree();
		}
		
	}
	
	//this method wipes the terrain
	void wipeStuff(){
		SpatialMaterial mat = new SpatialMaterial();
		this.SetSurfaceMaterial(0,mat);
		this.Scale = new Vector3(2,1,2);
	}
	
	//this method uses the generate map class to generate the noise required for the terrain
	void generateStuff(){
		SpatialMaterial mat = new SpatialMaterial();
		this.SetSurfaceMaterial(0,mat);
		this.Scale = new Vector3(2,1,2);
		drawMap(mapGenerator.generateMap(mapWidth,mapHeight,s,octaves,persistence,lacunarity));
		GD.Print("generated");
	}
	
	//this is the bulk of the class; it takes in a 2D array of noise values and generates our
	//map from those in either color or heightmap modes, and allows us to change the color and
	//values depending on the color gradient and height curve variables
	void drawMap(float[,] noiseMap){
		
		//generates a new material to be added to the plane
		SpatialMaterial mat = new SpatialMaterial();
		
		ImageTexture imgt = mapGenerator.generateTexture(noiseMap,mapWidth,mapHeight,use_color,landCurve,land_clr_gradient);
		mat.AlbedoTexture = imgt;
		mat.FlagsUnshaded = true;
		
		//sets the plane's material to our noise map/color map and scales it based on the map's size
		this.SetSurfaceMaterial(0,mat);
		this.ScaleObjectLocal(new Vector3(mapWidth,1,mapHeight));
	}
}
