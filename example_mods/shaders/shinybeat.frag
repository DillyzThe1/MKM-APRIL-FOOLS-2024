#pragma header

uniform float showing;

void main() {
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	
	float diff = (showing/8);
	color.x *= 1 + diff;
	color.y *= 1 + diff;
	color.z *= 1 + diff;
	
	vec4 color_bright = vec4(color.x, color.y, color.z, color.a);
	
	diff = abs(((openfl_TextureCoordv.x - 0.5) + (openfl_TextureCoordv.y - 0.5))/1.85);
	color_bright.x += diff;
	color_bright.y += diff;
	color_bright.z += diff;
	
	gl_FragColor = color * (1 - showing) + color_bright * showing;
}