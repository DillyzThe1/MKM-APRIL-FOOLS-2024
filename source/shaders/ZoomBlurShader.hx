package shaders;

import flixel.system.FlxAssets.FlxShader;

class ZoomBlurShader extends FlxShader
{
	@:glFragmentSource('
    	#pragma header

		uniform float zoomRadius;
		
		vec2 modPos() {
			return vec2(openfl_TextureCoordv.x + (openfl_TextureCoordv.x - 0.5)*-zoomRadius, openfl_TextureCoordv.y + (openfl_TextureCoordv.y - 0.5)*-zoomRadius); 
		}

		vec2 lerpVecs(vec2 og, vec2 mod, float amount) {
			return og * amount + mod * (1.0 - amount);
		}

		void main() {
			float amount = abs(openfl_TextureCoordv.x - 0.5) * 0.25;
			gl_FragColor = (texture2D(bitmap, openfl_TextureCoordv) * amount) + (texture2D(bitmap, modPos()) * (1.0 - amount));
		}
	')
	public function new()
	{
		super();
	}
}
