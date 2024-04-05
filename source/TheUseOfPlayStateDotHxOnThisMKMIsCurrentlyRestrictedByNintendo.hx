import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;

class TheUseOfPlayStateDotHxOnThisMKMIsCurrentlyRestrictedByNintendo extends MusicBeatSubstate
{
    var scary:BlurFilter;
    var newSuperScary:Array<BitmapFilter>;
    var bannedXd:FlxSprite;
    var theCamera:FlxCamera;
    var inputBlocked:Bool = true;

    //public static var
    public static var state:String = "";

    override public function create()
    {
        super.create();

        theCamera = new FlxCamera();
        FlxG.cameras.add(theCamera, false);
        theCamera.bgColor.alpha = 0;

        scary = new BlurFilter(1, 1, 15);
        newSuperScary = [scary];
        FlxG.camera.filtersEnabled = true;

        bannedXd = new FlxSprite(0, 0);
        bannedXd.scrollFactor.set();
        bannedXd.cameras = [theCamera];
        bannedXd.frames = Paths.getSparrowAtlas("The use of PlayState.hx on this MKM is currently restricted by Nintendo");
        bannedXd.animation.addByPrefix("open", "message box open", 60, false);
        bannedXd.animation.addByPrefix("close", "message box close", 60, false);
        bannedXd.animation.addByPrefix("idle", "message box default", 60);
        bannedXd.animation.addByPrefix("move left", "move left", 60, false);
        bannedXd.animation.addByPrefix("move down", "move down", 60, false);
        bannedXd.animation.addByPrefix("move up", "move up", 60, false);
        bannedXd.animation.addByPrefix("move right", "move right", 60, false);
        bannedXd.screenCenter();
        add(bannedXd);
        bannedXd.animation.play("idle", true);
        bannedXd.visible = false;

        new FlxTimer().start(1, function(t:FlxTimer) {
            FlxG.camera.setFilters(newSuperScary);
            FlxTween.tween(scary, {"blurX": 10, "blurY": 10}, 0.13);
            bannedXd.animation.play("open", true);
            bannedXd.visible = true;
        });
    }

    override public function update(elapsed)
    {
        bannedXd.animation.curAnim.update(elapsed); // why do i have to manually update it?????????????????????????????????????? what in the world??????????????????????????????????????

        if (bannedXd.animation.curAnim.finished && bannedXd.animation.curAnim.name == "close")
        {
            if (state == "storyMenu")
            {
                StoryMenuState.stopspamming = false;
                StoryMenuState.selectedWeek = false;
                StoryMenuState.grpWeekText.members[StoryMenuState.curWeek].stopFlashing();
            }
            else if (state == "freeplay")
            {
                FreeplayState.hasSelected = false;
            }

            close();
        }
        else if (bannedXd.animation.curAnim.finished && bannedXd.animation.curAnim.name == "open")
        {
            inputBlocked = false;
        }
        else if (bannedXd.animation.curAnim.finished && bannedXd.animation.curAnim.name != "idle")
        {
            bannedXd.offset.x = 0;
            bannedXd.animation.play("idle");
        }

        /*if (bannedXd.animation.curAnim.name == "move left") // i'd like to do the offsets this way but flixel is really goofy and waits a frame before applying the offset
            bannedXd.offset.x = 25;
        else if (bannedXd.animation.curAnim.name == "move right")
            bannedXd.offset.x = 11;
        else
            bannedXd.offset.x = 0;*/

        if (!inputBlocked)
        {
            if (controls.UI_LEFT_P)
            {
                bannedXd.offset.x = 25;
                bannedXd.animation.play("move left", true);
            }
            else if (controls.UI_RIGHT_P)
            {
                bannedXd.offset.x = 11;
                bannedXd.animation.play("move right", true);
            }
            else if (controls.UI_DOWN_P)
            {
                bannedXd.offset.x = 0;
                bannedXd.animation.play("move down", true);
            }
            else if (controls.UI_UP_P)
            {
                bannedXd.offset.x = 0;
                bannedXd.animation.play("move up", true);
            }
            else if (controls.ACCEPT)
            {
                inputBlocked = true;
                bannedXd.offset.x = 0;
                bannedXd.animation.play("close", true);
                FlxTween.tween(scary, {"blurX": 0, "blurY": 0}, 0.13/*, {ease: FlxEase.circInOut}*/); //0.3 with the ease
        
                if (FlxG.sound.music != null)
                {
                    FlxG.sound.music.play();
                    FlxG.sound.music.fadeIn(0.13);
                }
            }
        }
    }
}