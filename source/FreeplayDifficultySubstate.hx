package;

import editors.ChartingState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;

class FreeplayDifficultySubstate extends MusicBeatSubstate {
	var stars:FlxTypedGroup<MaroStar>;
    var curStar:Int = 0;
    var hasSel:Bool = false;

    var songName:String = '';

    var diffCam:FlxCamera;

    public function new (song:String) {
        super();
        this.songName = song;
    }
    
    public override function create() {
        super.create();

		diffCam = new FlxCamera();
		diffCam.bgColor.alpha = 0;
		FlxG.cameras.add(diffCam, false);

		stars = new FlxTypedGroup<MaroStar>();

        for (i in 0...CoolUtil.difficulties.length) {
			var star:MaroStar = new MaroStar(CoolUtil.difficulties[i]);
			star.screenCenter(X);
			var thingpleasework:Float = CoolUtil.difficulties.length - 1;
			thingpleasework /= 2.0;
			var thing:Float = thingpleasework - i;
			trace(thingpleasework + " " + thing);
			star.x += 125 * thing;
			star.y = FlxG.height * 0.2;
			stars.add(star);
		}
		add(stars);

        var playerSymbol:FlxSprite = new FlxSprite(0,FlxG.height/2).loadGraphic(Paths.image("difficon","preload"));
        playerSymbol.screenCenter(X);
		add(playerSymbol);

		stars.cameras = playerSymbol.cameras = [diffCam];

        FlxG.sound.play(Paths.sound("difficulty screen", "preload"));
		changeSel();
    }

    public function select() {
		hasSel = true;
        
		PlayState.storyDifficulty = stars.members[curStar].getDiffIndex();
		var songLowercase:String = Paths.formatToSongPath(songName);
		var peopleOrderOurPatties:String = Highscore.formatSong(songLowercase, PlayState.storyDifficulty);
		PlayState.SONG = Song.loadFromJson(peopleOrderOurPatties, songLowercase);

		var goToChart:Bool = FlxG.keys.pressed.SHIFT;
		diffCam.fade(FlxColor.BLACK, 0.15, false, function()
        {
            LoadingState.loadAndSwitchState(goToChart ? new ChartingState() : new PlayState());
		});
    }

    public function changeSel(?amount:Int = 0) {
        curStar += amount;
        if (curStar < 0)
			curStar = stars.members.length - 1;
		if (curStar >= stars.members.length)
			curStar = 0;

        for (star in 0...stars.members.length)
        {
			var intendedScale:Float = (star == curStar) ? 1.15 : 0.95;
			stars.members[star].scale.set(intendedScale, intendedScale);
        }
    }

    public override function update(e:Float) {
        super.update(e);

        if (hasSel)
            return;

        if (controls.UI_LEFT_P)
			changeSel(-1);
		else if (controls.UI_RIGHT_P)
			changeSel(-1);
        else if (controls.ACCEPT)
			select();
    }
}

class MaroStar extends FlxSprite {
    var diffName:String;

	public function new(diffName:String) {
        super();
        this.frames = Paths.getSparrowAtlas("diffstar", "preload");
		this.animation.addByPrefix("empty", "star0", 24, true, false, false);
		this.animation.addByPrefix("full", "star full0", 24, true, false, false);
		this.animation.play("empty", true);

		this.diffName = diffName;
    }

    var lastEmpty:Bool = true;
    public function setEmpty(empty:Bool) {
		if (lastEmpty == empty)
            return;
        this.animation.play(empty ? "empty" : "full", true);
		this.lastEmpty = empty;
    }

    public function getDiffIndex()
		return CoolUtil.difficulties.indexOf(diffName);
}