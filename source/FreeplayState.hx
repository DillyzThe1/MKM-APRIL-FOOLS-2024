package;

import Discord.DiscordClient;
import editors.ChartingState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.filters.ShaderFilter;
import shaders.ZoomBlurShader;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	var bgalt:FlxSprite;
	var bg:FlxSprite;

	var portraits:Array<FlxSprite> = [];
	var grpSongs:FlxTypedGroup<Alphabet>;

	var iconArray:Array<HealthIcon> = [];

	var curIndex:Int = 0;

	var curIndexOffset:Int = 0;

	var hasSelected:Bool = false;

	#if FREEPLAY_SHADER_THING
	var zoomShader:ZoomBlurShader;
	#end

	var hintBG:FlxSprite;
	var hintText:FlxText;

	var overCam:FlxCamera;

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

		overCam = new FlxCamera();
		overCam.bgColor.alpha = 0;
		FlxG.cameras.add(overCam, false);

		hintBG = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
		hintBG.cameras = [overCam];
		add(hintBG);
		
		hintText = new FlxText(FlxG.width/2, FlxG.height * 0.875, /*FlxG.width * 0.875*/ 0, "bottom text", 32, true);
		hintText.setBorderStyle(OUTLINE, FlxColor.BLACK, 4, 1.15);
		hintText.alignment = CENTER;
		hintText.cameras = hintBG.cameras;
		add(hintText);

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
				/*
					song[0] - song name
					song[1] - health icon
					song[2] - color array
					song[3] - hidden until unlocked (and from story mode)
					song[4] - unlocker key
					song[5] - unlock hint
				*/
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), song.length >= 4 ? song[3] : false,
					song.length >= 5 ? song[4] : '${song[0].toLowerCase().replace(' ', '-')}-start', song.length >= 6 ? song[5] : '');
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

			// trace(fixedsongname);

			// note to self: if a name is over 25 chars, just simplify it like this
			if (fixedsongname == "top-10-great-amazing-super-duper-wonderful-outstanding-saster-level-music-that-ever-has-been-heard")
				fixedsongname = "t10gasdwoslmtehbh";

			var gwagwa = 'portraits/${songIsUnlockedEmoji ? fixedsongname : 'null'}';
			// trace(gwagwa);
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

		// Updating Discord Rich Presence
		DiscordClient.inMenus();

		#if FREEPLAY_SHADER_THING
		zoomShader = new ZoomBlurShader();
		zoomShader.zoomRadius.value = [0];
		FlxG.camera.setFilters([new ShaderFilter(zoomShader)]);
		trace("booted up zoom shader");
		#end
	}

	override function update(e:Float)
	{
		super.update(e);

		var posind:Int = 0;
		for (i in 0...songs.length)
		{
			if (!songs[i].loadedIn)
				continue;

			var lerpAmount:Float = e * 114 * (ClientPrefs.framerate / 120);

			if (lerpAmount > 0.99)
				lerpAmount = 0.99;
			if (lerpAmount < 0.01)
				lerpAmount = 0.01;

			songs[i].portrait.x = FlxMath.lerp((FlxG.width / 2 + ((posind - curIndexOffset) * 600)) - (songs[i].portrait.width / 2), songs[i].portrait.x,
				lerpAmount);
			var a:Float = 0;
			for (o in 0...songs[i].text.lettersArray.length)
				a += songs[i].text.lettersArray[o].width * -0.5 * songs[i].text.textSize * songs[i].text.lettersArray[o].scale.x;
			songs[i].text.x = (songs[i].portrait.x + songs[i].portrait.width / 2) + a;
			songs[i].icon.x = (songs[i].portrait.x + songs[i].portrait.width / 2) - (songs[i].icon.width / 2);

			posind++;
		}
		bgalt.color = bg.color;
		bgalt.visible = songs[curIndexOffset].songName.toLowerCase() == "normalized";

		if (hasSelected)
			return;

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
				hasSelected = true;

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

				var goToChart:Bool = FlxG.keys.pressed.SHIFT;
				var theSongEver:SongMetadata = songs[curIndexOffset];

				FlxG.sound.music.fadeOut(0.175);

				FlxG.sound.play(Paths.sound('mario painting'), 1.35, false);

				if (WeekData.weeksList[theSongEver.week] == CoolUtil.fredCrossoverWeekName)
					FlxG.sound.play(Paths.sound('fred'), 0.125, false);

				FlxG.camera.fade(FlxColor.WHITE, 0.85, false, null, true);
				FlxTween.tween(theSongEver.portrait, {y: FlxG.height / 2 - theSongEver.portrait.height / 2, "scale.x": 1.15, "scale.y": 1.15}, 0.75,
					{ease: FlxEase.cubeInOut});
				FlxTween.tween(theSongEver.text, {y: FlxG.height + 100}, 0.75, {ease: FlxEase.cubeInOut});
				FlxTween.tween(theSongEver.icon, {y: FlxG.height + 100}, 0.75, {ease: FlxEase.cubeInOut});
				FlxTween.tween(theSongEver.portrait.scale, {x: 2.25, y: 2.25}, 1, {ease: FlxEase.cubeIn});
				FlxTween.tween(FlxG.camera, {zoom: 2.25}, 1, {
					ease: FlxEase.cubeIn,
					#if FREEPLAY_SHADER_THING
					onUpdate: function(t:FlxTween)
					{
						if (zoomShader != null && zoomShader.zoomRadius != null && zoomShader.zoomRadius.value != null)
							zoomShader.zoomRadius.value[0] = t.percent;
					},
					#end
					onComplete: function(t:FlxTween)
					{
						FlxG.camera.setFilters([]);
						add(new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE));
						FlxG.camera.fade(FlxColor.BLACK, 0.15, false, function()
						{
							LoadingState.loadAndSwitchState(goToChart ? new ChartingState() : new PlayState());
						});
					}
				});
			}
			else
			{
				FlxG.camera.shake(0.01, 0.15);
				FlxG.sound.play(Paths.sound('missnote${FlxG.random.int(1, 3)}', 'shared'));
			}
		}
	}

	public static function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	function recalcOffset()
	{
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
		#if !desktop
		var iconP3:FlxSprite = null;
		iconP3.makeGraphic(100, 100, FlxColor.WHITE);
		#end
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

		var boundsX:Float = 25;
		var boundsY:Float = 7.5;

		hintText.text = songs[curIndex].hint;
		hintText.screenCenter(X);

		hintText.y = (FlxG.height * 0.875) + 16;
		hintText.y -= hintText.height/2;

		if (hintText.y + hintText.height > FlxG.height)
			hintText.y = FlxG.height - hintText.height;

		// hintBG.setGraphicSize(Std.int(hintText.width + boundsX * 2), Std.int(hintText.height + boundsY * 2));
		hintBG.makeGraphic(Std.int(hintText.width + boundsX * 2), Std.int(hintText.height + boundsY * 2), FlxColor.BLACK);
		hintBG.setPosition(hintText.x - boundsX, hintText.y - boundsY);
		hintBG.alpha = 0.375;

		// round the texture's rectangle a bit for smoother looks
		if (hintBG.width >= 10 && hintBG.height >= 10 && hintBG.graphic != null && hintBG.graphic.bitmap != null)
		{
			var bmp:BitmapData = hintBG.graphic.bitmap;
			var bmpWidth:Int = bmp.width - 1;
			var bmpHeight:Int = bmp.height - 1;

			// top left corner
			bmp.setPixel32(0, 0, FlxColor.TRANSPARENT);
			bmp.setPixel32(0, 1, FlxColor.TRANSPARENT);
			bmp.setPixel32(1, 0, FlxColor.TRANSPARENT);
			//

			// top right corner
			bmp.setPixel32(bmpWidth, 0, FlxColor.TRANSPARENT);
			bmp.setPixel32(bmpWidth, 1, FlxColor.TRANSPARENT);
			bmp.setPixel32(bmpWidth - 1, 0, FlxColor.TRANSPARENT);
			//

			// bottom left corner
			bmp.setPixel32(0, bmpHeight, FlxColor.TRANSPARENT);
			bmp.setPixel32(0, bmpHeight - 1, FlxColor.TRANSPARENT);
			bmp.setPixel32(1, bmpHeight, FlxColor.TRANSPARENT);
			//

			// bottom right corner
			bmp.setPixel32(bmpWidth, bmpHeight, FlxColor.TRANSPARENT);
			bmp.setPixel32(bmpWidth, bmpHeight - 1, FlxColor.TRANSPARENT);
			bmp.setPixel32(bmpWidth - 1, bmpHeight, FlxColor.TRANSPARENT);
			//
		}

		intendedScore = Highscore.getScore(songs[curIndex].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curIndex].songName, curDifficulty);

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

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, hideStory:Bool, unlockKey:String, hint:String)
	{
		var s = new SongMetadata(songName, weekNum, songCharacter, color, hideStory, unlockKey, hint);
		songs.push(s);
		return s;
	}

	public override function destroy() {
		FlxG.cameras.remove(overCam);
		super.destroy();
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public var hiddenFromStoryMode:Bool = false;
	public var unlockerKey:String = '';
	public var hint:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int, hideFromStoryMode:Bool, unlockerKey:String, hint:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if (this.folder == null)
			this.folder = '';
		this.hiddenFromStoryMode = hideFromStoryMode;
		this.unlockerKey = unlockerKey;
		this.hint = hint;
	}

	public var portrait:FlxSprite;
	public var text:Alphabet;
	public var icon:HealthIcon;
	public var loadedIn:Bool = true;
}
