package options;

using StringTools;

class MKMExtraSettingsSubState extends BaseOptionsMenu
{
    public static var menuThemes:Map<String, MenuSongInfo> = [
        "MKM Menu Theme (Forgotten)" => {name: "MKM Menu Theme (Forgotten)", file: "toadMenu", bpm: 102, loopTime: 0},
        "MKM Menu Theme" => {name: "MKM Menu Theme", file: "toadMenu-full", bpm: 102, loopTime: 0},
        "Baby Menu Theme (Forgotten)" => {name: "Baby Menu Theme (Forgotten)", file: "babyMenu", bpm: 82, loopTime: 0},
        "Baby Menu Theme" => {name: "Baby Menu Theme", file: "babyMenu-full", bpm: 82, loopTime: 0},
        "Danger Bup Ahead!" => {name: "Danger Bup Ahead!", file: "danger-bup-ahead", bpm: 140, loopTime: 0},
        "Playtime Bup Ahead!" => {name: "Playtime Bup Ahead!", file: "playtime-bup-ahead", bpm: 140, loopTime: 0},
        "Feels at Home" => {name: "Feels at Home", file: "feels-at-home", bpm: 105, loopTime: 27420},
    ];

    public static var menuThemes_stupidSwearWordingWorkaround:Array<String> = [
        "MKM Menu Theme (Forgotten)",
        "MKM Menu Theme",
        "Baby Menu Theme (Forgotten)",
        "Baby Menu Theme",
        "Danger Bup Ahead!",
        "Playtime Bup Ahead!",
        "Feels at Home"
    ];

    public static function getMenuTheme_keys() {
        return menuThemes_stupidSwearWordingWorkaround;
    }

	public function new()
	{
		title = 'MKM Extras';
		rpcTitle = 'MKM Extras Menu'; // for Discord Rich Presence

		var option:Option = new Option('Show Money', "Shows your money in-battle.\n(poor taste?)", 'showMoney', 'bool', true);
		addOption(option);

		option = new Option('BGM:', "What should play in the menus?\n(Includes v2.Oh nvm & v1.1 songs)", 'menuBgmType', 'string', "Feels at Home", getMenuTheme_keys());
		addOption(option);
        option.onChange = function() { CoolUtil.playMenuTheme(); };

        if (!CoolUtil.peaceRestored()) {
            option.canChange = false;
            option.description = 'What should play in the menus?\n(Unlocked ONLY after story completion!)';
        }

        super();
    }
}

typedef MenuSongInfo = {
    var name:String;
    var file:String;
    var bpm:Int;
    var loopTime:Float;
}