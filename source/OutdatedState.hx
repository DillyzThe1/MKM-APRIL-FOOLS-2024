package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;

	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		warnText = new FlxText(0, 0, FlxG.width, getStr(), 32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	function getStr()
	{
		if (MainMenuState.mkm_RELEASE_TRACKER > TitleState.updateTracker)
			return "Hey, looks like you're enjoying MKM!\nUnfortunately, this version (update v"
				+ MainMenuState.mushroomKingdomMadnessVersion
				+ ") is a leaked dev-build.\nPlease download the official v"
				+ TitleState.updateVersion
				+ " build instead!"
				+ "\n(hit enter to download, hit escape to disappoint your father).\n
			\n\nThank you for playing Mushroom Kingdom Madness!";

		if (MainMenuState.mkm_RELEASE_TRACKER == TitleState.updateTracker)
			return "Hey, looks like you're enjoying MKM!\nIt appears this message has appeared by mistake.\nPlease hit ESCAPE to ignore this!
			\n\nThank you for playing Mushroom Kingdom Madness!";

		return "Hey, looks like you're enjoying MKM!\nUnfortunately, this version (update v"
			+ MainMenuState.mushroomKingdomMadnessVersion
			+ ") is out of date.\nPlease update to v"
			+ TitleState.updateVersion
			+ "!"
			+ "\n(hit enter to download, hit escape to whine about it).\n
			\n\nThank you for playing Mushroom Kingdom Madness!";
	}

	override function update(elapsed:Float)
	{
		if (!leftState)
		{
			if (controls.ACCEPT)
			{
				leftState = true;
				CoolUtil.browserLoad(TitleState.updateURL);
			}
			else if (controls.BACK)
				leftState = true;

			if (leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function(twn:FlxTween)
					{
						MusicBeatState.switchState(new MainMenuState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}
