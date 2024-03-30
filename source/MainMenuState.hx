package;

import Achievements;
import Discord.DiscordClient;
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
import openfl.events.KeyboardEvent;

using StringTools;

#if VIDEOS_ALLOWED
import vlc.MP4Handler;
#end

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.2'; // This is also used for Discord RPC
	public static var mushroomKingdomMadnessVersion:String = '0.0.0-dev';
	public static var mkm_RELEASE_TRACKER:Int = 4;
	public static var curSelected:Int = 0;
	public static var selOnRight:Bool = false;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var menuItemsRight:FlxTypedGroup<FlxSprite>;
	public static var camGame:FlxCamera;
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

	var typingDisplay:CaptionObject;

	override function create()
	{
		Paths.pushGlobalMods();
		Mhat.call("menu_main");

		// Updating Discord Rich Presence
		DiscordClient.inMenus();
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		if (CoolUtil.squareWarning()) {
			optionShit = ['story_mode', 'credits', 'options'];
		}

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		bg = new FlxSprite(-80).loadGraphic(Paths.image(CoolUtil.squareWarning() ? 'menuDoom' : 'menuBG'));
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

		if (CoolUtil.squareWarning()) {
			magenta.color = FlxColor.BLACK;
			magenta.visible = true;
			magenta.alpha = 0;
			FlxTween.tween(magenta, {alpha: 0.65}, 7.25, {ease: FlxEase.cubeInOut, type: PINGPONG, loopDelay: 0.15});
		}

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
		if (!CoolUtil.squareWarning())
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
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, " Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "  ' v0.2.8", 12);
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

		beatenToadWeekONE = CoolUtil.warningGot() && !CoolUtil.squareWarning();
		// allow typing secrets
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, checkKeyDown);

		typingDisplay = new CaptionObject();
		add(typingDisplay);
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
	var skipNext:Bool = false;
	var freeplaysDied:Array<Int> = [];

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (skipNext) {
			skipNext = false;
			return;
		}

		var strictInput:Bool = typingBuffer.length > 0;

		if (FlxG.keys.justPressed.ANY) {
			trace("we " + (strictInput ? "strict" : "not strict") + " bc " + typingBuffer + " is " + typingBuffer.length + " chars long");
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P && (FlxG.keys.justPressed.UP || !strictInput))
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P && (FlxG.keys.justPressed.DOWN || !strictInput))
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (beatenToadWeekONE)
			{
				if (controls.UI_RIGHT_P && (FlxG.keys.justPressed.RIGHT || !strictInput))
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					setOnRight(true);
				}
				if (controls.UI_LEFT_P && (FlxG.keys.justPressed.LEFT || !strictInput))
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					setOnRight(false);
				}
			}

			if (controls.BACK && (FlxG.keys.justPressed.ESCAPE || !strictInput))
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT && (FlxG.keys.justPressed.ENTER || !strictInput) && !freeplaysDied.contains(curSelected))
			{
				if ((CoolUtil.peaceRestored() && FlxG.keys.pressed.SHIFT) ||  (!CoolUtil.peaceRestored() && (selOnRight ? optionShitRight : optionShit)[curSelected] == 'freeplay'))
				{
					if (!selOnRight && !freeplaysDied.contains(curSelected)) {
						freeplaysDied.push(curSelected);
						getCurMenuItems().forEach(function(spr:FlxSprite)
						{
							if (curSelected == spr.ID)
							{
								var awesomeY:Float = spr.y;
								FlxTween.tween(spr, {y: FlxG.height + 150}, 0.2, {
									ease: FlxEase.cubeIn,
									onComplete: function(twn:FlxTween)
									{
										spr.y = awesomeY;
										spr.kill();
										FlxG.sound.play(Paths.sound("house/divorce in a "));
										FlxG.camera.shake(0.1, 1);
									}
								});
							}
						});
					}
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if (CoolUtil.squareWarning())
						FlxTween.tween(bg, {alpha: 0}, 1.1, {ease: FlxEase.cubeInOut});
					else if (ClientPrefs.flashing)
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
										MusicBeatState.switchState(new FreeplayState());
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
									#if VIDEOS_ALLOWED
									case 'album':
										var video:MP4Handler = new MP4Handler();
										video.playVideo(Paths.video('fans'));
										video.finishCallback = function()
										{
											MusicBeatState.switchState(new MainMenuState());
											return;
										}
										DiscordClient.changePresence("In the Menus", "top 10 albums ever1!!");
									#end
									case 'normalized':
										if (!CoolUtil.loadFreeplaySong(CoolUtil.onePointFiveExtrasWeekName, "Normalized")) {
											MusicBeatState.switchState(new MainMenuState());
											FlxG.sound.play(Paths.sound('cancelMenu'));
										}
								}
							});
						}
					});
				}
			}
			else if (FlxG.keys.anyJustPressed(debugKeys) && !strictInput)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
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
		#if !desktop
		var iconP3:FlxSprite = null;
		iconP3.makeGraphic(100, 100, FlxColor.WHITE);
		#end
		// bgNormalized.alpha = FlxMath.lerp(selOnRight ? 1 : 0, bgNormalized.alpha, elapsed * 144 * 2.5);
	}

	var oldTweenGarbage:FlxTween;

	public function getCurMenuItems()
	{
		return (selOnRight ? menuItemsRight : menuItems);
	}

	function setOnRight(isNowRight:Bool)
	{
		selOnRight = (isNowRight && ClientPrefs.getKeyUnlocked("house-end"));
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

	// mario teaches typing
	var typingGoals:Array<String> = ['fred', 'uncle fred', 'impostor top 10', 'wrong house', 'crossover', 'fnf vs uncle fred full week mod', 'top 10', 'karrd kollision',
									'leak', 'vs uncle fred', 'secret', 'hello chat', 'source code', 'github', 'yeah', #if debug 'bug blaster', 'theory' #end];
	var typingBuffer:String = '';
	var keyBlacklist:Array<String> = ['left', 'down', 'up', 'right'];
	var numberNames:Array<String> = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'];

	private function checkKeyDown(evt:KeyboardEvent)
	{
		if (!beatenToadWeekONE)
		{
			typingBuffer = '';
			return;
		}
		var keyName:String = FlxKey.toStringMap.get(evt.keyCode).toLowerCase();
		if (keyBlacklist.contains(keyName))
			return;
		
		if (keyName == 'space')
			keyName = ' ';

		var numbIndex:Int = numberNames.indexOf(keyName);
		if (numbIndex != -1)
			keyName = Std.string(numbIndex);

		if (keyName == 'backspace' && typingBuffer.length > 0)
		{
			skipNext = true;
			var newLength:Int = typingBuffer.length - 1;
			if (newLength == 0) {
				typingDisplay.text = "";
				typingBuffer = "";
				FlxG.sound.muteKeys = TitleState.muteKeys;
				FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
				FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
				return;
			}
			typingBuffer = typingBuffer.substr(0, newLength);
			typingDisplay.text = typingBuffer;
		}
		else {
			skipNext = true;
			typingBuffer += keyName;
		}
		
		FlxG.sound.muteKeys = [];
		FlxG.sound.volumeDownKeys = [];
		FlxG.sound.volumeUpKeys = [];
		//trace(typingBuffer);

		var found:Bool = false;

		for (goal in typingGoals)
		{
			if (goal.toLowerCase() == typingBuffer)
			{
				trace("redeeming " + goal);
				typingDisplay.text = goal;
				typingDisplay.color = FlxColor.LIME;
				FlxG.sound.muteKeys = TitleState.muteKeys;
				FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
				FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;

				switch (goal.toLowerCase()) {
					case 'fred' | 'uncle fred' | 'impostor' | 'wrong house' | 'crossover' | 'fnf vs uncle fred full week mod' | 'vs uncle fred' | 'secret' | 'hello chat':
						trace("federal agents in your mailbox");
						WeekData.reloadWeekFiles(null, true);
						if (!WeekData.weeksList.contains(CoolUtil.fredCrossoverWeekName)) {
							trace("WARNING! Fred week has NOT been found! (Have you named the file something other than " + CoolUtil.fredCrossoverWeekName + "?)");
							trace(WeekData.weeksList);
							FlxG.resetState();
							break;
						}
						CoolUtil.loadWeek(WeekData.weeksLoaded.get(CoolUtil.fredCrossoverWeekName), -1, 0, true);
					case 'impostor top 10' | 'top 10':
						if (!CoolUtil.loadFreeplaySong("", "Incorrect Residence")) {
							trace("WARNING! Cannot load Incorrect Residence!");
							FlxG.resetState();
							break;
						}
					case 'leak':
						typingDisplay.text = typingBuffer = '';
						FlxG.openURL("https://www.youtube.com/watch?v=uj3QOMSKqOc");
					case 'source code' | 'github':
						typingDisplay.text = typingBuffer = '';
						FlxG.openURL("https://github.com/DillyzThe1/FNF-MKM-PUBLIC");
					case 'yeah':
						if (!CoolUtil.loadFreeplaySong("", "yeah")) {
							trace("WARNING! Cannot load yeah!");
							FlxG.resetState();
							break;
						}
					#if debug
					case 'bug blaster' | 'theory':
						if (!CoolUtil.loadFreeplaySong("", "Bug Blaster")) {
							trace("WARNING! Cannot load Bug Blaster!");
							FlxG.resetState();
							break;
						}
					#end
					default:
						trace("WARNING! Key " + goal + " is missing a reward!");
						typingDisplay.text = typingBuffer = '';
				}
				return;
			}
			if (goal.toLowerCase().startsWith(typingBuffer)) {
				typingDisplay.text = typingBuffer;
				for (i in 0...goal.length - typingDisplay.text.length)
					typingDisplay.text += "?";
				found = true;
				break;
			}
		}

		if (!found) {
			typingBuffer = '';
			typingDisplay.text = '';
			skipNext = false;
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
		}
		typingDisplay.color = FlxColor.WHITE;
	}

	override public function destroy()
	{
		Mhat.call("menu_main_end");
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkKeyDown);
		super.destroy();
	}
	//
}
