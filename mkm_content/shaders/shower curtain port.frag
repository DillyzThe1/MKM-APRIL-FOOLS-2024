#pragma header

uniform float blockyness;

vec2 funnyPos(vec2 ogpos) {
	return vec2(floor(ogpos.x*100/blockyness)*blockyness/100, floor(ogpos.y*100/blockyness)*blockyness/100);
}

void main() {
	float smearing = 0.005;
	vec4 color = flixel_texture2D(bitmap, funnyPos(openfl_TextureCoordv));
	color /= 3;
	vec4 color2 = flixel_texture2D(bitmap, funnyPos(openfl_TextureCoordv) - vec2(smearing, 0));
	color2 /= 3;
	vec4 color3 = flixel_texture2D(bitmap, funnyPos(openfl_TextureCoordv) + vec2(smearing, 0));
	color3 /= 3;
	gl_FragColor = color + color2 + color3;
}