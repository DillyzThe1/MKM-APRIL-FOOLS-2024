#pragma header

float calcDiff(float val) {
	float diff = val;
	if (diff > 0.5)
		diff = 0.5 - (diff - 0.5);
	diff = 0.5 - diff;
	diff *= 0.5;
	return diff;
}

uniform float curtime;

vec2 posEffect(vec2 curpos) {
	return vec2(curpos.x + cos(curtime + curpos.x*26)*0.0075, curpos.y + sin(curtime*2 + curpos.y*30)*0.0125);
}

void main() {
	vec2 curpos = openfl_TextureCoordv;

	vec4 color = flixel_texture2D(bitmap, posEffect(curpos));
	vec4 outputPixel = vec4(color.x, color.y, color.z, 1.0);
	
	float diff = max(calcDiff(curpos.x), calcDiff(curpos.y));
	
	outputPixel.x += diff*1.5;
	outputPixel.y -= diff*0.05;
	outputPixel.z += diff*0.05;
	
	outputPixel.x *= 0.9;
	outputPixel.y *= 0.5; 
	outputPixel.z *= 0.75; 
	
	
	// TESTING
	//outputPixel.x = diff*2;
	//outputPixel.y = outputPixel.z = 0; 
	//
	
	gl_FragColor = outputPixel * color.a;
}