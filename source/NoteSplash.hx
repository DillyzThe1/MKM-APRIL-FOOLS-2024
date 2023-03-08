package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;

	private var idleAnim:String;
	private var textureLoaded:String = null;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0)
	{
		super(x, y);

		var skin:String = 'noteSplashes';
		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
			skin = PlayState.SONG.splashSkin;

		loadAnims(skin);

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public var prevNote:Int = 0;
	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0)
	{
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.6;

		if (texture == null)
		{
			texture = 'noteSplashes';
			if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
				texture = PlayState.SONG.splashSkin;
		}

		if (textureLoaded != texture)
		{
			loadAnims(texture);
		}
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		offset.set(10, 10);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play(${Note.noteManiaSettings[PlayState.ogCount][4][note].toLowerCase()} + '-' + animNum, true);
		scale.x = scale.y = Note.noteScale + 0.3;
		if (animation.curAnim != null)
			animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);

		prevNote = note;
	}

	function loadAnims(skin:String)
	{
		frames = Paths.getSparrowAtlas(skin);
		// ${Note.noteManiaSettings[PlayState.keyCount][4][i % PlayState.keyCount].toLowerCase()}
		for (i in 1...3)
		{
			animation.addByPrefix("purple-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("blue-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("green-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("red-" + i, "note splash red " + i, 24, false);
			animation.addByPrefix("white-" + i, "note splash white " + i, 24, false);
			animation.addByPrefix("yellow-" + i, "note splash yellow " + i, 24, false);
			animation.addByPrefix("magenta-" + i, "note splash magenta " + i, 24, false);
			animation.addByPrefix("rose-" + i, "note splash rose " + i, 24, false);
			animation.addByPrefix("lapis-" + i, "note splash lapis " + i, 24, false);
		}
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null)
			if (animation.curAnim.finished)
				kill();

		super.update(elapsed);
	}
}
