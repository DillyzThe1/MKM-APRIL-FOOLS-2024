package;

import StoryMenuState.StorySongData;
import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class CoolUtil
{
	public static var defaultDifficulties:Array<String> = ['Easy', 'Normal', 'Hard'];
	public static var defaultDifficulty:String = 'Normal'; // The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	public static var onePointFiveExtrasWeekName:String = "3the1point5extras";
	public static var babyModeWeekName:String = "4babymode";
	public static var fredCrossoverWeekName:String = "5fredCrossover";

	inline public static function quantize(f:Float, snap:Float)
	{
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		trace(snap);
		return (m / snap);
	}

	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if (num == null)
			num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if (fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function difficultyString():String
	{
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		if (FileSystem.exists(path))
			daList = File.getContent(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0)
				{
					if (countByColor.exists(colorOfThisPixel))
					{
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					}
					else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687))
					{
						countByColor[colorOfThisPixel] = 1;
					}
				}
			}
		}
		var maxCount = 0;
		var maxKey:Int = 0; // after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
		for (key in countByColor.keys())
		{
			if (countByColor[key] >= maxCount)
			{
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	// uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void
	{
		Paths.sound(sound, library);
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void
	{
		Paths.music(sound, library);
	}

	public static function browserLoad(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static function toggleBabyMode(active:Bool)
	{
		FlxG.save.data.babymode = active;
		TitleState.forceIntro = true;

		if (active)
			ClientPrefs.setKeyUnlocked("babymode", true);

		// FlxG.sound.playMusic(Paths.music('freakyMenu', 'preload'));
		// FlxG.sound.music.fadeIn(1.75, 0, 1);
		LoadingState.loadAndSwitchState(new TitleState(), false);
	}

	public static function babyMode():Bool
	{
		if (FlxG.save.data.babymode == null)
			return false;
		return FlxG.save.data.babymode;
	}

	public static function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	public static function loadWeek(curWeek:WeekData, ?diff:Int = -1, ?delay:Float = 0, ?force:Bool = false):Bool
	{
		if (force || !weekIsLocked(curWeek.fileName))
		{
			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArrayStrs:Array<String> = [];
			var leWeek:Array<Dynamic> = curWeek.songs;
			for (i in 0...leWeek.length)
			{
				var thisCatsName:StorySongData = {
					name: leWeek[i][0],
					hidden: leWeek[i].length > 3 ? leWeek[i][3] : false
				};
				songArrayStrs.push(thisCatsName.name);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArrayStrs;
			PlayState.isStoryMode = true;

			var curDifficulty:Int = diff;
			if (curDifficulty < 0)
				curDifficulty = difficulties.length - 1;

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if (diffic == null)
				diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;

			if (delay > 0)
			{
				new FlxTimer().start(delay, function(tmr:FlxTimer)
				{
					LoadingState.loadAndSwitchState(new PlayState(), true);
				});
				return true;
			}
			LoadingState.loadAndSwitchState(new PlayState(), true);
			return true;
		}
		return false;
	}
}
