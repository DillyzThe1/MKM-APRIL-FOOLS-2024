#pragma header

uniform float elapsed;

void main() {
	float widescreen = 16.0 / 9.0;
	float screen = 4.0 / 3.0;
	float resx = ((openfl_TextureCoordv.x - ((widescreen - screen) / 4.0)) * widescreen) / screen;
	
	if (resx < 0.0 || resx > 1.0) {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
		return;
	}
	
	vec2 modifiedTex = vec2(resx, openfl_TextureCoordv.y);
	vec4 color = flixel_texture2D(bitmap, modifiedTex);
	float meidanColor = (color.r + color.g + color.b) / 3;
	vec4 bnw = vec4(meidanColor, meidanColor, meidanColor, color.a);
	gl_FragColor = bnw;
}