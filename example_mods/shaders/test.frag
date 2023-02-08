#pragma header

void main() {
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	vec4 outputPixel = vec4(color.x, color.y, color.z, 1.0);
	
	outputPixel.x = 0;
	//outputPixel.y = floor((outputPixel.y*255) / 16)/255;
	outputPixel.z = 0; 
	
	gl_FragColor = outputPixel * color.a;
}