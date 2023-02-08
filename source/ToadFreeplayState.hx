package;

import Discord.DiscordClient;
import FreeplayState.SongMetadata;
import editors.ChartingState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

class ToadFreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	var bgalt:FlxSprite;
	var bg:FlxSprite;

	var portraits:Array<FlxSprite> = [];
	var grpSongs:FlxTypedGroup<Alphabet>;

	var iconArray:Array<HealthIcon> = [];

	var curIndex:Int = 0;

	var curIndexOffset:Int = 0;

	override function create()
	{
		// Paths.clearStoredMemory();
		// Paths.clearUnusedMemory();

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		bgalt = new FlxSprite().loadGraphic(Paths.image('menuDesat-Luigi'));
		bgalt.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgalt);
		bgalt.screenCenter();
		bgalt.visible = false;

		var songsToLoad:Int = 0;
		for (i in 0...WeekData.weeksList.length)
			for (o in 0...WeekData.weeksLoaded.get(WeekData.weeksList[i]).songs.length)
				songsToLoad++;
		var songIn:Int = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				songIn++;
				var colors:Array<Int> = song[2];
				if (colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), song.length >= 4 ? song[3] : false,
					song.length >= 5 ? song[4] : '${song[0].toLowerCase().replace(' ', '-')}-start');
			}
		}
		WeekData.loadTheFirstEnabledMod();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songIsUnlockedEmoji:Bool = ClientPrefs.getKeyUnlocked(songs[i].unlockerKey)
				&& !FreeplayState.weekIsLocked(WeekData.weeksList[songs[i].week]);

			if (!songIsUnlockedEmoji && songs[i].hiddenFromStoryMode)
			{
				songs[i].loadedIn = false;
				continue;
			}

			var fixedsongname:String = songs[i].songName.toLowerCase().replace(" ", "-");

			//trace(fixedsongname);

			if (fixedsongname == "top-10-great-amazing-super-duper-wonderful-outstanding-saster-level-music-that-ever-has-been-heard")
				fixedsongname = "t10gasdwoslmtehbh";

			var gwagwa = 'portraits/${songIsUnlockedEmoji ? fixedsongname : 'null'}';
			//trace(gwagwa);
			var portrait:FlxSprite = new FlxSprite().loadGraphic(Paths.image(gwagwa, 'shared'));
			add(portrait);
			portraits.push(portrait);
			portrait.y = (FlxG.height / 2) - (portrait.height / 2) - 75;
			portrait.x = (FlxG.width / 2 + (i * 600)) - (portrait.width / 2);

			portrait.antialiasing = ClientPrefs.globalAntialiasing;

			var songText:Alphabet = new Alphabet(0, portrait.y + portrait.height + 20, songIsUnlockedEmoji ? songs[i].songName : '???', true, false);
			grpSongs.add(songText);

			if (songText.width > 980)
			{
				var textScale:Float = 980 / songText.width;
				songText.scale.x = textScale;
				for (letter in songText.lettersArray)
				{
					letter.x *= textScale;
					letter.offset.x *= textScale;
				}
				// songText.updateHitbox();
				// trace(songs[i].songName + ' new scale: ' + textScale);
			}

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.y = portrait.y + portrait.height + 75;

			if (!songIsUnlockedEmoji)
				icon.color = FlxColor.BLACK;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);

			songs[i].portrait = portrait;
			songs[i].text = songText;
			songs[i].icon = icon;
		}
		WeekData.setDirectoryFromWeek();

		changeSelection(0, false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.inMenus();
		#end
	}

	override function update(e:Float)
	{
		super.update(e);

		if (controls.UI_LEFT_P)
			changeSelection(-1);
		else if (controls.UI_RIGHT_P)
			changeSelection(1);

		if (controls.BACK)
		{
			persistentUpdate = false;
			if (colorTween != null)
				colorTween.cancel();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			if (ClientPrefs.getKeyUnlocked(songs[curIndex].unlockerKey)
				&& !FreeplayState.weekIsLocked(WeekData.weeksList[songs[curIndex].week]))
			{
				trace(CoolUtil.difficulties);
				PlayState.storyDifficulty = CoolUtil.difficulties.indexOf('Hard');
				persistentUpdate = false;
				var songLowercase:String = Paths.formatToSongPath(songs[curIndex].songName);
				var peopleOrderOurPatties:String = Highscore.formatSong(songLowercase, PlayState.storyDifficulty);
				PlayState.SONG = Song.loadFromJson(peopleOrderOurPatties, songLowercase);
				PlayState.isStoryMode = false;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if (colorTween != null)
					colorTween.cancel();

				if (FlxG.keys.pressed.SHIFT)
					LoadingState.loadAndSwitchState(new ChartingState());
				else
					LoadingState.loadAndSwitchState(new PlayState());

				FlxG.sound.music.fadeOut(0.175);
			}
			else
			{
				FlxG.camera.shake(0.01, 0.15);
				FlxG.sound.play(Paths.sound('missnote${FlxG.random.int(1, 3)}', 'shared'));
			}
		}

		var posind:Int = 0;
		for (i in 0...songs.length)
		{
			if (!songs[i].loadedIn)
				continue;

			var lerpAmount:Float = e * 114 * (ClientPrefs.framerate/120);

			if (lerpAmount > 0.99)
				lerpAmount = 0.99;
			if (lerpAmount < 0.01)
				lerpAmount = 0.01;

			songs[i].portrait.x = FlxMath.lerp((FlxG.width / 2 + ((posind - curIndexOffset) * 600)) - (songs[i].portrait.width / 2), songs[i].portrait.x, lerpAmount);
			var a:Float = 0;
			for (o in 0...songs[i].text.lettersArray.length)
				a += songs[i].text.lettersArray[o].width * -0.5 * songs[i].text.textSize * songs[i].text.lettersArray[o].scale.x;
			songs[i].text.x = (songs[i].portrait.x + songs[i].portrait.width / 2) + a;
			songs[i].icon.x = (songs[i].portrait.x + songs[i].portrait.width / 2) - (songs[i].icon.width / 2);

			posind++;
		}
		bgalt.color = bg.color;
		bgalt.visible = songs[curIndexOffset].songName.toLowerCase() == "normalized";
	}

	function recalcOffset() {
		curIndexOffset = 0;

		for (i in 0...songs.length)
		{
			if (!songs[i].loadedIn || i >= curIndex)
				continue;
			curIndexOffset++;
		}
	}

	var intendedScore:Int = 0;
	var curDifficulty:Int = 0;
	var intendedRating:Float = 0;
	var colorTween:FlxTween;
	var intendedColor:FlxColor;
	var lastDifficultyName:String = "";

	function changeSelection(change:Int = 0, ?playSound:Bool = true)
	{
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curIndex += change;

		if (curIndex < 0)
			curIndex = songs.length - 1;
		if (curIndex >= songs.length)
			curIndex = 0;

		if (!songs[curIndex].loadedIn)
		{
			changeSelection(change, false);
			return;
		}

		recalcOffset();

		var newColor:Int = songs[curIndex].color;
		if (newColor != intendedColor)
		{
			if (colorTween != null)
				colorTween.cancel();
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}

		#if !switch
		intendedScore = Highscore.getScore(songs[curIndex].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curIndex].songName, curDifficulty);
		#end

		for (i in 0...iconArray.length)
		{
			portraits[i].alpha = iconArray[i].alpha = (curIndexOffset == i ? 1 : 0.6);
			grpSongs.members[i].alpha = (curIndexOffset == i ? 1 : 0.1);
		}

		Paths.currentModDirectory = songs[curIndex].folder;
		PlayState.storyWeek = songs[curIndex].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if (diffStr != null)
			diffStr = diffStr.trim(); // Fuck you HTML5

		if (diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if (diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if (diffs[i].length < 1)
						diffs.remove(diffs[i]);
				}
				--i;
			}

			if (diffs.length > 0 && diffs[0].length > 0)
				CoolUtil.difficulties = diffs;
		}

		/*if (CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
				curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
			else
				curDifficulty = 0;

			var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
				if (newPos > -1)
					curDifficulty = newPos;

				var ext:String = lastDifficultyName.toLowerCase().replace(' ', '-') == 'normal' ? '' : '-${lastDifficultyName.toLowerCase().replace(' ', '-')}';
				if (!Paths.fileExists('data/${songs[curIndex].songName.toLowerCase().replace(' ', '-')}/${songs[curIndex].songName.toLowerCase().replace(' ', '-')}${ext}.json',
					TEXT)) */

		curDifficulty = CoolUtil.difficulties.indexOf('Hard');
		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, hideStory:Bool, unlockKey:String)
	{
		var s = new SongMetadata(songName, weekNum, songCharacter, color, hideStory, unlockKey);
		songs.push(s);
		return s;
	}
}
