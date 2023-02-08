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

float loopme(float valueee) {
	if (valueee > 1)
		return 1 - (valueee - 1);
	if (valueee < 0)
		return -valueee;
	return valueee;
}

vec2 posEffect(vec2 curpos) {
	return vec2(loopme(curpos.x + cos(curtime*3.5 + curpos.y*55)*0.001), loopme(curpos.y + sin(curtime*3.5 + curpos.x*55)*0.0035));
}

void main() {
	vec2 curpos = openfl_TextureCoordv;

	vec4 color = flixel_texture2D(bitmap, posEffect(curpos));
	vec4 outputPixel = vec4(color.x, color.y, color.z, 1.0);
	
	float diff = max(calcDiff(curpos.x), calcDiff(curpos.y));
	
	//diff *= (sin(curtime * 0.5)/8) + (1 - (1/8));
	
	outputPixel.x += diff*1.5;
	outputPixel.y -= diff*0.15;
	outputPixel.z += diff*0.05;
	
	outputPixel.x *= 0.9;
	outputPixel.y *= 0.5; 
	outputPixel.z *= 0.75; 
	
	// TESTING
	//outputPixel.x = diff*2;
	//outputPixel.y = outputPixel.z = 0; 
	//
	
	float funny = 0.1 + (sin(curtime*0.775) * 0.15);
	outputPixel.x *= 1 + funny;
	outputPixel.y *= 1 - funny*0.15; 
	outputPixel.z *= 1 + funny*0.225;
	
	outputPixel.x *= 0.9;
	outputPixel.y *= 0.8; 
	outputPixel.z *= 0.875; 
	
	gl_FragColor = outputPixel * color.a;
}