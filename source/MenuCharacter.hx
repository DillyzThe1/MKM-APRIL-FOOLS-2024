package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

typedef MenuCharacterFile = {
	var image:String;
	var scale:Float;
	var position:Array<Int>;
	var idle_anim:String;
	var confirm_anim:String;
	var flipX:Bool;
}

class MenuCharacter extends FlxSprite
{
	public var character:String;
	public var hasConfirmAnimation:Bool = false;
	private static var DEFAULT_CHARACTER:String = 'bf';

	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		changeCharacter(character);
	}

	public function changeCharacter(?character:String = 'bf') {
		if(character == null) character = '';
		if(character == this.character) return;

		var prevFrame:Int = 0;
		if (this.animation != null && this.animation.curAnim != null)
			prevFrame = this.animation.curAnim.curFrame;

		this.character = character;
		antialiasing = ClientPrefs.globalAntialiasing;
		visible = true;

		var dontPlayAnim:Bool = false;
		scale.set(1, 1);
		updateHitbox();

		hasConfirmAnimation = false;
		switch(character) {
			case '':
				visible = false;
				dontPlayAnim = true;
			default:
				var characterPath:String = 'images/menucharacters/' + character + '.json';
				var rawJson = null;

				var path:String = Paths.modFolders(characterPath);
				if (!FileSystem.exists(path)) {
					path = Paths.getPreloadPath(characterPath);
				}

				if(!FileSystem.exists(path)) {
					path = Paths.getPreloadPath('images/menucharacters/' + DEFAULT_CHARACTER + '.json');
				}
				rawJson = File.getContent(path);
				
				var charFile:MenuCharacterFile = cast Json.parse(rawJson);
				frames = Paths.getSparrowAtlas('menucharacters/' + charFile.image);
				animation.addByPrefix('idle', charFile.idle_anim, 24, false);

				var confirmAnim:String = charFile.confirm_anim;
				if(confirmAnim != null && confirmAnim != charFile.idle_anim)
				{
					animation.addByPrefix('confirm', confirmAnim, 24, false);
					if (animation.getByName('confirm') != null) //check for invalid animation
						hasConfirmAnimation = true;
				}

				flipX = (charFile.flipX == true);

				if(charFile.scale != 1) {
					scale.set(charFile.scale, charFile.scale);
					updateHitbox();
				}
				offset.set(charFile.position[0], charFile.position[1]);
				animation.play('idle', true, false, prevFrame);
		}
	}

	public function dance() {
		animation.play('idle', true);
	}
}
