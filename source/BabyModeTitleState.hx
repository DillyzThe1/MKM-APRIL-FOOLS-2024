package;

import Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

typedef ButtonData = {
    var name:String;
    var frameIndex:Int;
    var disabled:Bool;
} 

class BabyModeTitleState extends MusicBeatState {
    var bg:FlxSprite;
    var logo:FlxSprite;
    var dangerIcons:Array<DangerIcon> = [];
    var menuButtons:Array<FlxSprite> = [];
    
    var buttonDatas:Array<ButtonData> = [
        {
            name: "Story Mode",
            frameIndex: 0,
            disabled: true
        },
        {
            name: "Freeplay",
            frameIndex: 1,
            disabled: false
        },
        {
            name: "Options",
            frameIndex: 2,
            disabled: true
        }
    ];

    public override function create() {
        super.create();

        DiscordClient.updateLargeImage(true);
		DiscordClient.changePresence("In the Age Appropriate Menus", null);

        bg = new FlxSprite().loadGraphic(Paths.image("babymode/bg", "preload"));
        bg.screenCenter();
        add(bg);
        bg.antialiasing = ClientPrefs.globalAntialiasing;

        logo = new FlxSprite(0, FlxG.height * -0.125).loadGraphic(Paths.image("babymode/logo", "preload"));
        logo.screenCenter(X);
        logo.scale.x = logo.scale.y = 0.65;
        add(logo);
        logo.antialiasing = ClientPrefs.globalAntialiasing;

        for (i in 0...buttonDatas.length) {
            var curData:ButtonData = buttonDatas[i];
            var newButton:FlxSprite = new FlxSprite(0, FlxG.height * 0.325 + (FlxG.height * 0.2 * i));
            newButton.frames = Paths.getSparrowAtlas("babymode/menubuttons", "preload");
            newButton.animation.addByIndices("button", "baby menubuttons0", [curData.frameIndex], "", 24, false);
            newButton.animation.play("button", true);
            newButton.screenCenter(X);
            newButton.antialiasing = ClientPrefs.globalAntialiasing;

            if (curData.disabled) {
                newButton.scale.x = newButton.scale.y = 0.95;
                newButton.alpha = 0.65;

                var newDanger:DangerIcon = new DangerIcon(newButton);
                dangerIcons.push(newDanger);
                add(newDanger);
            }
            else
                newButton.scale.x = newButton.scale.y = 1.1;

            add(newButton);
            menuButtons.push(newButton);
        }
    }

    var hasPressed:Bool = false;

    public override function update(e:Float) {
        super.update(e);

        if (controls.ACCEPT && !hasPressed) {
            hasPressed = true;
            
            if (ClientPrefs.flashing)
                FlxG.camera.flash();
            FlxG.sound.play(Paths.sound('confirmMenu'));

            for (i in 0...menuButtons.length) {
                if (i != 1)
                {
                    FlxTween.tween(menuButtons[i], {alpha: 0}, 0.4, {
                        ease: FlxEase.quadOut,
                        onComplete: function(twn:FlxTween)
                        {
                            menuButtons[i].kill();
                        }
                    });
                }
                else
                {
                    FlxFlicker.flicker(menuButtons[i], 1, 0.06, false, false, function(flick:FlxFlicker)
                    {
                        if (!CoolUtil.loadFreeplaySong(CoolUtil.babyModeWeekName, "Jhonny")) {
                            CoolUtil.toggleBabyMode(false);
                            MusicBeatState.switchState(new MainMenuState());
                            FlxG.sound.play(Paths.sound('cancelMenu'));
                        }
                    });
                }
            }
        }
    }
}

class DangerIcon extends FlxSprite {
    var mbToFollow:FlxSprite;
    public function new(mbToFollow:FlxSprite) {
        super();
        loadGraphic(Paths.image("babymode/Danger - Vs Impostor", "preload"));
        scale.x = scale.y = 0.5;
        antialiasing = ClientPrefs.globalAntialiasing;

        this.mbToFollow = mbToFollow;
    }

    public override function update(e:Float) {
        super.update(e);

        if (mbToFollow != null)
            this.setPosition(mbToFollow.x + mbToFollow.width - 150, mbToFollow.y + mbToFollow.height/2 - this.height/2);
    }
}