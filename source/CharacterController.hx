package;

import FunkinLua;

using StringTools;

class CharacterController {
    public var name:String;
    public var sprite:Character;
    //public var playAnimCallback:(controller:CharacterController, name:String, force:Bool) -> Void;

    var curDance:Int = -1;
    public var danceLoop:Array<String> = ['idle'];
    public var danceNumBeats:Int = 2;
    public var skipDance:Bool = false;
    public var specialAnim:Bool = false;
    public var lastPlayerHit:Bool = false;
    public var stunned:Bool = false;

    public var holdTimer:Float = 0;
    public var singDuration:Float = 6;
    public var idleSuffix:String = '';

    public function new(name:String, sprite:Character) {
        this.name = name;
        this.sprite = sprite;
    }

    public function update(elapsed:Float) {
        if (sprite.animation.curAnim != null) {
            if (lastPlayerHit) {
                if (sprite.animation.curAnim.name.startsWith('sing'))
                    holdTimer += elapsed;
                else
                    holdTimer = 0;
    
                if (sprite.animation.curAnim.name.endsWith('miss') && sprite.animation.curAnim.finished)
                    dance(true);
            }

            if (specialAnim && sprite.animation.curAnim.finished)
            {
                specialAnim = false;
                dance();
            }

			if (!lastPlayerHit)
			{
				if (sprite.animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;

				if (holdTimer >= Conductor.stepCrochet * 0.0011 * singDuration)
				{
					dance();
					holdTimer = 0;
				}
			}

			if (sprite.animation.curAnim.finished && sprite.animation.getByName(sprite.animation.curAnim.name + '-loop') != null)
				playAnim(sprite.animation.curAnim.name + '-loop', true);
        }
    }

    public function dance(?force:Bool = false)
    {
        if (!skipDance && !specialAnim)
        {
            curDance++;
            if (curDance >= danceLoop.length)
                curDance = 0;
            playAnim(danceLoop[curDance] + idleSuffix, force);
        }
    }

    public function playAnim(name:String, force:Bool, ?reverse:Bool = false, ?startFrame:Int = 0) {
        if (name == 'singSPACE')
        {
            if (sprite.animOffsets.exists('singHEY'))
                name = 'singHEY';
            else if (sprite.animOffsets.exists('singMIDDLE'))
                name = 'singMIDDLE';
            else if (sprite.animOffsets.exists('singMID'))
                name = 'singMID';
            else
                name = 'singUP';
        }
        specialAnim = false;
        sprite.animation.play(name, force, reverse, startFrame);

        var curOffset = sprite.animOffsets.get(name);
        if (sprite.animOffsets.exists(name))
            sprite.offset.set(curOffset[0], curOffset[1]);
		else if (name.contains('-'))
		{
			var splitThing:Array<String> = name.split('-');
			playAnim(splitThing[0], force, reverse, startFrame);
		}
        else
            sprite.offset.set(0, 0);
    }
}