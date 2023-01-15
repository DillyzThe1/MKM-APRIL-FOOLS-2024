package;

import Discord.DiscordClient;
import FreeplayState.SongMetadata;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class ToadFreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var bg:FlxSprite;

	var portraits:Array<FlxSprite> = [];

	override function create()
	{
		// Paths.clearStoredMemory();
		// Paths.clearUnusedMemory();

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		var songsToLoad:Int = 0;
		for (i in 0...WeekData.weeksList.length)
			for (o in 0...WeekData.weeksLoaded.get(WeekData.weeksList[i]).songs.length)
				songsToLoad++;
		var songIn:Int = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				songIn++;
				var colors:Array<Int> = song[2];
				if (colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				var s = addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), song.length >= 4 ? song[3] : false,
					song.length >= 5 ? song[4] : '${song[0].toLowerCase().replace(' ', '-')}-start');

				var gwagwa = 'portraits/${song.length >= 6 ? song[5] : 'null'}';
				trace(gwagwa);
				var portrait:FlxSprite = new FlxSprite().loadGraphic(Paths.image(gwagwa, 'shared'));
				add(portrait);
				portraits.push(portrait);

				portrait.y = (FlxG.height / 2) - (portrait.height / 2);
				portrait.x = (FlxG.width / 2 + ((songIn - 1) * 600)) - (portrait.width / 2);
			}
		}
		WeekData.loadTheFirstEnabledMod();

		/*//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//

			var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
			for (i in 0...initSonglist.length)
			{
				if(initSonglist[i] != null && initSonglist[i].length > 0) {
					var songArray:Array<String> = initSonglist[i].split(":");
					addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
				}
		}*/
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, hideStory:Bool, unlockKey:String)
	{
		var s = new SongMetadata(songName, weekNum, songCharacter, color, hideStory, unlockKey);
		songs.push(s);
		return s;
	}
}
