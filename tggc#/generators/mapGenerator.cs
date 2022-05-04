using Godot;
using System;

[Tool]

//this class generated our noisemap from the noise class
public class mapGenerator : Node
{
	//this method generates a 2D array of noise values
	public static float[,] generateMap(int mapWidth, 
	int mapHeight, 
	float noiseScale,
	int octaves,
	float persistence,
	float lacunarity){
	float[,] noiseMap = simplexNoise.generateNoiseMap(mapWidth,mapHeight,noiseScale,octaves,persistence,lacunarity);
	
	return noiseMap;
	
	}
	
	//this method generates a texture based on our noise values and generates a color on a gradient if specified
	public static ImageTexture generateTexture(float[,] noiseMap,int mapWidth,int mapHeight,bool use_color, Curve landCurve,Gradient land_clr_gradient){
		//generates a 1D array of colors
		Color[] colorMap = new Color[mapWidth * mapHeight];
		for(int y=0;y<mapHeight;y++){
			for(int x=0;x<mapWidth;x++){
				//lerps between 0 and 1 giving us a value for our noise's color at a given point
				float origval = Mathf.Lerp(0f,1f,noiseMap[x,y]);
				float val = origval;
				
				//this allows us to modify the noise's value based on a curve
				if(landCurve != null){
					val = landCurve.InterpolateBaked(origval);
				}
				
				if(use_color && land_clr_gradient != null){
					//creates a color based on our color gradient
					colorMap[y*mapWidth+x] = land_clr_gradient.Interpolate(val);
				}else{
					//creates a color from our noise data
					colorMap[y*mapWidth+x] = new Color(val,val,val);
				}
				
			}
		}
		//this is a complicated thing but basically Image.CreateFromData requires us to give it a 
		//poolbyte array in order to not have to set each pixel, so we are creating a byte array for
		//our colors so all the points can be inputted at once. This is faster than setting each pixel
		//and locking the image.
		byte[] poolyshit = new byte[mapWidth * mapHeight * 3];
		for(int i=0;i<colorMap.Length;i++){
			Color c = colorMap[i];
			poolyshit[3*i] = (byte)c.r8;
			poolyshit[3*i+1] = (byte)c.g8;
			poolyshit[3*i+2] = (byte)c.b8;
		}
		
		//this creates our new image from our map's dimensions and our poolbytearray of colors
		Image img = new Image();
		img.CreateFromData(mapWidth,mapHeight,false,Image.Format.Rgb8,poolyshit);
		ImageTexture imgt = new ImageTexture();
		imgt.CreateFromImage(img);
		//this flags thing removes a wrapping issue that would normally cause the sides of the map to be weird
		imgt.Flags = 4;
		
		return imgt;
	}
	
}

