package;

#if DISCORD_RPC_ALLOWED
import Sys.sleep;
import discord_rpc.DiscordRpc;
#end

using StringTools;

#if LUA_ALLOWED
import llua.Lua;
import llua.State;
#end

class DiscordClient
{
	public static var isInitialized:Bool = false;
	public static var epicPrank:Bool = false;

	public function new()
	{
		#if DISCORD_RPC_ALLOWED
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "940825854626365550",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			if (!epicPrank)
				DiscordRpc.process();
			else
				break;
			sleep(2);
			// trace("Discord Client Update");
		}

		if (!epicPrank)
			DiscordRpc.shutdown();
		#end
	}

	public static function shutdown()
	{
		#if DISCORD_RPC_ALLOWED
		DiscordRpc.shutdown();
		#end
	}

	static function onReady()
	{
		#if DISCORD_RPC_ALLOWED
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "Psych Engine"
		});
		#end
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		#if DISCORD_RPC_ALLOWED
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
		isInitialized = true;
		#end
	}

	private static var largekey:String = 'icon';

	public static var lastDetails:String = "";

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
		#if DISCORD_RPC_ALLOWED
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		lastDetails = details;
		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: largekey,
			largeImageText: "v" + MainMenuState.mushroomKingdomMadnessVersion.trim(),
			smallImageKey: '',
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});

		// trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
		#end
	}

	public static function inMenus()
	{
		#if DISCORD_RPC_ALLOWED
		updateLargeImage(true);
		DiscordClient.changePresence("In the Menus", null);
		#end
	}

	public static function updateLargeImage(?forceIcon:Bool = false)
	{
		#if DISCORD_RPC_ALLOWED
		if (forceIcon || PlayState.instance == null || PlayState.SONG == null || PlayState.SONG.song == null || PlayState.SONG.song == ""
			|| PlayState.instance.endingSong)
		{
			largekey = 'icon';
			trace(largekey);
			return;
		}
		largekey = CoolUtil.shortenSongName(PlayState.SONG.song.toLowerCase().replace(" ", "-"));
		trace(largekey);
		#end
	}

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State)
	{
		Lua_helper.add_callback(lua, "changePresence",
			function(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
			{
				changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp);
			});
	}
	#end
}
