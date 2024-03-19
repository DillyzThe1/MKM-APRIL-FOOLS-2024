package;

import editors.ChartingState;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

typedef EventNote =
{
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

class Note extends FlxSprite
{
	public static var oppositeMode:Bool = false;
	public var extraData:Map<String, Dynamic> = [];

	public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;
	public var nextNote:Note;

	public var spawned:Bool = false;

	public var tail:Array<Note> = []; // for sustains
	public var parent:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;

	public var animSuffix:String = '';
	public var gfNote:Bool = false;
	public var earlyHitMult:Float = 0.5;
	public var lateHitMult:Float = 1;
	public var lowPriority:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var noteScale:Float = 0.7;
	public static var pixelNoteScale:Float = 1;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var noStrumAnim:Bool = false;
	public var missPenalty:Bool = true;

	public var topTenEditorText:AttachedFlxText;

	public static var maniaKeyCounts:Array<Int> = [4, 6, 9, 5, 7, 8, 1, 2, 3];

	// intentionally kept the same as kade engine extra keys
	public static function maniaToKeyCount(manReal:Int)
	{
		if (manReal == -1)
			return 0;
		if (manReal < maniaKeyCounts.length)
			return maniaKeyCounts[manReal];
		return 0;
	}

	public static function keyCountToMania(keyReal:Int)
	{
		if (keyReal == 0)
			return -1;
		for (i in 0...maniaKeyCounts.length)
			if (maniaKeyCounts[i] == keyReal)
				return i;
		return 0;
	}

	public static var noteManiaSettings:Array<Array<Dynamic>> = [
		[
			// 0 key LMAO
			- 1,
			160 * 0.7, // swag width
			0.7, // scale
			1, // pixel scale
			[], // color names for notes
			[], // arrow letter names
			[], // arrow directions
			[], // keybinds
			0,
			[], // keyCountSwapBinds
			[-1, -1, -1, -1, -1, -1, -1, -1, -1]
		],
		[
			keyCountToMania(1),
			200 * 0.7, // swag width
			0.7, // scale
			1, // pixel scale
			['White'], // color names for notes
			['E'], // arrow letter names
			['Space'], // arrow directions
			['note_space_9k'], // keybinds
			175,
			['', '', '', '', 'note_space_9k', '', '', '', ''], // keyCountSwapBinds
			[-1, -1, -1, -1, 0, -1, -1, -1, -1]
		],
		[
			keyCountToMania(2),
			180 * 0.7, // swag width
			0.7, // scale
			1, // pixel scale
			['Purple', 'Red'], // color names for notes
			['A', 'D'], // arrow letter names
			['Left', 'Right'], // arrow directions
			['note_left', 'note_right'], // keybinds
			107,
			['note_left', '', '', 'note_right', '', '', '', '', ''], // keyCountSwapBinds
			[0, -1, -1, 1, -1, -1, -1, -1, -1]
		],
		[
			keyCountToMania(3),
			170 * 0.7, // swag width
			0.7, // scale
			1, // pixel scale
			['Purple', 'White', 'Red'], // color names for notes
			['A', 'E', 'D'], // arrow letter names
			['Left', 'Space', 'Right'], // arrow directions
			['note_left', 'note_space_9k', 'note_right'], // keybinds
			47,
			['note_left', '', '', 'note_right', 'note_space_9k', '', '', '', ''], // keyCountSwapBinds
			[0, -1, -1, 2, 1, -1, -1, -1, -1]
		],
		[
			keyCountToMania(4),
			160 * 0.7, // swag width
			0.7, // scale
			1, // pixel scale
			['Purple', 'Blue', 'Green', 'Red'], // color names for notes
			['A', 'B', 'C', 'D'], // arrow letter names
			['Left', 'Down', 'Up', 'Right'], // arrow directions
			['note_left', 'note_down', 'note_up', 'note_right'], // keybinds
			0,
			['note_left', 'note_down', 'note_up', 'note_right', '', '', '', '', ''], // keyCountSwapBinds
			[0, 1, 2, 3, -1, -1, -1, -1, -1]
		],
		[
			keyCountToMania(5),
			140 * 0.7, // swag width
			0.65, // scale
			0.9, // pixel scale
			['Purple', 'Blue', 'White', 'Green', 'Red'], // color names for notes
			['A', 'B', 'E', 'C', 'D'], // arrow letter names
			['Left', 'Down', 'Space', 'Up', 'Right'], // arrow directions
			['note_left', 'note_down', 'note_space_9k', 'note_up', 'note_right'], // keybinds
			- 16,
			[
				'note_left',
				'note_down',
				'note_up',
				'note_right',
				'note_space_9k',
				'',
				'',
				'',
				''
			], // keyCountSwapBinds
			[0, 1, 3, 4, 2, -1, -1, -1, -1]
		],
		[
			keyCountToMania(6),
			120 * 0.7, // swag width
			0.6, // scale
			0.83, // pixel scale
			['Purple', 'Green', 'Red', 'Yellow', 'Blue', 'Lapis'], // color names for notes
			['A', 'C', 'D', 'F', 'B', 'I'], // arrow letter names
			['Left', 'Up', 'Right', 'Left', 'Down', 'Right'], // arrow directions
			[
				'note_left_6k',
				'note_up_6k',
				'note_right_6k',
				'note_left2_6k',
				'note_down_6k',
				'note_right2_6k'
			], // keybinds
			- 32,
			[
				'note_left_6k',
				'note_down_6k',
				'note_up_6k',
				'note_right_6k',
				'',
				'note_left2_6k',
				'',
				'',
				'note_right2_6k'
			], // keyCountSwapBinds
			[0, 4, 1, 2, -1, 3, -1, -1, 5]
		],
		[
			keyCountToMania(7),
			110 * 0.7, // swag width
			0.575, // scale
			0.78, // pixel scale
			['Purple', 'Green', 'Red', 'White', 'Yellow', 'Blue', 'Lapis'], // color names for notes
			['A', 'C', 'D', 'E', 'F', 'B', 'I'], // arrow letter names
			['Left', 'Up', 'Right', 'Space', 'Left', 'Down', 'Right'], // arrow directions
			[
				'note_left_6k',
				'note_up_6k',
				'note_right_6k',
				'note_space_9k',
				'note_left2_6k',
				'note_down_6k',
				'note_right2_6k'
			], // keybinds
			- 49,
			[
				'note_left_6k',
				'note_down_6k',
				'note_up_6k',
				'note_right_6k',
				'note_space_9k',
				'note_left2_6k',
				'',
				'',
				'note_right2_6k'
			], // keyCountSwapBinds
			[0, 5, 1, 2, 3, 4, -1, -1, 6]
		],
		[
			keyCountToMania(8),
			100 * 0.7, // swag width
			0.55, // scale
			0.74, // pixel scale
			['Purple', 'Blue', 'Green', 'Red', 'Yellow', 'Magenta', 'Rose', 'Lapis'], // color names for notes
			['A', 'B', 'C', 'D', 'F', 'G', 'H', 'I'], // arrow letter names
			['Left', 'Down', 'Up', 'Right', 'Left', 'Down', 'Up', 'Right'], // arrow directions
			[
				'note_left_9k',
				'note_down_9k',
				'note_up_9k',
				'note_right_9k',
				'note_left2_9k',
				'note_down2_9k',
				'note_up2_9k',
				'note_right2_9k'
			], // keybinds
			- 66, // arrow directions
			[
				'note_left_9k',
				'note_down_9k',
				'note_up_9k',
				'note_right_9k',
				'',
				'note_left2_9k',
				'note_down2_9k',
				'note_up2_9k',
				'note_right2_9k'
			], // keyCountSwapBinds
			[0, 1, 2, 3, -1, 4, 5, 6, 7]
		],
		[
			keyCountToMania(9),
			95 * 0.7, // swag width
			0.5, // scale
			0.7, // pixel scale
			['Purple', 'Blue', 'Green', 'Red', 'White', 'Yellow', 'Magenta', 'Rose', 'Lapis'], // color names for notes
			['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'], // arrow letter names
			['Left', 'Down', 'Up', 'Right', 'Space', 'Left', 'Down', 'Up', 'Right',], // arrow directions
			[
				'note_left_9k',
				'note_down_9k',
				'note_up_9k',
				'note_right_9k',
				'note_space_9k',
				'note_left2_9k',
				'note_down2_9k',
				'note_up2_9k',
				'note_right2_9k'
			], // keybinds
			- 81, // arrow directions
			[
				'note_left_9k',
				'note_down_9k',
				'note_up_9k',
				'note_right_9k',
				'note_space_9k',
				'note_left2_9k',
				'note_down2_9k',
				'note_up2_9k',
				'note_right2_9k'
			], // keyCountSwapBinds
			[0, 1, 2, 3, 4, 5, 6, 7, 8]
		]
	];

	// Lua shit
	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;
	public var multSpeed(default, set):Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; // 9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick
	public var ratingDisabled:Bool = false;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var noMissAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000; // plan on doing scroll directions soon -bb

	public var hitsoundDisabled:Bool = false;

	private function set_multSpeed(value:Float):Float
	{
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		// trace('fuck cock');
		return value;
	}

	public function resizeByRatio(ratio:Float) // haha funny twitter shit
	{
		if (isSustainNote && !animation.curAnim.name.endsWith('end'))
		{
			scale.y *= ratio;
			updateHitbox();
		}
	}

	private function set_texture(value:String):String
	{
		if (texture != value)
		{
			reloadNote('', value);
		}
		texture = value;
		return value;
	}

	function shouldPress() {
		return (mustPress && !oppositeMode) || (!mustPress && oppositeMode);
	}

	private function set_noteType(value:String):String
	{
		noteSplashTexture = PlayState.SONG.splashSkin;
		colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
		colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
		colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;

		if (noteData > -1 && noteType != value)
		{
			switch (value)
			{
				case 'Hurt Note':
					ignoreNote = shouldPress();
					reloadNote('HURT');
					noteSplashTexture = 'HURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					lowPriority = true;

					if (isSustainNote)
					{
						missHealth = 0.1;
					}
					else
					{
						missHealth = 0.3;
					}
					hitCausesMiss = true;
				case 'Alt Animation':
					animSuffix = '-alt';
				case 'No Animation':
					noAnimation = true;
					noMissAnimation = true;
				case 'GF Sing':
					gfNote = true;
			}
			noteType = value;
		}
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		return value;
	}

	public static var noteOffset:Int;

	public static function reloadNoteStuffs()
	{
		var noteSettings:Array<Dynamic> = noteManiaSettings[PlayState.keyCount];
		swagWidth = noteSettings[1];
		noteScale = noteSettings[2];
		pixelNoteScale = noteSettings[3];
		noteOffset = noteSettings[8];
	}

	var funIsInfinite:Float = 0;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;

		x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if (!inEditor)
			this.strumTime += ClientPrefs.noteOffset;

		this.noteData = noteData;

		if (noteData > -1)
		{
			texture = '';
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			x += swagWidth * (noteData % PlayState.keyCount);
			if (!isSustainNote)
				animation.play('${noteManiaSettings[PlayState.keyCount][4][noteData % PlayState.keyCount].toLowerCase()}Scroll');
		}

		// trace(prevNote);

		if (prevNote != null)
			prevNote.nextNote = this;

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			multAlpha = 0.6;
			hitsoundDisabled = true;
			if (ClientPrefs.downScroll)
				flipY = true;

			offsetX += width / 2;
			copyAngle = false;

			animation.play('${noteManiaSettings[PlayState.keyCount][4][noteData % PlayState.keyCount].toLowerCase()}holdend');

			updateHitbox();

			offsetX -= width / 2;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play('${noteManiaSettings[PlayState.keyCount][4][noteData % PlayState.keyCount].toLowerCase()}hold');

				funIsInfinite = 1;
				funIsInfinite *= Conductor.stepCrochet / 100 * 1.05;
				if (PlayState.instance != null)
				{
					funIsInfinite *= PlayState.instance.songSpeed;
				}
				prevNote.updateHitbox();
				prevNote.scale.y *= funIsInfinite;
				// prevNote.setGraphicSize();
			}
		}
		else if (!isSustainNote)
		{
			earlyHitMult = 1;
		}
		x += offsetX;
	}

	var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
	var lastNoteScaleToo:Float = 1;

	public var originalHeightForCalcs:Float = 6;

	function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '')
	{
		if (prefix == null)
			prefix = '';
		if (texture == null)
			texture = '';
		if (suffix == null)
			suffix = '';

		var skin:String = texture;
		if (texture.length < 1)
		{
			skin = PlayState.SONG.arrowSkin;
			if (skin == null || skin.length < 1)
			{
				skin = 'NOTE_assets';
			}
		}

		var animName:String = null;
		if (animation.curAnim != null)
		{
			animName = animation.curAnim.name;
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length - 1] = prefix + arraySkin[arraySkin.length - 1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');

		frames = Paths.getSparrowAtlas(blahblah);
		loadNoteAnims();
		antialiasing = ClientPrefs.globalAntialiasing;
		if (isSustainNote)
		{
			scale.y = lastScaleY;
		}
		updateHitbox();

		if (animName != null)
			animation.play(animName, true);

		if (inEditor)
		{
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	function loadNoteAnims()
	{
		var letters:Array<Dynamic> = noteManiaSettings[noteManiaSettings.length - 1];

		for (i in 0...letters[4].length)
		{
			animation.addByPrefix('${letters[4][i].toLowerCase()}Scroll', '${letters[5][i].toUpperCase()}0');

			if (isSustainNote)
			{
				animation.addByPrefix('${letters[4][i].toLowerCase()}hold', '${letters[5][i].toUpperCase()} hold0');
				animation.addByPrefix('${letters[4][i].toLowerCase()}holdend', '${letters[5][i].toUpperCase()} tail0');
			}
		}

		// setGraphicSize(Std.int(width * noteScale));
		scale.x = scale.y = noteScale;
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (shouldPress())
		{
			// ok river
			if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult)
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
			{
				if ((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}

		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
