package;

import editors.ChartingState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class FreeplayDifficultySubstate extends MusicBeatSubstate {
	var stars:FlxTypedGroup<MaroStar>;
    var curStar:Int = 0;
    var hasSel:Bool = false;

    var songName:String = '';

    var diffCam:FlxCamera;

    var diffText:FlxText;
    var songText:FlxText;

    public function new (song:String) {
        super();
        this.songName = song;
    }
    
    public override function create() {
        super.create();

		var offset:Float = FlxG.height * -0.1;

		diffCam = new FlxCamera();
		diffCam.bgColor.alpha = 0;
		FlxG.cameras.add(diffCam, false);

		stars = new FlxTypedGroup<MaroStar>();

        for (i in 0...CoolUtil.difficulties.length) {
			var star:MaroStar = new MaroStar(CoolUtil.difficulties[i], songName);
			star.screenCenter(X);
			star.x += 125 * (i - (CoolUtil.difficulties.length - 1.0) / 2.0);
			star.y = FlxG.height * 0.2 + offset;
			star.antialiasing = ClientPrefs.globalAntialiasing;
			stars.add(star);
		}
		add(stars);

		var playerSymbol:FlxSprite = new FlxSprite(0, FlxG.height / 2 + offset).loadGraphic(Paths.image("difficon","preload"));
        playerSymbol.screenCenter(X);
		playerSymbol.antialiasing = ClientPrefs.globalAntialiasing;
		add(playerSymbol);

		songText = new FlxText(0, playerSymbol.y + playerSymbol.height + 10, 0, songName, 32, true);
		songText.color = FlxColor.BLACK;
		songText.alignment = CENTER;
		add(songText);
		songText.screenCenter(X);

		diffText = new FlxText(0, FlxG.height * 0.275, 0, "", 16, true);
		diffText.color = FlxColor.BLACK;
		diffText.alignment = CENTER;
		add(diffText);

		stars.cameras = playerSymbol.cameras = songText.cameras = diffText.cameras = [diffCam];

        FlxG.sound.play(Paths.sound("difficulty screen", "preload"), 0.75);
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

		//trace(stars.members[curStar].diffName);
		diffText.text = stars.members[curStar].diffName;
		diffText.screenCenter(X);
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
    public var diffName:String;

	public function new(diffName:String, song:String) {
        super();
        this.frames = Paths.getSparrowAtlas("diffstar", "preload");
		this.animation.addByPrefix("empty", "star0", 24, true, false, false);
		this.animation.addByPrefix("full", "star full0", 24, true, false, false);
		this.animation.play("empty", true);

		this.diffName = diffName;

		setEmpty(Highscore.getScore(song, getDiffIndex()) < 10);
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