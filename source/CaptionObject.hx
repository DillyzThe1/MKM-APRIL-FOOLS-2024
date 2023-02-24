package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.display.BitmapData;

class CaptionObject extends FlxSpriteGroup {
    var captionBG:FlxSprite;
    var captionText:FlxText;

    public var text(get, set):String;

    public function new(?textDefault:String = "", ?cams:Array<FlxCamera> = null) {
        super();
        if (cams == null)
            cams = [FlxG.camera];

        captionBG = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
        captionBG.scrollFactor.set(0, 0);
		add(captionBG);

        captionText = new FlxText(FlxG.width/2, FlxG.height * 0.875, 0, "", 32, true);
		captionText.setBorderStyle(OUTLINE, FlxColor.BLACK, 4, 1.15);
		captionText.alignment = CENTER;
        captionText.scrollFactor.set(0, 0);
		add(captionText);

        this.cameras = cams;
        this.text = textDefault;
        this.scrollFactor.set(0, 0);
    }

    @:noCompletion
    public function set_text(?newText:String = "") {
        if (newText == "") {
            captionText.visible = captionBG.visible = false;
            return "";
        }
        captionText.visible = captionBG.visible = true;

        var boundsX:Float = 25;
        var boundsY:Float = 7.5;

        captionText.text = newText;
        captionText.screenCenter(X);

        captionText.y = (FlxG.height * 0.875) + 16;
        captionText.y -= captionText.height/2;

        if (captionText.y + captionText.height > FlxG.height)
            captionText.y = FlxG.height - captionText.height;

        captionBG.makeGraphic(Std.int(captionText.width + boundsX * 2), Std.int(captionText.height + boundsY * 2), FlxColor.BLACK);
        captionBG.setPosition(captionText.x - boundsX, captionText.y - boundsY);
        captionBG.alpha = 0.375;

        // round the texture's rectangle a bit for smoother looks
        if (captionBG.width >= 10 && captionBG.height >= 10 && captionBG.graphic != null && captionBG.graphic.bitmap != null)
        {
            var bmp:BitmapData = captionBG.graphic.bitmap;
            var bmpWidth:Int = bmp.width - 1;
            var bmpHeight:Int = bmp.height - 1;

            // top left corner
            bmp.setPixel32(0, 0, FlxColor.TRANSPARENT);
            bmp.setPixel32(0, 1, FlxColor.TRANSPARENT);
            bmp.setPixel32(1, 0, FlxColor.TRANSPARENT);
            //

            // top right corner
            bmp.setPixel32(bmpWidth, 0, FlxColor.TRANSPARENT);
            bmp.setPixel32(bmpWidth, 1, FlxColor.TRANSPARENT);
            bmp.setPixel32(bmpWidth - 1, 0, FlxColor.TRANSPARENT);
            //

            // bottom left corner
            bmp.setPixel32(0, bmpHeight, FlxColor.TRANSPARENT);
            bmp.setPixel32(0, bmpHeight - 1, FlxColor.TRANSPARENT);
            bmp.setPixel32(1, bmpHeight, FlxColor.TRANSPARENT);
            //

            // bottom right corner
            bmp.setPixel32(bmpWidth, bmpHeight, FlxColor.TRANSPARENT);
            bmp.setPixel32(bmpWidth, bmpHeight - 1, FlxColor.TRANSPARENT);
            bmp.setPixel32(bmpWidth - 1, bmpHeight, FlxColor.TRANSPARENT);
            //
        }

        return captionText.text;
    }

	function get_text():String
		return captionText.text;
}