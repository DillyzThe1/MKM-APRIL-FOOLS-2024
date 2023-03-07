package;

import Song;
import haxe.Json;
import haxe.format.JsonParser;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef StageFile = {
	var directory:String;
	var defaultZoom:Float;
	var isPixelStage:Bool;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;
	var hide_girlfriend:Bool;

	var camera_boyfriend:Array<Float>;
	var camera_opponent:Array<Float>;
	var camera_girlfriend:Array<Float>;
	var camera_speed:Null<Float>;
}

class StageData {
	public static var forceNextDirectory:String = null;
	public static function loadDirectory(SONG:SwagSong) {
		var stage:String = '';
		if(SONG.stage != null)
			stage = SONG.stage;
		else
			stage = 'stage';

		var stageFile:StageFile = getStageFile(stage);
		if(stageFile == null)
			forceNextDirectory = '';
		else
			forceNextDirectory = stageFile.directory;
	}

	public static function getStageFile(stage:String):StageFile {
		var rawJson:String = null;
		var path:String = Paths.getPreloadPath('stages/' + stage + '.json');

		var modPath:String = Paths.modFolders('stages/' + stage + '.json');
		if(FileSystem.exists(modPath))
			rawJson = File.getContent(modPath);
		else if(FileSystem.exists(path))
			rawJson = File.getContent(path);
		else
			return null;
		return cast Json.parse(rawJson);
	}
}