package;

import editors.ChartingState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.utils.AssetType;

using StringTools;

class FreeplayDifficultySubstate extends MusicBeatSubstate {
	var stars:FlxTypedGroup<MaroStar>;
    var curStar:Int = 0;
    var hasSel:Bool = false;

    var songName:String = '';

    var diffCam:FlxCamera;

    var diffText:FlxText;
    var songText:FlxText;

	var funnyBupBupBupSound:FlxSound;

    public function new (song:String) {
        super();
        this.songName = song;
    }
    
    public override function create() {
        super.create();

		CoolUtil.loadSongDiffs(songName);

		var offset:Float = FlxG.height * -0.1;

		diffCam = new FlxCamera();
		diffCam.bgColor.alpha = 0;
		FlxG.cameras.add(diffCam, false);

		stars = new FlxTypedGroup<MaroStar>();

        for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = CoolUtil.difficulties[i];
			if (CoolUtil.hiddenDifficulties.contains(diff) &&!CoolUtil.songCompletedOnDiff(songName, diff))
				continue;
			var star:MaroStar = new MaroStar(diff, songName);
			star.screenCenter(X);
			star.y = FlxG.height * 0.2 + offset;
			star.antialiasing = ClientPrefs.globalAntialiasing;
			stars.add(star);
		}
		add(stars);

		for (i in 0...stars.members.length)
			stars.members[i].x += 125 * (i - (stars.length - 1.0) / 2.0);

		var thePngEver:FlxGraphic = null;
		var pngName:String = "data/" + songName.toLowerCase().replace(" ", "-") + "/difficon.png";
		if (Paths.fileExists(pngName, AssetType.IMAGE, false, "preload"))
			thePngEver = Paths.graphicFromLoosePath(pngName);
		else
			thePngEver = Paths.image("difficon", "preload");

		var playerSymbol:FlxSprite = new FlxSprite(0, FlxG.height / 2 + offset).loadGraphic(thePngEver);
        playerSymbol.screenCenter(X);
		playerSymbol.antialiasing = ClientPrefs.globalAntialiasing;
		add(playerSymbol);

		songText = new FlxText(0, playerSymbol.y + playerSymbol.height + 10, 0, songName, 32, true);
		songText.color = FlxColor.BLACK;
		songText.alignment = CENTER;
		add(songText);
		songText.screenCenter(X);

		// top 10 amazing
		if (songText.width > FlxG.width * 0.95)
			songText.scale.x = (FlxG.width * 0.95)/songText.width;

		diffText = new FlxText(0, FlxG.height * 0.275, 0, "", 16, true);
		diffText.color = FlxColor.BLACK;
		diffText.alignment = CENTER;
		add(diffText);

		stars.cameras = playerSymbol.cameras = songText.cameras = diffText.cameras = [diffCam];

        funnyBupBupBupSound = FlxG.sound.play(Paths.sound("difficulty screen", "preload"), 0.75);
		changeSel();
    }

    public function select() {
		hasSel = true;
		FreeplayState.instance.pleaseStop = true;

		var goToChart:Bool = FlxG.keys.pressed.SHIFT;
		var epicfail:Bool = false;
		
		var songLowercase:String = Paths.formatToSongPath(songName);
		var diffLowercase:String = stars.members[curStar].diffName.toLowerCase();

		if (songLowercase == "bup" && diffLowercase == "alpha" && !ClientPrefs.getKeyUnlocked("no-way-end")) {
			PlayState.storyDifficulty = CoolUtil.loadSongDiffs("No Way");
			songLowercase = Paths.formatToSongPath("No Way");
			goToChart = false;
			epicfail = true;
		} 
		else if ((songLowercase == "chaotically-stupid" && (diffLowercase == "old" || diffLowercase == "alpha"))
				|| (songLowercase == "bup" && diffLowercase == "old")
				|| (songLowercase == "square" && diffLowercase == "alpha")
				|| songLowercase == "tutorial"
				|| songLowercase == "bug-blaster"
				|| (songLowercase == "merry-way" && diffLowercase == "beta")
				|| (songLowercase == "brrrrr" && (diffLowercase == "old" || diffLowercase == "alpha"))
				|| (songLowercase == "wario's-song" && diffLowercase == "Ultra Dubstep Techno Rock Metal Song-Like New Song My New Song Super Duper Bros. U 64 Kart Deluxe Remix".toLowerCase())) {
			var cahcnawagwgwgawgawaeassersdrtkjtdedr:Int = FlxG.random.int(1, 5);
			switch(songLowercase) {
				case "brrrrr":
					FlxG.sound.play(Paths.sound('brrrrr'), 1, false);
				default:
					FlxG.sound.play(Paths.sound('alpha/toadWeekRandom$cahcnawagwgwgawgawaeassersdrtkjtdedr'));
			}
			FlxG.sound.play(Paths.sound('missnote${FlxG.random.int(1, 3)}', 'shared'));
			diffCam.shake(0.05, 0.375);
			hasSel = false;
			FreeplayState.instance.pleaseStop = false;
			#if CHAT_LU_E_G__ALLOWED
			MusicBeatState.terror -= 120;
			trace(MusicBeatState.terror);
			if (MusicBeatState.terror <= 0)
				MusicBeatState.theHorrors();
			#end
			if (cahcnawagwgwgawgawaeassersdrtkjtdedr == 5)
				exitthing();
			return;
		} 
		else
			PlayState.storyDifficulty = CoolUtil.difficulties.indexOf(stars.members[curStar].diffName);
        
		var peopleOrderOurPatties:String = Highscore.formatSong(songLowercase, PlayState.storyDifficulty);
		PlayState.SONG = Song.loadFromJson(peopleOrderOurPatties, songLowercase);

		diffCam.fade(FlxColor.BLACK, 0.15, false, function()
        {
            LoadingState.loadAndSwitchState(goToChart ? new ChartingState() : new PlayState());
			PlayState.havingAnEpicFail = epicfail;
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

	function exitthing() {
		hasSel = true;
		FlxG.sound.play(Paths.sound('cancelMenu'));
		if (funnyBupBupBupSound != null)
			funnyBupBupBupSound.fadeOut(0.25);
		stars.destroy();
		songText.destroy();
		diffText.destroy();
		persistentUpdate = false;
		//diffCam.alpha = 0;
		close();
	}

    public override function update(e:Float) {
        super.update(e);

        if (hasSel)
            return;

        if (controls.UI_LEFT_P)
			changeSel(-1);
		else if (controls.UI_RIGHT_P)
			changeSel(1);
        else if (controls.ACCEPT)
			select();
	
		if (controls.BACK)
			exitthing();
    }
}

class MaroStar extends FlxSprite {
    public var diffName:String;

	public function new(diffName:String, song:String) {
        super();
        this.frames = Paths.getSparrowAtlas("diffstar", "preload");
		this.animation.addByPrefix("empty", "star0", 24, true, false, false);
		this.animation.addByPrefix("full", "star filled0", 24, true, false, false);
		this.animation.play("empty", true);

		this.diffName = diffName;

		setEmpty(!CoolUtil.songCompletedOnDiff(song, diffName));
    }

    var lastEmpty:Bool = true;
    public function setEmpty(empty:Bool) {
		if (lastEmpty == empty)
            return;
        this.animation.play(empty ? "empty" : "full", true);
		this.lastEmpty = empty;
	}
}