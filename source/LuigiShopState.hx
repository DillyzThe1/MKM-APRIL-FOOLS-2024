import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

typedef LuigiShopItem = {
    var name:String;
    var internalName:String;
    var tip:String;
    var price:Float;
    var picture:String;
}

class LSI_Instance {
    public var data:LuigiShopItem;
    public var picture:FlxSprite;
    public var name:Alphabet;

    public function new() {}
}

class LuigiShopState extends MusicBeatState {
    var shopData:Array<LuigiShopItem> = [
        {name: "Money Multiplier", internalName: "robloxgamepass", tip: "Get up to triple the cash... based on your combo!", price: 249.99, picture: "shop/stonks"},
        {name: "gtg-inator", internalName: "gtg-inator", tip: "Play as Impostor anywhere... but beware!", price: 49.99, picture: "shop/gtg"},
        {name: "Omnipotent Sphere", internalName: "omnisphere", tip: "Play as the Omnipotent Sphere!", price: 499.99, picture: "shop/omnisphere"},
        {name: "Family Guy Full Episodes", internalName: "familyguy", tip: "Play as Peter Griffin... due to our lack of originality!", price: 89.99, picture: "shop/peter"},
        {name: "Dev Tools", internalName: "hacks", tip: "Get access to dev tools! (Shift + 7 & 8 keys)", price: 749.99, picture: "shop/nerd"},
        {name: "free robux", internalName: null, tip: "free robux", price: 19.99, picture: "shop/none"}
    ];

    var contradictionArray:Array<Array<String>> = [["gtg-inator", "omnisphere", "familyguy"]];


    var bg:FlxSprite;
    var balance:FlxText;
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
        bg.alpha = 0;
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

        FlxTween.tween(bg, {alpha: 1}, 1, { ease: FlxEase.cubeInOut });

        balance = new FlxText(0, FlxG.height * 0.025, 0, "Balance: $0.00", 32, true);
        balance.alignment = CENTER;
		balance.scrollFactor.set(0, 0);
        balance.screenCenter(X);
        balance.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 1);
        add(balance);

        tipObj = new CaptionObject("Description");
		add(tipObj);

        for (i in 0...shopData.length) {
            var lsi:LSI_Instance = new LSI_Instance();
            lsi.data = shopData[i];
            lsi.picture = new FlxSprite().loadGraphic(Paths.image(lsi.data.picture));
			lsi.picture.y = (FlxG.height / 2) - (lsi.picture.height / 2) - 75;
			//lsi.picture.x = (FlxG.width / 2 + (i * 600)) - (lsi.picture.width / 2);
            lsi.picture.x = -500;
			lsi.picture.antialiasing = ClientPrefs.globalAntialiasing;
            add(lsi.picture);

			lsi.name = new Alphabet(0, lsi.picture.y + lsi.picture.height + 20, lsi.data.name, true, false);
            add(lsi.name);

            items.push(lsi);
        }

        changeSelection();
    }

    var counter_Money_current:Float = 0;

    public override function update(e:Float) {
        counter_Money_current = FlxMath.lerp(counter_Money_current, ClientPrefs.money, Math.exp(-e * 256));
        balance.text = "Balance: " + CoolUtil.toMoney(counter_Money_current);

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

        #if debug
        if (FlxG.keys.justPressed.ONE) {
            ClientPrefs.money += 100;
            changeSelection();
        }
        if (FlxG.keys.justPressed.R) {
            ClientPrefs.ls_purchase(items[curIndex].data.internalName, false);
            ClientPrefs.ls_enable(items[curIndex].data.internalName, false);
            changeSelection();
        }
        #end
        
		if (controls.UI_LEFT_P)
			changeSelection(-1, true);
		if (controls.UI_RIGHT_P)
			changeSelection(1, true);
        if (controls.BACK)
            exitShop();
        if (controls.ACCEPT) {
            if (ClientPrefs.ls_owned(items[curIndex].data.internalName)) {
                trace("Toggled!");

                for (c in contradictionArray) {
                    if (!c.contains(items[curIndex].data.internalName))
                        continue;

                    trace("Contradictions: " + c);

                    for (i in items)
                        if (i.data.internalName != items[curIndex].data.internalName && c.contains(i.data.internalName))
                            ClientPrefs.ls_enable(i.data.internalName, false);
                }
                

                ClientPrefs.ls_enable(items[curIndex].data.internalName, !ClientPrefs.ls_enabled(items[curIndex].data.internalName));
                ClientPrefs.saveSettings();
                changeSelection();
                return;
            }

            if (ClientPrefs.money < items[curIndex].data.price) {
                trace("Too broke!");
                FlxG.camera.shake(0.01, 0.15);
				FlxG.sound.play(Paths.sound('missnote${FlxG.random.int(1, 3)}', 'shared'));
                return;
            }
            
            trace("Purchased!");
            FlxG.sound.play(Paths.sound('kaching'));
            ClientPrefs.money -= items[curIndex].data.price;
            ClientPrefs.ls_purchase(items[curIndex].data.internalName);
            ClientPrefs.saveSettings();
            changeSelection();
        }
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

        var enableddddd:Bool = ClientPrefs.ls_enabled(items[curIndex].data.internalName);
        tipObj.text = items[curIndex].data.tip + (ClientPrefs.ls_owned(items[curIndex].data.internalName) ? 
            '\n(${!enableddddd ? "Disabled" : "Enabled"}, hit ENTER to ${enableddddd ? 'disable' : 'enable'})'
            : ("\nPrice: " + CoolUtil.toMoney(items[curIndex].data.price)));

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