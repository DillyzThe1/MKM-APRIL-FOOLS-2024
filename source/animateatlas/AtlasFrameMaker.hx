package animateatlas;

import animateatlas.JSONData.AnimationData;
import animateatlas.JSONData.AtlasData;
import animateatlas.displayobject.SpriteAnimationLibrary;
import animateatlas.displayobject.SpriteMovieClip;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flxanimate.FlxAnimate;
import flxanimate.data.SpriteMapData.AnimateAtlas;
import flxanimate.data.SpriteMapData.AnimateSpriteData;
import flxanimate.data.SpriteMapData.Meta;
import haxe.Json;
import haxe.io.Bytes;
import lime.graphics.Image;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;

using StringTools;

#if desktop
import sys.FileSystem;
import sys.io.File;
#else
import js.html.File;
import js.html.FileSystem;
#end

class AtlasFrameMaker extends FlxFramesCollection
{
	// public static var widthoffset:Int = 0;
	// public static var heightoffset:Int = 0;
	// public static var excludeArray:Array<String>;

	/**

		* Creates Frames from TextureAtlas(very early and broken ok) Originally made for FNF HD by Smokey and Rozebud
		*
		* @param   key                 The file path.
		* @param   _excludeArray       Use this to only create selected animations. Keep null to create all of them.
		*
	 */
	public static function construct(key:String, ?_excludeArray:Array<String> = null, ?noAntialiasing:Bool = false):FlxFramesCollection
	{
		// widthoffset = _widthoffset;
		// heightoffset = _heightoffset;

		var frameCollection:FlxFramesCollection;
		var frameArray:Array<Array<FlxFrame>> = [];

		if (Paths.fileExists('images/$key/spritemap1.json', TEXT))
		{
			outputWarning("Only Spritemaps made with Adobe Animate 2018 are supported");
			return null;
		}

		var animationData:AnimationData = Json.parse(Paths.getTextFromFile('images/$key/Animation.json'));
		var atlasData:AtlasData = Json.parse(Paths.getTextFromFile('images/$key/spritemap.json').replace("\uFEFF", ""));

		var graphic:FlxGraphic = Paths.image('$key/spritemap');
		var ss:SpriteAnimationLibrary = new SpriteAnimationLibrary(animationData, atlasData, graphic.bitmap);
		var t:SpriteMovieClip = ss.createAnimation(noAntialiasing);
		if (_excludeArray == null)
		{
			_excludeArray = t.getFrameLabels();
			// trace('creating all anims');
		}
		trace('Creating: ' + _excludeArray);

		frameCollection = new FlxFramesCollection(graphic, FlxFrameCollectionType.IMAGE);
		for (x in _excludeArray)
		{
			frameArray.push(getFramesArray(t, x));
		}

		for (x in frameArray)
		{
			for (y in x)
			{
				frameCollection.pushFrame(y);
			}
		}
		return frameCollection;
	}

	@:noCompletion static function getFramesArray(t:SpriteMovieClip, animation:String):Array<FlxFrame>
	{
		var sizeInfo:Rectangle = new Rectangle(0, 0);
		t.currentLabel = animation;
		var bitMapArray:Array<BitmapData> = [];
		var daFramez:Array<FlxFrame> = [];
		var firstPass = true;
		var frameSize:FlxPoint = new FlxPoint(0, 0);

		for (i in t.getFrame(animation)...t.numFrames)
		{
			t.currentFrame = i;
			if (t.currentLabel == animation)
			{
				sizeInfo = t.getBounds(t);
				var bitmapShit:BitmapData = new BitmapData(Std.int(sizeInfo.width + sizeInfo.x), Std.int(sizeInfo.height + sizeInfo.y), true, 0);
				bitmapShit.draw(t, null, null, null, null, true);
				bitMapArray.push(bitmapShit);

				if (firstPass)
				{
					frameSize.set(bitmapShit.width, bitmapShit.height);
					firstPass = false;
				}
			}
			else
				break;
		}

		for (i in 0...bitMapArray.length)
		{
			var b = FlxGraphic.fromBitmapData(bitMapArray[i]);
			var theFrame = new FlxFrame(b);
			theFrame.parent = b;
			theFrame.name = animation + i;
			theFrame.sourceSize.set(frameSize.x, frameSize.y);
			theFrame.frame = new FlxRect(0, 0, bitMapArray[i].width, bitMapArray[i].height);
			daFramez.push(theFrame);
			// trace(daFramez);
		}
		return daFramez;
	}

