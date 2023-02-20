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

	override public function new(aaaaaaaaaaaaaa:(SwagSong) -> Void)
	{
		super();
		this.ipAddress = aaaaaaaaaaaaaa;
	}

	override public function create()
	{
		super.create();

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
					if (ipAddress != null) {
						PlayState.storyDifficulty = CoolUtil.tryGettingDifficulty(bruhhhhhhhh ? "Hard" : "Skill Issue", "Hard");
						trace("GAHHHHHHHHHHHHHH " + CoolUtil.getDifficultyFilePath(PlayState.storyDifficulty));
						ipAddress(Song.loadFromJson(PlayState.storyPlaylist[0] + CoolUtil.getDifficultyFilePath(PlayState.storyDifficulty), PlayState.storyPlaylist[0]));
					}
				}
			});
		}
	}
}
