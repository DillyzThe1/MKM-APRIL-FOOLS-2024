import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;

typedef LuigiShopItem = {
    var name:String;
    var internalName:String;
    var tip:String;
    var price:Float;
    var picture:String;
    var contradicts:Array<String>;
}

class LSI_Instance {
    public var data:LuigiShopItem;
    public var picture:FlxSprite;
    public var name:Alphabet;

    public function new() {}
}

class LuigiShopState extends MusicBeatState {
    var shopData:Array<LuigiShopItem> = [
        {name: "gtg-inator", internalName: "gtg-inator", tip: "Play as Impostor anywhere... but beware!", price: 49.99, picture: "portraits/wrong-house", contradicts: ["omnisphere"]},
        {name: "Omnipotent Sphere", internalName: "omnisphere", tip: "Play as the Omnipotent Sphere!", price: 499.99, picture: "portraits/none", contradicts: ["gtg-inator"]}
    ];


    var bg:FlxSprite;
    var items:Array<LSI_Instance> = [];
    var tipObj:CaptionObject;

    var curIndex:Int = 0;
    var curIndexOffset:Int = 0;
    var hasSelected:Bool = false;

    public override function create() {
		Mhat.call("menu_shop");

        FlxG.cameras.reset(new FlxCamera());

        bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG-Luigi'));
		bg.scrollFactor.set(0, 0);
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

        tipObj = new CaptionObject("Description");
		add(tipObj);

        for (i in 0...shopData.length) {
            var lsi:LSI_Instance = new LSI_Instance();
            lsi.data = shopData[i];
            lsi.picture = new FlxSprite().loadGraphic(Paths.image(lsi.data.picture));
			lsi.picture.y = (FlxG.height / 2) - (lsi.picture.height / 2) - 75;
			lsi.picture.x = (FlxG.width / 2 + (i * 600)) - (lsi.picture.width / 2);
			lsi.picture.antialiasing = ClientPrefs.globalAntialiasing;
            add(lsi.picture);

			lsi.name = new Alphabet(0, lsi.picture.y + lsi.picture.height + 20, lsi.data.name, true, false);
            add(lsi.name);

            items.push(lsi);
        }

        changeSelection();
    }

    public override function update(e:Float) {

        for (i in 0...items.length) {
			var lerpAmount:Float = e * 114 * (ClientPrefs.framerate / 120);

			if (lerpAmount > 0.99)
				lerpAmount = 0.99;
			if (lerpAmount < 0.01)
				lerpAmount = 0.01;

            items[i].picture.x = FlxMath.lerp((FlxG.width / 2 + ((i - curIndexOffset) * 600)) - (items[i].picture.width / 2), items[i].picture.x, lerpAmount);
			var a:Float = 0;
			for (o in 0...items[i].name.lettersArray.length)
				a += items[i].name.lettersArray[o].width * -0.5 * items[i].name.textSize * items[i].name.lettersArray[o].scale.x;
			items[i].name.x = (items[i].picture.x + items[i].picture.width / 2) + a;
        }

		if (hasSelected)
			return;
        
		if (controls.UI_LEFT_P)
			changeSelection(-1, true);
		if (controls.UI_RIGHT_P)
			changeSelection(1, true);
        if (controls.BACK)
            exitShop();
    }

	function recalcOffset()
	{
        curIndexOffset = curIndex;
		/*curIndexOffset = 0;

		for (i in 0...songs.length)
		{
			if (!songs[i].loadedIn || i >= curIndex)
				continue;
			curIndexOffset++;
		}*/
	}

    function changeSelection(change:Int = 0, ?playSound:Bool = false) {
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curIndex += change;

		if (curIndex < 0)
			curIndex = items.length - 1;
		if (curIndex >= items.length)
			curIndex = 0;

        recalcOffset();

        tipObj.text = items[curIndex].data.tip + (false ? "\n (Disabled, hit ENTER to enable)" : ("\n Price: " + CoolUtil.toMoney(items[curIndex].data.price)));

        for (i in 0...items.length)
        {
            items[i].picture.alpha = (curIndexOffset == i ? 1 : 0.6);
            items[i].name.alpha = (curIndexOffset == i ? 1 : 0.1);
        }
    }

    function exitShop() {
        hasSelected = true;
        MusicBeatState.switchState(new MainMenuState());
    }
}