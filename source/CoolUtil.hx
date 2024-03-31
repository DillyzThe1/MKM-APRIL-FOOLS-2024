package;

import StoryMenuState.StorySongData;
import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets as LimeAssets;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import options.MKMExtraSettingsSubState;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class CoolUtil
{
	public static var defaultDifficulties:Array<String> = ['Easy', 'Normal', 'Hard'];
	public static var hiddenDifficulties:Array<String> = [];
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

	public static function loadSongDiffs(song:String, ?difficultyToGet:String = "Hard", ?backupDifficulty:String = "Hard"):Int {
		trace(song + "'s diffs should be loaded into " + difficultyToGet + " mode (or fall back on " + backupDifficulty + " mode instead)");
		difficulties = getSongDiffs(song);

		if (difficulties.contains(difficultyToGet))
			return difficulties.indexOf(difficultyToGet);
		else if (difficulties.contains(backupDifficulty))
			return difficulties.indexOf(backupDifficulty);
		return 0;
	}

	public static function toMoney(amount:Float):String {
		var funnyThing:Int = Std.int(amount * 100) % 100;
		return '$$${Std.int(amount)}.${funnyThing < 10 ? "0" + funnyThing : "" + funnyThing}';
	}

	public static function getCrappyDifficulties(song:String):Array<String> {
		var formattedSong:String = song.toLowerCase().replace(" ", "-");
		var newDifficulties:Array<String> = [];
		var txtName:String = "data/" + formattedSong + "/crap.txt";
		if (Paths.fileExists(txtName, AssetType.TEXT, false, "preload")) {
			newDifficulties = Paths.getTextFromFile(txtName, false).trim().split("\n");
			for (i in 0...newDifficulties.length)
				newDifficulties[i] = newDifficulties[i].trim();
			trace(newDifficulties);
			return newDifficulties;
		}
		return newDifficulties;
	}

	public static function getSongDiffs(song:String):Array<String> {
		var formattedSong:String = song.toLowerCase().replace(" ", "-");

		var newDifficulties:Array<String> = [];

		for (i in 0...hiddenDifficulties.length)
			hiddenDifficulties.pop();

		var txtName:String = "data/" + formattedSong + "/hidden.txt";
		if (Paths.fileExists(txtName, AssetType.TEXT, false, "preload")) {
			hiddenDifficulties = Paths.getTextFromFile(txtName, false).trim().split("\n");
			for (i in 0...hiddenDifficulties.length)
				hiddenDifficulties[i] = hiddenDifficulties[i].trim();
			trace("HIDDEN - " + hiddenDifficulties);
		}

		if (formattedSong == "wrong-house" && ClientPrefs.ls_enabled("gtg-inator"))
			return ["Solo"];

		txtName = "data/" + formattedSong + "/difficulties.txt";
		if (Paths.fileExists(txtName, AssetType.TEXT, false, "preload")) {
			newDifficulties = Paths.getTextFromFile(txtName, false).trim().split("\n");
			for (i in 0...newDifficulties.length)
				newDifficulties[i] = newDifficulties[i].trim();
			trace(newDifficulties);
			return newDifficulties;
		}

		for (week in WeekData.weeksLoaded)
			for (songDATA in week.songs)
			{
				var top10Amazing:String = songDATA[0];
				if (top10Amazing.toLowerCase().replace(" ", "-") == formattedSong)
				{
					var diffStr:String = week.difficulties;
					if (diffStr != null) {
						diffStr = diffStr.trim();

						if (diffStr != "")
							newDifficulties = diffStr.replace(", ", ",").split(",");
						else
							break;
					}
					else 
						break;

					for (i in 0...newDifficulties.length)
						newDifficulties[i] = newDifficulties[i].trim();
					trace(newDifficulties);
					return newDifficulties;
				}
			}
		return defaultDifficulties.copy();
	}

	public static function tryGettingDifficulty(diff:String, ?fallbackDiff:String = "") {
		var endResult:Int = 0;
		for (i in 0...difficulties.length)
			if (difficulties[i].toLowerCase() == diff.toLowerCase())
				return i;
			else if (fallbackDiff != "" && difficulties[i].toLowerCase() == fallbackDiff.toLowerCase())
				endResult = i;
		return endResult;
	}
	
	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if (num == null)
			num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if (fileSuffix != defaultDifficulty)
			fileSuffix = '-' + fileSuffix;
		else
			fileSuffix = '';
		return Paths.formatToSongPath(fileSuffix);
	}
	
	public static function getDifficultyFilePathByName(nameeE:String)
	{
		var fileSuffix:String = nameeE;
		if (fileSuffix != defaultDifficulty)
			fileSuffix = '-' + fileSuffix;
		else
			fileSuffix = '';
		return Paths.formatToSongPath(fileSuffix);
	}

	@:privateAccess
	public static function songCompletedOnDiff(song:String, diff:String) {
		var daSong:String = Paths.formatToSongPath(song) + getDifficultyFilePathByName(diff);
		@:privateAccess
		if (!Highscore.songScores.exists(daSong))
			Highscore.setScore(daSong, 0);
		return Highscore.songScores.get(daSong) >= 10;
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
		if (fredMode)
			return;

		FlxG.save.data.babymode = active;
		TitleState.forceIntro = true;

		if (active)
			ClientPrefs.setKeyUnlocked("babymode", true);

		LoadingState.loadAndSwitchState(new TitleState(), false);
	}

	public static function babyMode():Bool
	{
		if (fredMode)
			return false;
		if (FlxG.save.data.babymode == null)
			return false;
		return FlxG.save.data.babymode;
	}

	public static function warningGot() {
		return ClientPrefs.getKeyUnlocked("bup-end");
	}

	public static function peaceRestored() {
		return ClientPrefs.getKeyUnlocked("square-vs-toad-end");
	}

	// i'm debating on making this bup-end & square-vs-toad-end or 0weekToad & 1weekToad-AF24
	public static function squareWarning():Bool {
		if (warningGot() && !peaceRestored())
			return true;
		return false;
	}

	public static function playMenuTheme(?volume:Float = 1, ?looped:Bool = true) {
		var menuThemeName:String = 'toadMenu';
		var babyMode:Bool = FlxG.save.data.babymode;

		if (peaceRestored() && babyMode) {
			menuThemeName = "Baby Menu Theme";
		}
		else if (peaceRestored()) {
			if (ClientPrefs.menuBgmType == "Feels at Home")
				trace('mkm if it used massive x');
			menuThemeName = ClientPrefs.menuBgmType;
		}
		else if (squareWarning())
			menuThemeName = babyMode ? 'Playtime Bup Ahead!' : 'Danger Bup Ahead!';
		else
			menuThemeName = babyMode ? "Baby Menu Theme (Forgotten)" : "MKM Menu Theme (Forgotten)";

		var songInfo:MenuSongInfo = MKMExtraSettingsSubState.menuThemes.get(MKMExtraSettingsSubState.menuThemes.exists(menuThemeName) ? menuThemeName : "MKM Menu Theme (Forgotten)");

		FlxG.sound.playMusic(Paths.music(songInfo.file, 'preload'), volume, looped);
		Conductor.changeBPM(songInfo.bpm);
		FlxG.sound.music.loopTime = songInfo.loopTime;
		trace('ok we gotta play the $menuThemeName at ${Conductor.bpm} BPM');
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
		if (fredMode)
		{
			curWeek = WeekData.weeksLoaded[fredCrossoverWeekName];
			diff = 0;
		}

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

			difficulties = curWeek.difficulties.replace(", ", ",").split(",");

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArrayStrs;
			PlayState.isStoryMode = true;

			var curDifficulty:Int = CoolUtil.loadSongDiffs(PlayState.storyPlaylist[0], CoolUtil.difficulties[diff]);
			if (curDifficulty < 0)
				curDifficulty = difficulties.length - 1;

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if (diffic == null)
				diffic = '';

			PlayState.storyDifficulty = curDifficulty;
			PlayState.originallyWantedDiffName = difficulties[curDifficulty];
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

	public static function loadFreeplaySong(weekName:String, songName:String, ?diff:String = "Hard", ?fallbackDiff:String = "Hard") {
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);
		trace(WeekData.weeksList);

		if (fredMode)
		{
			weekName = fredCrossoverWeekName;
			songName = "Karrd Kollision";
			diff = fallbackDiff = "Hard";
		}

		if (WeekData.weeksList.contains(weekName))
			PlayState.storyWeek = WeekData.weeksList.indexOf(weekName);
		
		trace(PlayState.storyWeek);
		var songLowercase:String = Paths.formatToSongPath(songName);
		// CoolUtil.difficulties = ['Hard'];

		if (songLowercase == "wrong-house" && ClientPrefs.ls_enabled("gtg-inator"))
			diff = "Solo";

		PlayState.storyDifficulty = CoolUtil.loadSongDiffs(songName, diff, fallbackDiff);
		var songDataStuff:String = Highscore.formatSong(songLowercase, PlayState.storyDifficulty);
		PlayState.SONG = Song.loadFromJson(songDataStuff, songLowercase);
		PlayState.isStoryMode = false;
		LoadingState.loadAndSwitchState(new PlayState());
		FlxG.sound.music.volume = 0;
		return true;
	}

	public static var fredMode:Bool = false;
	public static function shortenSongName(songInput:String) {
		var formattedSong:String = songInput.toLowerCase().replace(" ", "-");
		return switch(formattedSong) {
			case "top-10-great-amazing-super-duper-wonderful-outstanding-saster-level-music-that-ever-has-been-heard": "t10gasdwoslmtehbh";
			default: songInput;
		};
	}
}
