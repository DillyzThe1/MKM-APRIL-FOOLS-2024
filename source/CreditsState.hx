package;

import Discord.DiscordClient;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<Dynamic>> = [];

	private var voiceIcons:Array<HealthIcon> = [];
	private var voiceIcons_Tweens:Array<FlxTween> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var newDescBox:CaptionObject;

	var offsetThing:Float = -75;

	override function create()
	{
		// Updating Discord Rich Presence
		DiscordClient.inMenus();
		Mhat.call("menu_credits");

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		var pisspoop:Array<Array<Dynamic>> = [
			// Name - Icon name - Description - Link - BG Color - Voice(s)
			['Mushroom Kingdom Madness'],
			[
				'DillyzThe1',
				'dillyz',
				'Programmer, Artist, Animator,\nMusician, Voice Actor, etc.',
				'https://github.com/DillyzThe1/',
				'FF9933',
				// NOTE: sometimes i voice boyman, but he doesn't exist... soooo.....
				['square', 'luigi', 'pico', 'peter']
			],
			[
				'That1LazerBoi',
				'lazer',
				'Director, Musician, & Voice Actor.',
				'https://www.youtube.com/c/That1LazerBoidoodoofart/',
				'FFFF33',
				['bup', 'toad', 'lazer']
			],
			[
				'Zarzok',
				'zarzok',
				'Musician, Feedback, & Play Tester.',
				'https://gamebanana.com/members/1862368/',
				'FF99CC',
				['circle', 'wario']
			],
			[
				'Impostor',
				'impostor',
				'Musician, Some Crossover Art/Animation,\nFeedback, & Play Tester.',
				'https://gamebanana.com/members/1895937/',
				'505050',
				['impostor', 'this-render']
			],
			[''],
			[' Engine Team'],
			[
				'Shadow Mario',
				'shadowmario',
				'Main Programmer of  Engine',
				'https://twitter.com/Shadow_Mario_',
				'444444'
			],
			[
				'RiverOaken',
				'river',
				'Main Artist/Animator of  Engine',
				'https://twitter.com/RiverOaken',
				'B42F71'
			],
			[
				'shubs',
				'shubs',
				'Additional Programmer of  Engine',
				'https://twitter.com/yoshubs',
				'5E99DF'
			],
			[''],
			['Former Engine Members'],
			[
				'bb-panzu',
				'bb',
				'Ex-Programmer of  Engine',
				'https://twitter.com/bbsub3',
				'3E813A'
			],
			[''],
			['Engine Contributors'],
			[
				'iFlicky',
				'flicky',
				'Composer of  and  \nMade the  Sounds',
				'https://twitter.com/flicky_i',
				'9E29CF'
			],
			[
				'SqirraRNG',
				'sqirra',
				'Crash Handler and Base code for\nChart Editor\'s Waveform',
				'https://twitter.com/gedehari',
				'E1843A'
			],
			[
				'PolybiusProxy',
				'proxy',
				'.MP4 Video Loader Library (hxCodec)',
				'https://twitter.com/polybiusproxy',
				'DCD294'
			],
			[
				'KadeDev',
				'kade',
				'Fixed some cool stuff on Chart Editor\nand other PRs',
				'https://twitter.com/kade0912',
				'64A250'
			],
			[
				'Keoiki',
				'keoiki',
				'Note Splash Animations',
				'https://twitter.com/Keoiki_',
				'D2D2D2'
			],
			[
				'Nebula the Zorua',
				'nebula',
				'LUA JIT Fork and some Lua reworks',
				'https://twitter.com/Nebula_Zorua',
				'7D40B2'
			],
			[
				'Smokey',
				'smokey',
				'Sprite Atlas Support',
				'https://twitter.com/Smokey_5_',
				'483D92'
			],
			[''],
			["' Crew"],
			[
				'ninjamuffin99',
				'ninjamuffin99',
				"Programmer of   '",
				'https://twitter.com/ninja_muffin99',
				'CF2D2D'
			],
			[
				'PhantomArcade',
				'phantomarcade',
				"Animator of   '",
				'https://twitter.com/PhantomArcade3K',
				'FADC45'
			],
			[
				'evilsk8r',
				'evilsk8r',
				"Artist of   '",
				'https://twitter.com/evilsk8r',
				'5ABD4B'
			],
			[
				'kawaisprite',
				'kawaisprite',
				"Composer of   '",
				'https://twitter.com/kawaisprite',
				'378FC7'
			]
		];

		for (i in pisspoop)
		{
			creditsStuff.push(i);
		}

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			optionText.yAdd -= 70;
			if (isSelectable)
			{
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			// optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (isSelectable)
			{
				if (creditsStuff[i][5] != null)
				{
					Paths.currentModDirectory = creditsStuff[i][5];
				}

				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;

				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Paths.currentModDirectory = '';

				if (curSelected == -1)
					curSelected = i;
			}
		}

		newDescBox = new CaptionObject("");
		newDescBox.animate = true;
		add(newDescBox);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!quitting)
		{
			if (creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if (FlxG.keys.pressed.SHIFT)
					shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-1 * shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(1 * shiftMult);
					holdTime = 0;
				}

				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if (controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4))
			{
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}
			if (controls.BACK)
			{
				if (colorTween != null)
				{
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}

		for (item in grpOptions.members)
		{
			if (!item.isBold)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if (item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
					item.forceX = item.x;
				}
				else
				{
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
					item.forceX = item.x;
				}
			}
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		}
		while (unselectableCheck(curSelected));

		var newColor:Int = getCurrentBGColor();
		if (newColor != intendedColor)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCheck(bullShit - 1))
			{
				item.alpha = 0.6;
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
		}

		newDescBox.text = creditsStuff[curSelected][2];
		
		if (creditsStuff[curSelected].length < 6) {
			for (i in voiceIcons)
				i.visible = false;
			return;
		}

		var iconsToShow:Array<String> = creditsStuff[curSelected][5];
		
		if (iconsToShow.length == 0) {
			for (i in voiceIcons)
				i.visible = false;
			return;
		}

		if (voiceIcons.length < iconsToShow.length)
			for (i in 0...(iconsToShow.length - voiceIcons.length)) {
				var newIcon:HealthIcon = new HealthIcon('toad', false);
				newIcon.y = (FlxG.height * 0.875) - 185;
				//newIcon.y = FlxG.height * 0.225;
				add(newIcon);
				voiceIcons.push(newIcon);
				voiceIcons_Tweens.push(null);
			}

		for (i in 0...voiceIcons.length) {
			if (i >= iconsToShow.length) {
				voiceIcons[i].visible = false;
				continue;
			}

			voiceIcons[i].visible = true;
			voiceIcons[i].changeIcon(iconsToShow[iconsToShow.length - i - 1]);
			// i don't feel like fixing this.
			var realTwitterValue:Float = (FlxG.width / 2) - (i * 150) - 75 + ((iconsToShow.length - 1) * 75);
			voiceIcons[i].x = FlxMath.lerp((FlxG.width / 2) - 75, realTwitterValue, 0.75);

			voiceIcons[i].scale.set(0.8, 0.8);
			if (voiceIcons_Tweens[i] != null)
				voiceIcons_Tweens[i].cancel();
			voiceIcons_Tweens[i] = FlxTween.tween(voiceIcons[i], {x: realTwitterValue, "scale.x": 1, "scale.y": 1}, 0.25, {ease: FlxEase.cubeOut});
		}
	}

	function getCurrentBGColor()
	{
		var bgColor:String = creditsStuff[curSelected][4];
		if (!bgColor.startsWith('0x'))
		{
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool
	{
		return creditsStuff[num].length <= 1;
	}

	override function destroy()
	{
		Mhat.call("menu_credits_end");
		super.destroy();
	}
}
