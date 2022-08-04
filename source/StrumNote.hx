package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StrumNote extends FlxSprite
{
	private var colorSwap:ColorSwap;

	public var resetAnim:Float = 0;

	private var noteData:Null<Int> = 0;

	public var direction:Float = 90; // plan on doing scroll directions soon -bb
	public var downScroll:Bool = false; // plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;

	private var player:Int;

	public var texture(default, set):String = null;

	private function set_texture(value:String):String
	{
		if (texture != value)
		{
			texture = value;
			reloadNote();
		}
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, player:Int)
	{
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);

		var skin:String = 'NOTE_assets';
		if (PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1)
			skin = PlayState.SONG.arrowSkin;
		texture = skin; // Load texture and anims

		scrollFactor.set();
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if (animation.curAnim != null)
			lastAnim = animation.curAnim.name;

		frames = Paths.getSparrowAtlas(texture);
		animation.addByPrefix('purple', 'arrowLEFT');
		animation.addByPrefix('down', 'arrowDOWN');
		animation.addByPrefix('up', 'arrowUP');
		animation.addByPrefix('right', 'arrowRIGHT');
		animation.addByPrefix('space', 'arrowSPACE');

		antialiasing = ClientPrefs.globalAntialiasing;
		// setGraphicSize(Std.int(width * Note.noteManiaSettings[PlayState.keyCount][2]));
		scale.x = scale.y = Note.noteScale;

		if (noteData == null || noteData >= Note.noteManiaSettings[PlayState.keyCount][5].length)
			noteData = 0;

		animation.addByPrefix('static', 'arrow${Note.noteManiaSettings[PlayState.keyCount][6][Std.int(Math.abs(noteData))].toUpperCase()}');
		animation.addByPrefix('pressed', '${Note.noteManiaSettings[PlayState.keyCount][5][Std.int(Math.abs(noteData))].toUpperCase()} press', 24, false);
		animation.addByPrefix('confirm', '${Note.noteManiaSettings[PlayState.keyCount][5][Std.int(Math.abs(noteData))].toUpperCase()} confirm', 24, false);

		updateHitbox();

		if (lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function postAddedToGroup(?pos:Int = -10)
	{
		if (pos == -10)
			pos = noteData;
		playAnim('static');
		if (pos != -1)
		{
			x += Note.swagWidth * pos;
			x += 50;
			x += ((FlxG.width / 2) * player);
			x += Note.noteOffset;
		}
		else
			x = -2000;
		ID = noteData;
	}

	override function update(elapsed:Float)
	{
		if (resetAnim > 0)
		{
			resetAnim -= elapsed;
			if (resetAnim <= 0)
			{
				playAnim('static');
				resetAnim = 0;
			}
		}
		// if(animation.curAnim != null){ //my bad i was upset
		if (animation.curAnim.name == 'confirm')
		{
			centerOrigin();
			// }
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false)
	{
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();
		if (animation.curAnim == null || animation.curAnim.name == 'static')
		{
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
		}
		else
		{
			colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;

			if (animation.curAnim.name == 'confirm')
			{
				centerOrigin();
			}
		}
	}
}
