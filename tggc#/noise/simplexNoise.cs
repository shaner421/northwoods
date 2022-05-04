using Godot;
using System;

[Tool]

//this class creates our noise
public class simplexNoise : Node
{
	
	public static float[,] generateNoiseMap(int mapWidth,int mapHeight,float scale,int octaves,float persistence,float lacunarity){
		//here we are creating a new opensimplexnoise object
		OpenSimplexNoise noise = new OpenSimplexNoise();
		//here we are setting our parameters for the noise
		noise.Octaves = octaves;
		noise.Persistence = persistence;
		noise.Lacunarity = lacunarity;
		noise.Period = scale;
		
		//here we are creating our 2D array of noise values
		float[,] noiseMap = new float[mapWidth,mapHeight];
		
		//making sure the scale can never be zero
		if(scale<=0){
			scale = 0.0001f;
		}
		
		//generating our noisemap by getting a noise value for each point in our 2D array
		for(int y=0;y<mapHeight;y++){
			for(int x=0;x<mapWidth;x++){
				float val = noise.GetNoise2d(x,y);
				
				//making our noise look normal
				val *= 1.2f;
				val = (val + 1 )/2f;
				val = Mathf.Clamp(val,0f,1f);
				
				noiseMap[x,y] = val;
			}
		}
		
		return noiseMap;
	}
}
