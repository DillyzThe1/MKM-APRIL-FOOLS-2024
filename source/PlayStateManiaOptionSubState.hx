package;

import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

class PlayStateManiaOptionSubState extends MusicBeatSubstate
{
	public var newCam:FlxCamera;
	public var ipAddress:(SwagSong) -> Void;

	public var camText:FlxText;

	public var nextSong:SwagSong;
	public var nextSongSkillIssue:SwagSong;

	override public function new(bruh:SwagSong)
	{
		super();
		nextSong = bruh;
	}

	override public function create()
	{
		super.create();

		var difficulty:String = CoolUtil.getDifficultyFilePath();
		for (i in 0...CoolUtil.difficulties.length)
			if (CoolUtil.difficulties[i].toLowerCase().replace('-', ' ') == 'skill issue')
				difficulty = CoolUtil.getDifficultyFilePath(i);
		nextSongSkillIssue = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);

		newCam = new FlxCamera();
		newCam.bgColor.alpha = 125;
		FlxG.cameras.add(newCam, false);

		camText = new FlxText(0, 0, FlxG.width,
			"Hey!\nThe next song here uses a few EK mechanics!\n\nIf you wish to disable them, hit ESCAPE!\nOtherwise, hit ENTER!", 32);
		camText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		camText.screenCenter(Y);
		add(camText);
		camText.cameras = [newCam];

		newCam.alpha = 0;

		hasChosen = true;
		FlxTween.tween(newCam, {alpha: 1}, 0.75, {
			ease: FlxEase.cubeInOut,
			onComplete: function(t:FlxTween)
			{
				hasChosen = false;
			}
		});
	}

	public var hasChosen:Bool = false;

	override public function update(e:Float)
	{
		super.update(e);

		if (hasChosen)
			return;

		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.ENTER)
		{
			var bruhhhhhhhh:Bool = FlxG.keys.justPressed.ENTER;
			hasChosen = true;
			FlxTween.tween(newCam, {alpha: 0}, 0.75, {
				ease: FlxEase.cubeInOut,
				onComplete: function(t:FlxTween)
				{
					FlxG.cameras.remove(newCam);
					for (i in 0...CoolUtil.difficulties.length)
						if (CoolUtil.difficulties[i].toLowerCase().replace('-', ' ') == 'skill issue')
							PlayState.storyDifficulty = i;
					if (ipAddress != null)
						ipAddress(bruhhhhhhhh ? nextSong : nextSongSkillIssue);
				}
			});
		}
	}
}
