package;

import Discord.DiscordClient;
import FreeplayDifficultySubstate.MaroStar;
import editors.ChartingState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
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
	public static var instance:FreeplayState;
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

	var hintObj:CaptionObject;

	var overCam:FlxCamera;

	var theFunnyyyyyyyyyyyy:Int = 0;

	var overspitrhwrwhjwak:FlxSprite;

	var epicOverTween:FlxTween;

	public var pleaseStop:Bool = false; 

	public var hasMustacheDeemed:Bool = false;

	override function create()
	{
		// Paths.clearStoredMemory();
		// Paths.clearUnusedMemory();
		Mhat.call("menu_freeplay");

		instance = this;

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

		FlxG.cameras.reset(new FlxCamera());
		overCam = new FlxCamera();
		overCam.bgColor.alpha = 0;
		FlxG.cameras.add(overCam, false);

		hintObj = new CaptionObject("bottom text", [overCam]);
		add(hintObj);

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

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			if (songs[i].songName.toLowerCase().replace(" ", "-") == "karrd-kollision")
				theFunnyyyyyyyyyyyy = i;
			var songIsUnlockedEmoji:Bool = CoolUtil.fredMode || (ClientPrefs.getKeyUnlocked(songs[i].unlockerKey)
				&& !FreeplayState.weekIsLocked(WeekData.weeksList[songs[i].week]));

			if (!songIsUnlockedEmoji && songs[i].hiddenFromStoryMode)
			{
				songs[i].loadedIn = false;
				continue;
			}

			var fixedsongname:String = CoolUtil.fredMode ? "karrd-kollision" : CoolUtil.shortenSongName(songs[i].songName.toLowerCase().replace(" ", "-"));
			var gwagwa = 'portraits/${songIsUnlockedEmoji ? fixedsongname : 'null'}';
			// trace(gwagwa);
			var portrait:FlxSprite = new FlxSprite().loadGraphic(Paths.image(gwagwa, 'shared'));
			add(portrait);
			portraits.push(portrait);
			portrait.y = (FlxG.height / 2) - (portrait.height / 2) - 75;
			portrait.x = (FlxG.width / 2 + (i * 600)) - (portrait.width / 2);

			portrait.antialiasing = ClientPrefs.globalAntialiasing;

			var sonnngNAmeee:String = songIsUnlockedEmoji ? songs[i].songName : '???';
			if (CoolUtil.fredMode)
				sonnngNAmeee = "Karrd Kollision";

			var songText:Alphabet = new Alphabet(0, portrait.y + portrait.height + 20, sonnngNAmeee, true, false);
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

			Paths.currentModDirectory = CoolUtil.fredMode ? '' : songs[i].folder;
			var icon:HealthIcon = new HealthIcon(CoolUtil.fredMode ? "uncle-fred" : songs[i].songCharacter);
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

		// soup soup soup
		// soup soup souuup soup soup su soup soup
		// soup soup soup
		// soup soup  SOUUUP soup soup soup su soup

		// su su soup su su soup
		// SOUUUUP soup soup su soup suuuu
		// soupsoupsoup soup su su soup soup su soup

		// soup soup soup
		this.subStateClosed.add(function(substate:FlxSubState) {
			trace('substate died lmao');

			if (!(substate is FreeplayDifficultySubstate))
				return;
			if (!pleaseStop)
			{
				trace('ok, let\'s go');
				var theSongEver:SongMetadata = songs[curIndex];

				if (theSongEver.songName.toLowerCase() == "square" && !theSongEver.flag0) {
					theSongEver.icon.visible = false;
					theSongEver.portrait.loadGraphic(Paths.image('portraits/square-goaway', 'shared'));
					theSongEver.flag0 = true;
				}
	
				if (epicOverTween != null)
					epicOverTween.cancel();
				if (overspitrhwrwhjwak != null)
					epicOverTween = FlxTween.tween(overspitrhwrwhjwak, {alpha: 0}, 0.5);
	
				FlxG.camera.flash(FlxColor.WHITE, 0.5, null, true);
	
				var intendedPortraitY:Float = (FlxG.height / 2) - (theSongEver.portrait.height / 2) - 75;
	
				FlxTween.tween(theSongEver.portrait, {y: intendedPortraitY}, 0.75, {ease: FlxEase.cubeInOut});
				FlxG.sound.music.fadeIn(0.175);
				FlxTween.tween(theSongEver.text, {y: intendedPortraitY + theSongEver.portrait.height + 20}, 0.75, {ease: FlxEase.cubeInOut, startDelay: 0.15});
				FlxTween.tween(theSongEver.icon, {y: intendedPortraitY + theSongEver.portrait.height + 75}, 0.75, {ease: FlxEase.cubeInOut, startDelay: 0.15});
				FlxTween.tween(theSongEver.portrait.scale, {x: 1, y: 1}, 1, {ease: FlxEase.cubeOut});
				FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {
					ease: FlxEase.cubeOut,
					#if FREEPLAY_SHADER_THING
					onUpdate: function(t:FlxTween)
					{
						if (zoomShader != null && zoomShader.zoomRadius != null && zoomShader.zoomRadius.value != null)
							zoomShader.zoomRadius.value[0] = 100 - t.percent;
					},
					#end
					onComplete: function(t:FlxTween)
					{
						FlxG.camera.setFilters([]);

						if (!hasMustacheDeemed)
							hasSelected = false;
						else {
							FlxG.sound.music.fadeOut(0.175, 0.25);
							FlxG.sound.play(Paths.sound("deemed")).onComplete = function() {
								var theSongEver:SongMetadata = songs[curIndex];
								FlxG.sound.music.fadeOut(0.175);
								FlxG.sound.play(Paths.sound('mario painting'), 1.35, false);
								FlxTween.tween(theSongEver.portrait, {y: FlxG.height / 2 - theSongEver.portrait.height / 2, "scale.x": 1.15, "scale.y": 1.15}, 0.75,
									{ease: FlxEase.cubeInOut});
								FlxTween.tween(theSongEver.text, {y: FlxG.height + 100}, 0.75, {ease: FlxEase.cubeInOut});
								FlxTween.tween(theSongEver.icon, {y: FlxG.height + 100}, 0.75, {ease: FlxEase.cubeInOut});
								FlxTween.tween(theSongEver.portrait.scale, {x: 2.25, y: 2.25}, 1, {ease: FlxEase.cubeIn});
								if (overspitrhwrwhjwak == null) {
									overspitrhwrwhjwak = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
									overspitrhwrwhjwak.alpha = 0;
									add(overspitrhwrwhjwak);
								}
								if (epicOverTween != null)
									epicOverTween.cancel();
								epicOverTween = FlxTween.tween(overspitrhwrwhjwak, {alpha: 1}, 0.85);
				
								FlxTween.tween(FlxG.camera, {zoom: 2.25}, 1, {
									ease: FlxEase.cubeIn,
									onComplete: function(t:FlxTween)
									{
										FlxG.camera.setFilters([]);
										PlayState.storyDifficulty = CoolUtil.difficulties.indexOf("Hard");
										var peopleOrderOurPatties:String = Highscore.formatSong("wario's-song", PlayState.storyDifficulty);
										PlayState.SONG = Song.loadFromJson(peopleOrderOurPatties, "wario's-song");
										LoadingState.loadAndSwitchState(new PlayState());
									}
								});
							};
						}
					}
				});
			}
		});
	}

	public function deleteCurSelection() {
		songs[curIndex].icon.visible = false;
		songs[curIndex].portrait.visible = false;
		songs[curIndex].text.visible = false;
		grpSongs.members.remove(songs[curIndex].text);
		iconArray.remove(songs[curIndex].icon);
		portraits.remove(songs[curIndex].portrait);
		songs.remove(songs[curIndex]);
		changeSelection();
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

		if (hasSelected)
			return;

		#if debug
		// lock func
		if (FlxG.keys.justPressed.R && FlxG.keys.pressed.SHIFT)
		{
			trace(songs[curIndex].songName + " " + songs[curIndex].unlockerKey);
			var wasunlocked = ClientPrefs.getKeyUnlocked(songs[curIndex].unlockerKey);
			ClientPrefs.setKeyUnlocked(songs[curIndex].unlockerKey, !wasunlocked);
			var saieahiwahiwfaih:String = songs[curIndex].songName.toLowerCase().replace(" ", "-");
			ClientPrefs.setKeyUnlocked(saieahiwahiwfaih + "-start", !wasunlocked);
			ClientPrefs.setKeyUnlocked(saieahiwahiwfaih + "-end", !wasunlocked);
			CoolUtil.loadSongDiffs(songs[curIndex].songName);
			@:privateAccess
			if (wasunlocked)
				for (i in 0...CoolUtil.difficulties.length)
					Highscore.setScore(Highscore.formatSong(songs[curIndex].songName, i), 0);
			FlxG.resetState();
			return;
		}
		#end

		if(FlxG.keys.justPressed.CONTROL)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
			return;
		}

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
			if (CoolUtil.fredMode)
				changeSelection(theFunnyyyyyyyyyyyy - curIndex);
			
			if (songs[curIndex].songName.toLowerCase() == "brrrrr")
				FlxG.sound.play(Paths.sound('brrrrr'), 1, false);
			else if (songs[curIndex].songName.toLowerCase() == "nether brrrrr")
				FlxG.sound.play(Paths.sound("brrrrrn't"), 1, false);
			else if (ClientPrefs.ls_enabled("nosong") && songs[curIndex].songName.toLowerCase() == "wario's song") {
				FlxG.sound.play(Paths.sound("spraybottle"), 1, false);
				deleteCurSelection();
				return;
			}

			if (songs[curIndex].flag0) {
				if (songs[curIndex].flag1 > 3)
					return;
				if (songs[curIndex].flag1 == 3) {
					deleteCurSelection();
					return;
				}
				songs[curIndex].flag1++;
				var newlevel:Float = ((FlxG.height / 2) - (songs[curIndex].portrait.height / 2) - 75) + (175 * songs[curIndex].flag1);
				FlxTween.tween(songs[curIndex].portrait, {y: newlevel}, 0.75, {ease: FlxEase.cubeInOut});
				FlxTween.tween(songs[curIndex].text, {y: newlevel + songs[curIndex].portrait.height + 20}, 0.75, {ease: FlxEase.cubeInOut});
				FlxTween.tween(songs[curIndex].icon, {y: newlevel + songs[curIndex].portrait.height + 75}, 0.75, {ease: FlxEase.cubeInOut});
			}
			else if (CoolUtil.fredMode || (ClientPrefs.getKeyUnlocked(songs[curIndex].unlockerKey)
				&& !FreeplayState.weekIsLocked(WeekData.weeksList[songs[curIndex].week])))
			{
				hasSelected = true;

				// soup soup soup
				trace(CoolUtil.difficulties);
				PlayState.storyDifficulty = CoolUtil.difficulties.indexOf('Hard');
				if (PlayState.storyDifficulty < 0)
					PlayState.storyDifficulty = 0;
				persistentUpdate = false;
				PlayState.isStoryMode = false;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if (colorTween != null)
					colorTween.cancel();

				//var goToChart:Bool = FlxG.keys.pressed.SHIFT;
				var theSongEver:SongMetadata = songs[curIndex];

				FlxG.sound.music.fadeOut(0.175);

				FlxG.sound.play(Paths.sound('mario painting'), 1.35, false);

				if (WeekData.weeksList[theSongEver.week] == CoolUtil.fredCrossoverWeekName)
					FlxG.sound.play(Paths.sound('fred'), 0.125, false);

				//FlxG.camera.fade(FlxColor.WHITE, 0.85, false, null, true);
				FlxTween.tween(theSongEver.portrait, {y: FlxG.height / 2 - theSongEver.portrait.height / 2, "scale.x": 1.15, "scale.y": 1.15}, 0.75,
					{ease: FlxEase.cubeInOut});
				FlxTween.tween(theSongEver.text, {y: FlxG.height + 100}, 0.75, {ease: FlxEase.cubeInOut});
				FlxTween.tween(theSongEver.icon, {y: FlxG.height + 100}, 0.75, {ease: FlxEase.cubeInOut});
				FlxTween.tween(theSongEver.portrait.scale, {x: 2.25, y: 2.25}, 1, {ease: FlxEase.cubeIn});

				if (overspitrhwrwhjwak == null) {
					overspitrhwrwhjwak = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
					overspitrhwrwhjwak.alpha = 0;
					add(overspitrhwrwhjwak);
				}

				if (epicOverTween != null)
					epicOverTween.cancel();
				epicOverTween = FlxTween.tween(overspitrhwrwhjwak, {alpha: 1}, 0.85);

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
						/*FlxG.camera.fade(FlxColor.BLACK, 0.15, false, function()
						{
							LoadingState.loadAndSwitchState(goToChart ? new ChartingState() : new PlayState());
						});*/

						openSubState(new FreeplayDifficultySubstate(songs[curIndex].songName));
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

	var curDifficulty:Int = 0;
	var colorTween:FlxTween;
	var intendedColor:FlxColor;

	var top27freds:Array<String> = ["fred", "redf", "fref", "fan", "fork", "freed", "frolic", "derf", "fdre", "ferd", "dref", 
									"': VS Uncle Fred", "abcdeFREDghjiklmnopqrstuvwxyz", "ferf", "phineas and ferb"];
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
		

		hintObj.text = CoolUtil.fredMode ? top27freds[FlxG.random.int(0, top27freds.length - 1)] : songs[curIndex].hint;
		hintObj.visible = CoolUtil.fredMode || (!ClientPrefs.getKeyUnlocked(songs[curIndex].unlockerKey) || FreeplayState.weekIsLocked(WeekData.weeksList[songs[curIndex].week]));

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
		bgalt.visible = songs[curIndex].songName.toLowerCase() == "normalized";
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, hideStory:Bool, unlockKey:String, hint:String)
	{
		var s = new SongMetadata(songName, weekNum, songCharacter, color, hideStory, unlockKey, hint);
		songs.push(s);
		return s;
	}

	public override function destroy() {
		if (overCam != null && FlxG.cameras.list.contains(overCam))
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

	public var flag0:Bool = false;
	public var flag1:Int = 0;

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