	public static function construct1(key:String, ?_excludeArray:Array<String> = null, ?noAntialiasing:Bool = false):FlxFramesCollection
	{
		var frames:FlxAtlasFrames = new FlxAtlasFrames(null);
		// new FlxAnimate();
		// STOLE FROM flxanimate.frames.FlxAnimateFrames.fromTextureAtlas(key)
		// outputWarning(1);
		/*if (Paths.fileExists('$key/spritemap.json', TEXT))
			{
				var curJson:AnimateAtlas = haxe.Json.parse(StringTools.replace(Paths.getTextFromFile('$key/spritemap.json'), String.fromCharCode(0xFEFF), ""));
				var curSpritemap = Paths.image('$key/${curJson.meta.image}');
				if (curSpritemap != null)
				{
					for (curSprite in curJson.ATLAS.SPRITES)
					{
						frames.pushFrame(textureAtlasHelper(curSpritemap.bitmap, curSprite.SPRITE, curJson.meta));
					}
				}
				else
					outputWarning('the image called "${curJson.meta.image}" does not exist in Path $key, maybe you changed the image Path somewhere else?');
		}*/
		// var i = 1;
		if (Paths.fileExists('images/$key/spritemap1.json', TEXT))
		{
			// outputWarning(2);
			var curJson:AnimateAtlas = haxe.Json.parse(StringTools.replace(Paths.getTextFromFile('images/$key/spritemap1.json'), String.fromCharCode(0xFEFF),
				""));
			var curSpritemap = Paths.image('$key/spritemap1');
			// outputWarning(3);
			if (curSpritemap != null)
			{
				for (curSprite in curJson.ATLAS.SPRITES)
				{
					// outputWarning(curSpritemap.bitmap + "");
					frames.pushFrame(textureAtlasHelper(curSpritemap.bitmap, curSprite.SPRITE, curJson.meta));
				}
			}
			else
				outputWarning('the image called "${curJson.meta.image}" does not exist in Path $key, maybe you changed the image Path somewhere else?');
			// outputWarning(4);
			// i++;
		}
		// outputWarning(5);
		if (frames.frames == [])
		{
			outputWarning("the Frames parsing couldn't parse any of the frames, it's completely empty! \n Maybe you misspelled the Path?");
			return null;
		}
		outputWarning(frames);
		return frames;
		// new flxanimate.frames.FlxAnimateFrames.fromTextureAtlas(key);
	}

	// stolen from flxanimate.frames.FlxAnimateFrames bc screw ur private functions >:(((((((
	public static function textureAtlasHelper(SpriteMap:BitmapData, limb:AnimateSpriteData, curMeta:Meta)
	{
		var width = (limb.rotated) ? limb.h : limb.w;
		var height = (limb.rotated) ? limb.w : limb.h;
		var sprite = new BitmapData(width, height, true, 0);
		var matrix = new FlxMatrix(1, 0, 0, 1, -limb.x, -limb.y);
		if (limb.rotated)
		{
			matrix.rotateByNegative90();
			matrix.translate(0, height);
		}
		sprite.draw(SpriteMap, matrix);
		var ImageSize:FlxPoint = FlxPoint.get(width / Std.parseInt(curMeta.resolution), height / Std.parseInt(curMeta.resolution));

		@:privateAccess
		var curFrame = new FlxFrame(FlxG.bitmap.add(sprite));
		curFrame.name = limb.name;
		curFrame.sourceSize.set(ImageSize.x, ImageSize.y);
		curFrame.frame = new FlxRect(0, 0, width, height);
		return curFrame;
	}

	public static function outputWarning(str:Dynamic)
	{
		trace("w: " + str);
		if (PlayState.instance != null)
			PlayState.instance.addTextToDebug("w: " + str, FlxColor.RED);
	}
}
