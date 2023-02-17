package;

#if desktop
import Discord.DiscordClient;
#end
import Achievements;
import editors.MasterEditorMenu;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

#if VIDEOS_ALLOWED
import vlc.MP4Handler;
#end

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.2'; // This is also used for Discord RPC
	public static var mushroomKingdomMadnessVersion:String = '1.5.0';
	public static var mkm_RELEASE_TRACKER:Int = 4;
	public static var curSelected:Int = 0;
	public static var selOnRight:Bool = false;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var menuItemsRight:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		// #if !switch 'donate', #end
		#if VIDEOS_ALLOWED 'album', #end
		'options'
	];

	var optionShitRight:Array<String> = ['normalized'];

	var bg:FlxSprite;
	var magenta:FlxSprite;

	var bgNormalized:FlxSprite;
	var magentaNormalized:FlxSprite;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.inMenus();
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		bgNormalized = new FlxSprite(-80).loadGraphic(Paths.image('menuBG-Luigi'));
		bgNormalized.scrollFactor.set(0, yScroll);
		bgNormalized.setGraphicSize(Std.int(bgNormalized.width * 1.175));
		bgNormalized.updateHitbox();
		bgNormalized.screenCenter();
		bgNormalized.alpha = 0;
		bgNormalized.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgNormalized);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);

		magentaNormalized = new FlxSprite(-80).loadGraphic(Paths.image('menuBGBlue-Luigi'));
		magentaNormalized.scrollFactor.set(0, yScroll);
		magentaNormalized.setGraphicSize(Std.int(magentaNormalized.width * 1.175));
		magentaNormalized.updateHitbox();
		magentaNormalized.screenCenter();
		magentaNormalized.visible = false;
		magentaNormalized.antialiasing = ClientPrefs.globalAntialiasing;
		add(magentaNormalized);

		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		menuItemsRight = new FlxTypedGroup<FlxSprite>();
		add(menuItemsRight);

		setOnRight(false);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			// menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			if (optionShit[i] == 'album')
			{
				menuItem.y -= 25;
			}
		}

		for (i in 0...optionShitRight.length)
		{
			var offset:Float = 108 - (Math.max(optionShitRight.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShitRight[i]);
			menuItem.animation.addByPrefix('idle', optionShitRight[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShitRight[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItemsRight.add(menuItem);
			var scr:Float = (optionShitRight.length - 4) * 0.135;
			if (optionShitRight.length < 6)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			// menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Mushroom Kingdom Madness v" + MainMenuState.mushroomKingdomMadnessVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
		{
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if (!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2]))
			{ // It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();

		beatenToadWeekONE = StoryMenuState.weekCompleted.get('0weekToad');
	}

	var beatenToadWeekONE:Bool = false;

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement()
	{
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (beatenToadWeekONE)
			{
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					setOnRight(true);
				}
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					setOnRight(false);
				}
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if ((selOnRight ? optionShitRight : optionShit)[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if (ClientPrefs.flashing)
						FlxFlicker.flicker(selOnRight ? magentaNormalized : magenta, 1.1, 0.15, false);

					(!selOnRight ? menuItemsRight : menuItems).forEach(function(spr:FlxSprite)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					});

					getCurMenuItems().forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = (selOnRight ? optionShitRight : optionShit)[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new ToadFreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
									#if VIDEOS_ALLOWED
									case 'album':
										var video:MP4Handler = new MP4Handler();
										video.playVideo(Paths.video('fnf fans'));
										video.finishCallback = function()
										{
											MusicBeatState.switchState(new MainMenuState());
											return;
										}
										DiscordClient.changePresence("In the Menus", "top 10 albums ever1!!");
									#end
									case 'normalized':
										PlayState.isStoryMode = false;
										WeekData.reloadWeekFiles(false);
										trace(WeekData.weeksList);

										if (!WeekData.weeksList.contains(CoolUtil.onePointFiveExtrasWeekName))
										{
											MusicBeatState.switchState(new MainMenuState());
											FlxG.sound.play(Paths.sound('cancelMenu'));
											return;
										}

										PlayState.storyWeek = WeekData.weeksList.indexOf(CoolUtil.onePointFiveExtrasWeekName);
										trace(PlayState.storyWeek);
										var songLowercase:String = Paths.formatToSongPath('Normalized');
										// CoolUtil.difficulties = ['Hard'];

										CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
										var diffStr:String = WeekData.getCurrentWeek().difficulties;
										if (diffStr != null)
											diffStr = diffStr.trim();

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

										if (CoolUtil.difficulties.contains('Hard'))
											PlayState.storyDifficulty = CoolUtil.difficulties.indexOf('Hard');
										else
											PlayState.storyDifficulty = 0;

										trace(CoolUtil.difficulties);
										trace(PlayState.storyDifficulty);

										var songDataStuff:String = Highscore.formatSong(songLowercase, PlayState.storyDifficulty);
										PlayState.SONG = Song.loadFromJson(songDataStuff, songLowercase);
										PlayState.isStoryMode = false;
										LoadingState.loadAndSwitchState(new PlayState());
										FlxG.sound.music.volume = 0;
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		var lerpVal = elapsed * 144 / 1.25;
		getCurMenuItems().forEach(function(spr:FlxSprite)
		{
			var newx = (FlxG.width - spr.width) / 2;
			spr.x = FlxMath.lerp(newx, spr.x, lerpVal);
		});

		(!selOnRight ? menuItemsRight : menuItems).forEach(function(spr:FlxSprite)
		{
			var distAmount = 1500;
			var newx = ((FlxG.width - spr.width) / 2) + (selOnRight ? -distAmount : distAmount);
			spr.x = FlxMath.lerp(newx, spr.x, lerpVal);
		});

		// bgNormalized.alpha = FlxMath.lerp(selOnRight ? 1 : 0, bgNormalized.alpha, elapsed * 144 * 2.5);
	}

	var oldTweenGarbage:FlxTween;

	public function getCurMenuItems()
	{
		return (selOnRight ? menuItemsRight : menuItems);
	}

	function setOnRight(isNowRight:Bool)
	{
		selOnRight = (isNowRight && ClientPrefs.getKeyUnlocked("house-start"));
		changeItem();

		if (oldTweenGarbage != null)
			oldTweenGarbage.cancel();
		oldTweenGarbage = FlxTween.tween(bgNormalized, {alpha: selOnRight ? 1 : 0}, 0.45, {ease: FlxEase.cubeInOut});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= getCurMenuItems().length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = getCurMenuItems().length - 1;

		getCurMenuItems().forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if (getCurMenuItems().length > 4)
				{
					add = getCurMenuItems().length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});

		(!selOnRight ? menuItemsRight : menuItems).forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();
		});
	}
}
