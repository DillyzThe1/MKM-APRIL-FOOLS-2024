package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;

using StringTools;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Exit to menu'];

	public static var parentalControls_vals_default:Array<Bool> = [true, false, false, true, false, false, true, #if debug true, #end];
	public static var parentalControls_vals:Array<Bool> = parentalControls_vals_default.copy();

	var parentalControls:Array<String> = ['Input', 'Health Regen', 'Baby Mode', 'UI', 'Cinematic Mode', 'No Death', 'Mute On Miss', #if debug 'miss notes', #end 'Back'];
	var difficultyChoices:Array<String> = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);

	// var botplayText:FlxText;
	public static var songName:String = '';

	var songMode:Bool = false;
	var canExitLmaooooo:Bool = false;

	var extraWario:Array<String> = ["Listen To It", "My New Song", "Deem The Steam", "The Mustache's Command", "Pass the Time", "Gas the Time",
									"giggle", "New Song", "WANNA LISTEN TO MY NEW SONG", "Listen", "Songify Premium", "Pay $12.99", "i forgot",
									"WAAAAAAAAAAAAAH", "free song", "New Single Songs in YOUR Area", "songinator", "wrong song", "vs song full song song"];
	var warioItems:Array<String> = ["Listen To It", "My New Song", "Deem The Steam", "The Mustache's Command", "...",
										"MY", "MUSTACHE", "HAS", "DEEMED", "THAT", "YOU", "GET", "THE", "WARIO", "STEAM"];
	var warioIndex:Int = 0;

	var walletTxt:FlxText;

	function makeMenuItems() {
		if (PlayState.SONG.song.toLowerCase() == "wario's song") {
			menuItems = ["Obey Song", "Exit to menu"];
			songMode = true;
			return;
		}

		if (PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Leave Charting Mode');

			var num:Int = 0;
			if (!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
			menuItemsOG.insert(5 + num, 'Toggle Botplay');
		}
		menuItems = menuItemsOG;

		//if (PlayState.SONG.song.toLowerCase().replace(" ", "-") == "house")
		menuItemsOG.insert(2, 'Parental Controls');
	}

	public function new(x:Float, y:Float)
	{
		super();

		makeMenuItems();

		for (i in 0...CoolUtil.difficulties.length)
		{
			var diff:String = '' + CoolUtil.difficulties[i];

			if (!CoolUtil.hiddenDifficulties.contains(diff) || CoolUtil.songCompletedOnDiff(PlayState.SONG.song, diff))
				difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		if (difficultyChoices.length < 2)
			menuItemsOG.remove('Change Difficulty'); // No need to change difficulty if there is only one!

		pauseMusic = new FlxSound();
		if (songName != null)
		{
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		}
		else if (songName != 'None')
		{
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath('Betwixt The Chaos')), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var epicfailsTxt:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		epicfailsTxt.text = "Sentenced to Clam Blitz " + PlayState.deathCounter + " times.";
		epicfailsTxt.scrollFactor.set();
		epicfailsTxt.setFormat(Paths.font('vcr.ttf'), 32);
		epicfailsTxt.updateHitbox();
		add(epicfailsTxt);
		
		walletTxt = new FlxText(20, 15 + 96, 0, "", 32);
		walletTxt.text = "Balance: " + ClientPrefs.getMoney();
		walletTxt.scrollFactor.set();
		walletTxt.setFormat(Paths.font('vcr.ttf'), 32);
		walletTxt.updateHitbox();
		add(walletTxt);
		FlxG.save.data.money = ClientPrefs.money;

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		epicfailsTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		walletTxt.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		epicfailsTxt.x = FlxG.width - (epicfailsTxt.width + 20);
		walletTxt.x = FlxG.width - (walletTxt.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(epicfailsTxt, {alpha: 1, y: epicfailsTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(walletTxt, {alpha: 1, y: walletTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;

	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			if (songMode && curSelected == 0) {
				menuItems.insert(0, "!");
				for (i in 0...grpMenuShit.members.length)
					grpMenuShit.members[i].targetY++;
				var item = new Alphabet(0, 70 + 30, "!", true, false);
				item.isMenuItem = true;
				item.targetY = 0;
				grpMenuShit.insert(0, item);
				changeSelection();
			}
			else
				changeSelection(-1);
		}
		if (downP)
		{
			if (songMode && !canExitLmaooooo && curSelected >= menuItems.length - 2) {
				var epicText:String = warioIndex >= warioItems.length ? ((warioIndex < 32 || FlxG.random.bool(80)) ? "!" : extraWario[FlxG.random.int(0, extraWario.length - 1)]) : warioItems[warioIndex];
				var item = new Alphabet(0, 70 * (menuItems.length - 1) + 30, epicText, true, false);
				item.isMenuItem = true;
				item.targetY = menuItems.length - 1;
				menuItems.insert(menuItems.length - 1, epicText);
				grpMenuShit.insert(grpMenuShit.length - 1, item);
				warioIndex++;
			}
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if (controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if (holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if (curTime >= FlxG.sound.music.length)
						curTime -= FlxG.sound.music.length;
					else if (curTime < 0)
						curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted && (cantUnpause <= 0 || !ClientPrefs.controllerMode))
		{
			if (songMode) {
				switch (daSelected.toLowerCase()) {
					case "pay $12.99":
						if (canExitLmaooooo)
							return;

						if (ClientPrefs.money < 12.99) {
							grpMenuShit.members[curSelected].changeText("get a job");
							return;
						}

						ClientPrefs.money -= 12.99;
						walletTxt.text = "Balance: " + ClientPrefs.getMoney();
						FlxG.sound.play(Paths.sound('kaching'));
						canExitLmaooooo = true;
						grpMenuShit.members[curSelected].changeText("You may now leave.");
					case "exit to menu":
						if (!canExitLmaooooo) {
							trace("I FOUND YOU, YOU child-friendly-adjective CHEATER!!!!!!!!!");
							close();
							return;
						}
						PlayState.deathCounter = 0;
						PlayState.seenCutscene = false;
						MusicBeatState.switchState(PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState());
						PlayState.cancelMusicFadeTween();
						CoolUtil.playMenuTheme();
						PlayState.changedDifficulty = false;
						PlayState.chartingMode = false;
					default:
						close();
				}
				return;
			}

			if (menuItems == difficultyChoices)
			{
				if (menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected))
				{
					var name:String = PlayState.SONG.song;
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			if (menuItems == parentalControls)
			{
				if (menuItems.length - 1 != curSelected && parentalControls.contains(daSelected))
				{
					// regenMenu();
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					parentalControls_vals[curSelected] = !parentalControls_vals[curSelected];
					grpMenuShit.members[curSelected].changeText(menuItems[curSelected] + " - " + (parentalControls_vals[curSelected] ? "On" : "Off"));
					return;
				}

				if (parentalControls_vals[2])
				{
					CoolUtil.toggleBabyMode(true);
					return;
				}

				ClientPrefs.gameplaySettings['botplay'] = PlayState.instance.cpuControlled = parentalControls_vals[4];
				if (Main.fpsVar != null) {
					Main.fpsVar.showFps = Main.fpsVar.showMemory = !parentalControls_vals[4];
					Main.fpsVar.updateText();
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "Resume":
					close();
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					deleteSkipTimeText();
					regenMenu();
				case 'Parental Controls':
					menuItems = parentalControls;
					parentalControls_vals[4] = ClientPrefs.getGameplaySetting('botplay', false);
					deleteSkipTimeText();
					regenMenu();

					for (i in 0...(menuItems.length - 1))
						grpMenuShit.members[i].changeText(menuItems[i] + " - " + (parentalControls_vals[i] ? "On" : "Off"));
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "Restart Song":
					restartSong();
				case "Leave Charting Mode":
					restartSong();
					PlayState.chartingMode = false;
				case 'Skip Time':
					if (curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
				case "End Song":
					close();
					PlayState.instance.finishSong(true);
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case "Exit to menu":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					if (PlayState.isStoryMode)
					{
						MusicBeatState.switchState(new StoryMenuState());
					}
					else
					{
						MusicBeatState.switchState(new FreeplayState());
					}
					PlayState.cancelMusicFadeTween();
					CoolUtil.playMenuTheme();
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
			}
		}
	}

	function deleteSkipTimeText()
	{
		if (skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		if (PlayState.instance.splitVocals)
		{
			PlayState.instance.vocalsLeft.volume = 0;
			PlayState.instance.vocalsRight.volume = 0;
		}
		else
			PlayState.instance.vocals.volume = 0;

		if (noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));

				if (item == skipTimeTracker)
				{
					curTime = Math.max(0, Conductor.songPosition);
					updateSkipTimeText();
				}
			}
		}
	}

	function regenMenu():Void
	{
		for (i in 0...grpMenuShit.members.length)
		{
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length)
		{
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);

			if (menuItems[i] == 'Skip Time')
			{
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		curSelected = 0;
		changeSelection();
	}

	function updateSkipTextStuff()
	{
		if (skipTimeText == null || skipTimeTracker == null)
			return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false)
			+ ' / '
			+ FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}
