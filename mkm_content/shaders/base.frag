#pragma header

// default shader i wrote for you

void main() {
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	vec4 outputPixel = vec4(color.x, color.y, color.z, 1.0);
	
	// uncomment for a funny green shader
	//outputPixel.x = outputPixel.z = 0; outputPixel.y = floor((outputPixel.y*255) / 16)/255;

	gl_FragColor = outputPixel * color.a;
}