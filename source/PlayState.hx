package;

import Achievements;
import Conductor.Rating;
import Discord.DiscordClient;
import FunkinLua;
import Note.EventNote;
import Section.SwagSection;
import Song.SwagSong;
import StageData;
import animateatlas.AtlasFrameMaker;
import editors.CharacterEditorState;
import editors.ChartingState;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.events.KeyboardEvent;
import openfl.filters.BitmapFilter;
import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;
import openfl.filters.ShaderFilter;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import shaders.Grain;
import shaders.Hq2x;
import shaders.Scanline;
import shaders.Tiltshift;
import sys.FileSystem;
import sys.io.File;
import vlc.MP4Handler;
import vlc.MP4Handler;

using StringTools;
using StringTools;
#if DISCORD_RPC_ALLOWED
import discord_rpc.DiscordRpc;
#end

#if !flash
import flixel.addons.display.FlxRuntimeShader;
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public var camGameFilters:Array<BitmapFilter> = [];

	public var filterMap:Map<String, {filter:BitmapFilter, ?onUpdate:Void->Void}> = [
		"Scanline" => {
			filter: new ShaderFilter(new shaders.Scanline()),
		},
		"Hq2x" => {
			filter: new ShaderFilter(new shaders.Hq2x()),
		},
		"Tiltshift" => {
			filter: new ShaderFilter(new shaders.Tiltshift()),
		},
		"Grain" => {
			var shader = new shaders.Grain();
			{
				filter: new ShaderFilter(shader),
				onUpdate: function()
				{
					#if (openfl >= "8.0.0")
					shader.uTime.value = [Lib.getTimer() / 1000];
					#else
					shader.uTime = Lib.getTimer() / 1000;
					#end
				}
			}
		},
		"Blur" => {
			filter: new BlurFilter(),
		},
		"ZoomBlur" => {
			filter: new ShaderFilter(new shaders.ZoomBlurShader())
		}
		/*,
			"Grayscale" => {
				var matrix:Array<Float> = [
					0.5, 0.5, 0.5, 0, 0,
					0.5, 0.5, 0.5, 0, 0,
					0.5, 0.5, 0.5, 0, 0,
					  0,   0,   0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			},
			"Invert" => {
				var matrix:Array<Float> = [
					-1,  0,  0, 0, 255,
					 0, -1,  0, 0, 255,
					 0,  0, -1, 0, 255,
					 0,  0,  0, 1,   0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			},
			"Deuteranopia" => {
				var matrix:Array<Float> = [
					0.43, 0.72, -.15, 0, 0,
					0.34, 0.57, 0.09, 0, 0,
					-.02, 0.03,    1, 0, 0,
					   0,    0,    0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			},
			"Protanopia" => {
				var matrix:Array<Float> = [
					0.20, 0.99, -.19, 0, 0,
					0.16, 0.79, 0.04, 0, 0,
					0.01, -.01,    1, 0, 0,
					   0,    0,    0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			},
			"Tritanopia" => {
				var matrix:Array<Float> = [
					0.97, 0.11, -.08, 0, 0,
					0.02, 0.82, 0.16, 0, 0,
					0.06, 0.88, 0.18, 0, 0,
					   0,    0,    0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
		}*/
	];

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], // From 0% to 19%
		['Shit', 0.4], // From 20% to 39%
		['Bad', 0.5], // From 40% to 49%
		['Bruh', 0.6], // From 50% to 59%
		['Meh', 0.69], // From 60% to 68%
		['Nice', 0.7], // 69%
		['Good', 0.8], // From 70% to 79%
		['Great', 0.9], // From 80% to 89%
		['Sick!', 1], // From 90% to 99%
		['Perfect!!', 1] // The value on this one isn't used actually, since Perfect is always "1"
	];

	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	public var modchartCharacterControllers:Map<String, CharacterController> = new Map<String, CharacterController>();

	// event variables
	private var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Character> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	#else
	public var boyfriendMap:Map<String, Character> = new Map<String, Character>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var originallyWantedDiffName:String = "Hard";

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;

	var hasExtra:Bool = false;
	public var songExtra:FlxSound;
	public var vocalsLeft:FlxSound;
	public var vocalsRight:FlxSound;

	public var splitVocals:Bool = false;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Character = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	// Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;

	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;

	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var health_display:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;

	public var healthBar:FlxBar;

	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;

	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;

	public var endingSong:Bool = false;
	public var startingSong:Bool = false;

	private var updateTime:Bool = true;

	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	// Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var camCaptions:FlxCamera;
	public var cameraSpeed:Float = 1;

	var heyTimer:Float;

	var foregroundSprites:FlxTypedGroup<BGSprite>;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;

	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;

	public var songLength:Float = 0;
	public var songDisplayLength:Float = 0;

	public var displayLengthTween:FlxTween;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	var detailsCutsceneText:String = "";

	// Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;

	public var luaArray:Array<FunkinLua> = [];

	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;

	public var introSoundsSuffix:String = '';
	public var introSoundsVolume:Float = 0.6;
	public var countdownImgSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;

	var precacheList:Map<String, String> = new Map<String, String>();

	// extra key
	public static var mania:Int = 0;
	public static var keyCount:Int = 4;

	public var isBrrrrr:Bool = false;
	public var chartEditorThroughBrrrrr:Bool = false;
	var video:MP4Handler;

	public function getKeys()
	{
		var redAngryBirdIsComingToTakeYourWifi:Array<Array<FlxKey>> = [];
		var keyNames:Array<String> = Note.noteManiaSettings[keyCount][keysGonnaSwap ? 9 : 7];
		trace(keyNames);
		for (i in keyNames)
			redAngryBirdIsComingToTakeYourWifi.push(ClientPrefs.copyKey(ClientPrefs.keyBinds.get(i)));
		return redAngryBirdIsComingToTakeYourWifi;
		/*switch (mania)
			{
				default:
					return [
						ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
						ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
						ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
						ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
					];
		}*/
	}

	public function resetLastPlayer() {
		for (control in modchartCharacterControllers)
			control.lastPlayerHit = false;
	}

	public var isSoloMode:Bool = false;
	public var isLeftMode:Bool = false;
	public var doMiddleScroll:Bool = false;
	public var hideOpponentArrows:Bool = false;

	public static var havingAnEpicFail:Bool = false;

	var keysGonnaSwap:Bool = false;

	public static var ogCount:Int = 4;

	var bruhArrowsTween:FlxTween;
	var bruhArrowsTween2:FlxTween;
	var homophobicDog:Float = 0; // screw homophobia lmao
	var transphobicDog:Float = 0; // screw transphobia lmao

	var bruhhhh:Array<String> = [];

	var closedCaptions:CaptionObject;

	public var whatInTheWorldLua:Bool = false;

	function reloadNoteAnimsHeHeHeHa()
	{
		for (i in bruhhhh)
			singAnimations.push('sing${i.toUpperCase()}');
		//	singAnimations.push(i.toUpperCase() == 'SPACE' ? 'singUP' : 'sing${i.toUpperCase()}');
	}

	function desireNote(mustPress:Bool) {
		if (isLeftMode)
			return !mustPress;
		return mustPress;
	}

	public function changeKeyCount(amount:Int)
	{
		if (ogCount != 9)
			return;
		if (bruhArrowsTween != null)
			bruhArrowsTween.cancel();
		if (bruhArrowsTween2 != null)
			bruhArrowsTween2.cancel();
		keysGonnaSwap = true;
		trace('brh!! $amount');
		mania = Note.keyCountToMania(amount);
		keyCount = amount;
		// singAnimations = [];
		if (singAnimations.length != 9)
		{
			bruhhhh = Note.noteManiaSettings[9][6];
			reloadNoteAnimsHeHeHeHa();
		}
		Note.reloadNoteStuffs();
		var c:Array<Int> = Note.noteManiaSettings[keyCount][10];
		keysArray = getKeys();

		trace('192.561.7.12 $singAnimations');

		for (i in unspawnNotes)
			if (i.isSustainNote)
				i.scale.x = Note.noteScale;
			else
				i.scale.x = i.scale.y = Note.noteScale;
		for (i in notes)
			if (i.isSustainNote)
				i.scale.x = Note.noteScale;
			else
				i.scale.x = i.scale.y = Note.noteScale;

		for (player in 0...2)
			for (i in 0...9)
			{
				var truePlayer:Int = isLeftMode ? 1 - player : player;
				var babyArrow = (player == 1 ? playerStrums : opponentStrums).members[i];
				babyArrow.x = doMiddleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X;
				babyArrow.scale.x = babyArrow.scale.y = Note.noteScale;

				if (truePlayer == 0)
				{
					if (doMiddleScroll)
					{
						babyArrow.x += 310;
						if (c[i] >= [0, 0, 1, 1, 2, 2, 3, 3, 4, 4][keyCount])
						{ // Up and Right
							babyArrow.x += FlxG.width / 2 + 25;
						}
					}
				}

				babyArrow.postAddedToGroup(c[i]);
			}

		// for (i in strumLineNotes)
		//	i.angle = 360 * 1.5;
		homophobicDog = 360 * 0.75;
		transphobicDog = Note.noteScale * 1.2;
		bruhArrowsTween = FlxTween.tween(this, {homophobicDog: 0}, 0.5, {
			ease: FlxEase.bounceOut,
			onUpdate: function(t:FlxTween)
			{
				for (i in strumLineNotes)
					i.angle = homophobicDog;
			},
			onComplete: function(t:FlxTween)
			{
				for (i in strumLineNotes)
					i.angle = 0;
			}
		});
		bruhArrowsTween2 = FlxTween.tween(this, {transphobicDog: Note.noteScale}, 0.35, {
			ease: FlxEase.cubeOut,
			onUpdate: function(t:FlxTween)
			{
				for (i in strumLineNotes)
					i.scale.x = i.scale.y = transphobicDog;
			},
			onComplete: function(t:FlxTween)
			{
				for (i in strumLineNotes)
					i.scale.x = i.scale.y = Note.noteScale;
			}
		});
	}

	override public function create()
	{
		Paths.clearStoredMemory();
		Mhat.call("playstate");

		isSoloMode = SONG.soloMode;
		isLeftMode = SONG.leftMode;
		doMiddleScroll = ClientPrefs.middleScroll || isSoloMode;
		hideOpponentArrows = !ClientPrefs.opponentStrums || isSoloMode;

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; // Reset to default

		mania = SONG.mania;
		keyCount = Note.maniaToKeyCount(mania);
		ogCount = keyCount;
		for (event in eventPushedMap.keys())
			if (event == 'Key Count Swap')
			{
				keysGonnaSwap = true;
				keyCount = 9;
			}
		singAnimations = [];
		bruhhhh = Note.noteManiaSettings[keyCount][6];
		reloadNoteAnimsHeHeHeHa();
		Note.reloadNoteStuffs();
		PauseSubState.parentalControls_vals = PauseSubState.parentalControls_vals_default.copy();

		keysArray = getKeys();

		// Ratings
		ratingsData.push(new Rating('sick')); // default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camCaptions = new FlxCamera();
		camHUD.bgColor.alpha = camOther.bgColor.alpha = camCaptions.bgColor.alpha = 0;

		// getting around DCE
		camHUD.alpha = camGame.alpha = camOther.alpha = camCaptions.alpha = 1;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.add(camCaptions, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		CustomFadeTransition.nextCamera = camCaptions;
		// FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null) {
			PlayState.storyDifficulty = CoolUtil.loadSongDiffs('tutorial');
			SONG = Song.loadFromJson('tutorial');
		}

		Mhat.call("song_" + SONG.song);

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		detailsCutsceneText = "In Cutscene - " + detailsText;

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);
		var mario:String = SONG.audioPostfix;

		if ((FileSystem.exists('assets/songs/$songName/Voices$mario-left') || FileSystem.exists('mkm_content/songs/$songName/Voices$mario-left'))
			&& (FileSystem.exists('assets/songs/$songName/Voices$mario-right') || FileSystem.exists('mkm_content/songs/$songName/Voices$mario-right')))
			splitVocals = true;

		trace('split vocals? $splitVocals...');

		curStage = SONG.stage;
		// trace('stage is: ' + curStage);
		if (SONG.stage == null || SONG.stage.length < 1)
			curStage = 'stage';
		SONG.stage = curStage;

		Mhat.call("bg_" + curStage);

		var stageData:StageFile = StageData.getStageFile(curStage);
		if (stageData == null)
		{ // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if (stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if (boyfriendCameraOffset == null) // Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if (opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if (girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage': // Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if (!ClientPrefs.lowQuality)
				{
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
		}

		add(gfGroup); // Needed for blammed lights

		add(dadGroup);
		add(boyfriendGroup);

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if (Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for (mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));

		for (folder in foldersToCheck)
		{
			if (FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if (file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		// STAGE SCRIPTS
		#if (LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if (FileSystem.exists(Paths.modFolders(luaFile)))
		{
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		}
		else
		{
			luaFile = Paths.getPreloadPath(luaFile);
			if (FileSystem.exists(luaFile))
			{
				doPush = true;
			}
		}

		if (doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		var gfVersion:String = SONG.gfVersion;
		if (gfVersion == null || gfVersion.length < 1)
		{
			SONG.gfVersion = gfVersion = 'gf';
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Character(0, 0, SONG.player1, true);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		dad.isPlayer = isLeftMode;
		boyfriend.isPlayer = !isLeftMode;
		if (isLeftMode)
			trace('EPIC LEFT MODE SET THINGS');

		Note.oppositeMode = isLeftMode;

		dad.onPlayAnim = function(name:String, force:Bool, reversed:Bool, frame:Int) {
			callOnLuas("onPlayAnim", ["dad", name, force, reversed, frame]);
		};

		if (gf != null)
			gf.onPlayAnim = function(name:String, force:Bool, reversed:Bool, frame:Int) {
				callOnLuas("onPlayAnim", ["gf", name, force, reversed, frame]);
			};

		boyfriend.onPlayAnim = function(name:String, force:Bool, reversed:Bool, frame:Int) {
			callOnLuas("onPlayAnim", ["boyfriend", name, force, reversed, frame]);
		};

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if (gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if (dad.curCharacter.startsWith('gf'))
		{
			dad.setPosition(GF_X, GF_Y);
			if (gf != null)
				gf.visible = false;
		}

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(doMiddleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if (ClientPrefs.downScroll)
			strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if (ClientPrefs.downScroll)
			timeTxt.y = FlxG.height - 44;

		if (ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if (ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if (FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if (FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		for (event in eventPushedMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if (FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if (FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if (ClientPrefs.downScroll)
			healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health_display', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "CINEMATIC MODE", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if (ClientPrefs.downScroll)
		{
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if (Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for (mod in Paths.getGlobalMods())
			foldersToCheck.insert(0,
				Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) +
					'/')); // using push instead of insert because these should run after everything else

		for (folder in foldersToCheck)
		{
			if (FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if (file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			startCountdown();
			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}
		RecalculateRating();

		// PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if (ClientPrefs.hitsoundVolume > 0)
			precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null)
		{
			precacheList.set(PauseSubState.songName, 'music');
		}
		else if (ClientPrefs.pauseMusic != 'None')
		{
			precacheList.set(Paths.formatToSongPath('Betwixt The Chaos'), 'music');
		}

		// Updating Discord Rich Presence.
		DiscordClient.updateLargeImage(false);
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());

		if (!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		FlxG.camera.setFilters(camGameFilters);
		FlxG.camera.filtersEnabled = true;

		camGame.angle = camHUD.angle = 0;

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;
		callOnLuas('onCreatePost', []);

		super.create();

		Paths.clearUnusedMemory();

		for (key => type in precacheList)
		{
			// trace('Key $key is type $type');
			switch (type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		CustomFadeTransition.nextCamera = camCaptions;

		closedCaptions = new CaptionObject("", [camCaptions]);
		closedCaptions.animate = true;
		add(closedCaptions);
	}

	function set_songSpeed(value:Float):Float
	{
		if (generatedMusic)
		{
			var ratio:Float = value / songSpeed; // funny word huh
			for (note in notes)
				note.resizeByRatio(ratio);
			for (note in unspawnNotes)
				note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor)
	{
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText)
		{
			spr.y += 20;
		});

		if (luaDebugGroup.members.length > 34)
		{
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors()
	{
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int)
	{
		switch (type)
		{
			case 0:
				if (!boyfriendMap.exists(newCharacter))
				{
					var newBoyfriend:Character = new Character(0, 0, newCharacter, true);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if (!dadMap.exists(newCharacter))
				{
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if (gf != null && !gfMap.exists(newCharacter))
				{
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	public function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		if (FileSystem.exists(Paths.modFolders(luaFile)))
		{
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		}
		else
		{
			luaFile = Paths.getPreloadPath(luaFile);
			if (FileSystem.exists(luaFile))
			{
				doPush = true;
			}
		}

		if (doPush)
		{
			for (script in luaArray)
			{
				if (script.scriptName == luaFile)
					return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool = true, control:Bool = true):FlxSprite
	{
		if (modchartSprites.exists(tag))
			return modchartSprites.get(tag);
		if (text && modchartTexts.exists(tag))
			return modchartTexts.get(tag);
		if (control && modchartCharacterControllers.exists(tag))
			return modchartCharacterControllers.get(tag).sprite;
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false)
	{
		if (gfCheck && char.curCharacter.startsWith('gf'))
		{ // IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;
		if (name == "brrrrr-hard")
			isBrrrrr = true;
		trace(name);
		trace(isBrrrrr);

		var filepath:String = Paths.video(name);
		if (!FileSystem.exists(filepath))
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		video = new MP4Handler(ClientPrefs.seenCutscene(name));
		ClientPrefs.finishCutscene(name);
		video.readyCallback = function() {
			trace('the video\'s all loaded up!');
			video.volume = 1;
			@:privateAccess
			video.libvlc.setVolume(1);
			@:privateAccess
			video.libvlc.setTime(0);
			@:privateAccess
			video.libvlc.setRepeat(0);
		}

		video.volume = 0;
		video.playVideo(filepath, true);

		video.finishCallback = function()
		{
			if (!chartEditorThroughBrrrrr)
				startAndEnd();
			return;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if (endingSong)
			endSong();
		else
			startCountdown();
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	public static var startOnTime:Float = 0;

	public function showCountdownPiece(piece:Int, ?sound:Bool = false, ?discord:Bool = false) {
		var antialias:Bool = ClientPrefs.globalAntialiasing;
		switch (piece)
		{
			case 0:
				if (sound)
					FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), introSoundsVolume);
				if (discord)
					DiscordClient.changePresence("3 - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			case 1:
				var countdownReady:FlxSprite = new FlxSprite().loadGraphic(Paths.image('countdown/ready' + countdownImgSuffix));
				countdownReady.cameras = [camOther];
				countdownReady.scrollFactor.set();
				countdownReady.updateHitbox();

				countdownReady.screenCenter();
				countdownReady.antialiasing = antialias;
				insert(members.indexOf(notes), countdownReady);
				FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						remove(countdownReady);
						countdownReady.destroy();
					}
				});
				if (sound)
					FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), introSoundsVolume);
				if (discord)
					DiscordClient.changePresence("2 - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			case 2:
				var countdownSet:FlxSprite = new FlxSprite().loadGraphic(Paths.image('countdown/set' + countdownImgSuffix));
				countdownSet.cameras = [camOther];
				countdownSet.scrollFactor.set();

				countdownSet.screenCenter();
				countdownSet.antialiasing = antialias;
				insert(members.indexOf(notes), countdownSet);
				FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						remove(countdownSet);
						countdownSet.destroy();
					}
				});
				if (sound)
					FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), introSoundsVolume);
				if (discord)
					DiscordClient.changePresence("1 - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			case 3:
				var countdownGo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('countdown/go' + countdownImgSuffix));
				countdownGo.cameras = [camOther];
				countdownGo.scrollFactor.set();

				countdownGo.updateHitbox();

				countdownGo.screenCenter();
				countdownGo.antialiasing = antialias;
				insert(members.indexOf(notes), countdownGo);
				FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						remove(countdownGo);
						countdownGo.destroy();
					}
				});
				if (sound)
					FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), introSoundsVolume);
				if (discord)
					DiscordClient.changePresence("Go! - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		callOnLuas('onCountdownTick', [piece]);
	}

	public function startCountdown():Void
	{
		if (startedCountdown)
		{
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', [], false);
		if (ret != FunkinLua.Function_Stop)
		{
			if (skipCountdown || startOnTime > 0)
				skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length)
			{
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length)
			{
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				// if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if (startOnTime < 0)
				startOnTime = 0;

			if (startOnTime > 0)
			{
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return;
			}

			ClientPrefs.setKeyUnlocked('${SONG.song}-start', true);
			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (gf != null
					&& tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
					&& gf.animation.curAnim != null
					&& !gf.animation.curAnim.name.startsWith("sing")
					&& !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0
					&& boyfriend.animation.curAnim != null
					&& !boyfriend.animation.curAnim.name.startsWith('sing')
					&& !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0
					&& dad.animation.curAnim != null
					&& !dad.animation.curAnim.name.startsWith('sing')
					&& !dad.stunned)
				{
					dad.dance();
				}

				for (control in modchartCharacterControllers) {
					if (tmr.loopsLeft % control.danceNumBeats == 0
						&& control.sprite.animation.curAnim != null
						&& !control.sprite.animation.curAnim.name.startsWith('sing')
						&& !control.stunned)
					{
						control.dance();
					}
				}

				showCountdownPiece(swagCounter, true, true);

				notes.forEachAlive(function(note:Note)
				{
					if (!hideOpponentArrows || desireNote(note.mustPress))
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if (doMiddleScroll && !desireNote(note.mustPress))
						{
							note.alpha *= 0.35;
						}
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}

	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}

	public function addBehindDad(obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = unspawnNotes[i];
			if (daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = notes.members[i];
			if (daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		scoreTxt.text = 'Score: '
			+ songScore
			+ ' | Misses: '
			+ songMisses
			+ ' | Rating: '
			+ ratingName
			+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');

		if (ClientPrefs.scoreZoom && !miss && !cpuControlled)
		{
			if (scoreTxtTween != null)
			{
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween)
				{
					scoreTxtTween = null;
				}
			});
		}
	}

	public function setSongTime(time:Float)
	{
		if (time < 0)
			time = 0;

		FlxG.sound.music.pause();
		if (splitVocals)
		{
			vocalsLeft.pause();
			vocalsRight.pause();
		}
		else
			vocals.pause();
		songExtra.pause();


		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		if (splitVocals && (Conductor.songPosition <= vocalsLeft.length))
		{
			vocalsLeft.time = time;
			vocalsRight.time = time;
		}
		else if ((!splitVocals && (Conductor.songPosition <= vocals.length)))
			vocals.time = time;
		if (splitVocals)
		{
			vocalsLeft.play();
			vocalsRight.play();
		}
		else
			vocals.play();
		if (Conductor.songPosition <= songExtra.length)
			songExtra.time = time;
		songExtra.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		//FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song, PlayState.SONG.audioPostfix), 1, false);
		
		FlxG.sound.music.play(true, 0);
		FlxG.sound.music.volume = 1;
		FlxG.sound.music.onComplete = onSongComplete;
		if (splitVocals)
		{
			vocalsLeft.play();
			vocalsRight.play();
		}
		else
			vocals.play();
		songExtra.volume = 1;
		songExtra.play();

		if (startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if (paused)
		{
			// trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			if (splitVocals)
			{
				vocalsLeft.pause();
				vocalsRight.pause();
			}
			else
				vocals.pause();
			songExtra.pause();
		}

		// Song duration in a float, useful for the time left feature
		songDisplayLength = songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);

		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype', 'multiplicative');

		switch (songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (splitVocals)
		{
			if (SONG.needsVoices)
			{
				vocalsLeft = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, PlayState.SONG.audioPostfix, "-left", dad.singParam));
				vocalsRight = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, PlayState.SONG.audioPostfix, "-right", boyfriend.singParam));
			}
			else
			{
				vocalsLeft = new FlxSound();
				vocalsRight = new FlxSound();
			}
		}
		else
		{
			if (SONG.needsVoices)
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, PlayState.SONG.audioPostfix));
			else
				vocals = new FlxSound();
		}

		if (splitVocals)
		{
			FlxG.sound.list.add(vocalsLeft);
			FlxG.sound.list.add(vocalsRight);
		}
		else
			FlxG.sound.list.add(vocals);

		if (Paths.fileExists('songs/${Paths.formatToSongPath(PlayState.SONG.song)}/Extra${PlayState.SONG.audioPostfix}.ogg', AssetType.SOUND)) {
			hasExtra = true;
			songExtra = new FlxSound().loadEmbedded(Paths.songExtra(PlayState.SONG.song, PlayState.SONG.audioPostfix));
		}
		else
			songExtra = new FlxSound();
		FlxG.sound.list.add(songExtra);
		FlxG.sound.music.loadEmbedded(Paths.inst(PlayState.SONG.song, PlayState.SONG.audioPostfix));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file))
		{
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) // Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % keyCount);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > keyCount - 1)
				{
					gottaHitNote = !section.mustHitSection;
				}
				var oldNote:Note;

				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);

				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1] < keyCount));
				swagNote.noteType = songNotes[3];
				if (!Std.isOfType(songNotes[3], String))
					swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; // Backward compatibility + compatibility with Week 7 charts
				swagNote.scrollFactor.set();
				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);
				var floorSus:Int = Math.floor(susLength);

				if (floorSus > 0)
				{
					for (susNote in 0...floorSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						var sustainNote:Note = new Note(daStrumTime
							+ (Conductor.stepCrochet * susNote)
							+ (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData,
							oldNote, true);

						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1] < keyCount));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if (doMiddleScroll)
						{
							sustainNote.x += 310;
							if (daNoteData > 1) // Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}
				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if (doMiddleScroll)
				{
					swagNote.x += 310;
					if (daNoteData > 1) // Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}
				if (!noteTypeMap.exists(swagNote.noteType))
				{
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) // Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}
		// trace(unspawnNotes.length);
		// playerCounter += 1;
		unspawnNotes.sort(sortByShit);
		if (eventNotes.length > 1)
		{ // No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote)
	{
		switch (event.event)
		{
			case 'Change Character':
				var charType:Int = 0;
				switch (event.value1.toLowerCase())
				{
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
		}

		if (!eventPushedMap.exists(event.event))
		{
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float
	{
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if (returnedValue != 0)
		{
			return returnedValue;
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; // for lua

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...keyCount)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if ((player < 1 && !isLeftMode) || (player >= 1 && isLeftMode))
			{
				if (hideOpponentArrows)
					targetAlpha = 0;
				else if (doMiddleScroll)
					targetAlpha = 0.35;
			}

			trace('wtf the middle scroll is ${doMiddleScroll}');

			var basePlace:Float = doMiddleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X;
			// basePlace += (Note.noteManiaSettings[4][1]) * 2;
			// basePlace -= (Note.noteManiaSettings[keyCount][1]) * (keyCount / 2);

			var truePlayer:Int = isLeftMode ? 1 - player : player;
			var babyArrow:StrumNote = new StrumNote(basePlace, strumLine.y, i, doMiddleScroll ? truePlayer : player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				// babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (truePlayer == 1)
			{
				(isLeftMode ? opponentStrums : playerStrums).add(babyArrow);
			}
			else
			{
				if (doMiddleScroll)
				{
					babyArrow.x += 310;
					if (i >= keyCount / 2)
					{ // Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				(!isLeftMode ? opponentStrums : playerStrums).add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}

		if (keysGonnaSwap)
			changeKeyCount(ogCount);

		callOnLuas('onGenerateStaticArrows', [player, 1]);
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				if (splitVocals)
				{
					vocalsLeft.pause();
					vocalsRight.pause();
				}
				else
					vocals.pause();
				songExtra.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars)
			{
				if (char != null && char.colorTween != null)
				{
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens)
			{
				tween.active = false;
			}
			for (timer in modchartTimers)
			{
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars)
			{
				if (char != null && char.colorTween != null)
				{
					char.colorTween.active = true;
				}
			}

			for (tween in modchartTweens)
			{
				tween.active = true;
			}
			for (timer in modchartTimers)
			{
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song
					+ " ("
					+ storyDifficultyText
					+ ")", iconP2.getCharacter(), true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
			}
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song
					+ " ("
					+ storyDifficultyText
					+ ")", iconP2.getCharacter(), true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (health > 0 && !paused)
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (finishTimer != null)
			return;

		if (splitVocals)
		{
			vocalsLeft.pause();
			vocalsRight.pause();
		}
		else
			vocals.pause();
		songExtra.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		if (splitVocals)
		{
			if (Conductor.songPosition <= vocalsLeft.length)
			{
				vocalsLeft.time = Conductor.songPosition;
				vocalsRight.time = Conductor.songPosition;
			}
			vocalsLeft.play();
			vocalsRight.play();
		}
		else
		{
			if (Conductor.songPosition <= vocals.length)
			{
				vocals.time = Conductor.songPosition;
			}
			vocals.play();
		}
		if (Conductor.songPosition <= songExtra.length)
			songExtra.time = Conductor.songPosition;
		songExtra.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;

	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		callOnLuas('onUpdate', [elapsed]);

		for (i in filterMap)
			if (i.onUpdate != null)
				i.onUpdate();

		if (!inCutscene)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if (!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle'))
			{
				boyfriendIdleTime += elapsed;
				if (boyfriendIdleTime >= 0.15)
				{ // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			}
			else
			{
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		for (control in modchartCharacterControllers)
			control.update(elapsed);

		if (PauseSubState.parentalControls_vals[1])
		{
			health += elapsed * 0.2;
			if (health > 2)
				health = 2;
		}

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		if (botplayTxt.visible)
		{
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause && !CoolUtil.fredMode)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if (ret != FunkinLua.Function_Stop)
			{
				openPauseMenu();
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && (!inCutscene || isBrrrrr) && !CoolUtil.fredMode)
		{
			if (isBrrrrr)
				chartEditorThroughBrrrrr = true;
			if (video != null && video.isPlaying)
			{
				video.stop();
				video.dispose();
				video.visible = false;
			}
				
			openChartEditor();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			+ (150 * iconP1.scale.x - 150) / 2
			- iconOffset;
		iconP2.x = healthBar.x
			+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01))
			- (150 * iconP2.scale.x) / 2
			- iconOffset * 2;

		if (health > 2)
			health = 2;
		if (health < 0)
			health = 0;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		#if !desktop
		var iconP3:FlxSprite = null;
		iconP3.makeGraphic(100, 100, FlxColor.WHITE);
		#end

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene && !CoolUtil.fredMode)
		{
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if (updateTime)
				{
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if (curTime < 0)
						curTime = 0;
					songPercent = (curTime / songDisplayLength);

					var songCalc:Float = (songDisplayLength - curTime);
					if (ClientPrefs.timeBarType == 'Time Elapsed')
						songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if (secondsTotal < 0)
						secondsTotal = 0;

					if (ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if (songSpeed < 1)
				time /= songSpeed;
			if (unspawnNotes[0].multSpeed < 1)
				time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned = true;
				callOnLuas('onSpawnNote', [
					notes.members.indexOf(dunceNote),
					dunceNote.noteData,
					dunceNote.noteType,
					dunceNote.isSustainNote
				]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if (!inCutscene)
			{
				if (!cpuControlled)
				{
					keyShit();
				}
				else if ((isLeftMode ? dad : boyfriend).holdTimer > Conductor.stepCrochet * 0.0011 * (isLeftMode ? dad : boyfriend).singDuration
					&& (isLeftMode ? dad : boyfriend).animation.curAnim.name.startsWith('sing')
					&& !(isLeftMode ? dad : boyfriend).animation.curAnim.name.endsWith('miss'))
				{
					(isLeftMode ? dad : boyfriend).dance();
					// boyfriend.animation.curAnim.finish();
				}

				for (control in modchartCharacterControllers) {
					if (control.holdTimer > Conductor.stepCrochet * 0.0011 * control.singDuration
						&& control.sprite.animation.curAnim.name.startsWith('sing')
						&& !control.sprite.animation.curAnim.name.endsWith('miss'))
					{
						control.dance();
					}
				}
			}

			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if (!daNote.mustPress)
					strumGroup = opponentStrums;

				var strumHeight:Float = strumGroup.members[daNote.noteData].height;
				var strumX:Float = strumGroup.members[daNote.noteData].x;
				var strumY:Float = strumGroup.members[daNote.noteData].y;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;

				if (strumScroll) // Downscroll
				{
					// daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
				}
				else // Upscroll
				{
					// daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
				}

				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle)
					daNote.angle = strumDirection - 90 + strumAngle;

				if (daNote.copyAlpha)
					daNote.alpha = strumAlpha;

				if (daNote.copyX)
					daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

				if (daNote.copyY)
				{
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

					// Jesus fuck this took me so much mother fucking time AAAAAAAAAA
					if (strumScroll && daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end'))
						{
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
							daNote.y -= 19;
						}
						daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
					}
				}

				if (!desireNote(daNote.mustPress) && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					opponentNoteHit(daNote);
				}

				if (PauseSubState.parentalControls_vals[0] && desireNote(daNote.mustPress) && cpuControlled)
				{
					if (daNote.isSustainNote)
					{
						if (daNote.canBeHit)
						{
							goodNoteHit(daNote);
						}
					}
					else if (daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && desireNote(daNote.mustPress)))
					{
						goodNoteHit(daNote);
					}
				}

				var center:Float = strumY + Note.swagWidth / 2;
				if (strumGroup.members[daNote.noteData].sustainReduce
					&& daNote.isSustainNote
					&& (desireNote(daNote.mustPress) || !daNote.ignoreNote)
					&& (!desireNote(daNote.mustPress) || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					if (strumScroll)
					{
						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				var epicMult:Float = ClientPrefs.downScroll ? -1 : 1;
				if (daNote != null
					&& daNote.animation != null
					&& daNote.animation.curAnim != null
					&& daNote.animation.curAnim.name.endsWith('end')
					&& daNote.prevNote != null
					&& daNote.prevNote.scale != null
					&& daNote.prevNote.isSustainNote)
					daNote.y = daNote.prevNote.y + (daNote.prevNote.height * epicMult);
				

				if (daNote.isSustainNote)  {
					daNote.y += 15 * epicMult;
					var limitttt:Float = strumY + strumHeight/2;
					if ((!ClientPrefs.downScroll && daNote.y <= limitttt) || (ClientPrefs.downScroll && daNote.y >= limitttt))
						daNote.visible = false;
				}
				

				// Kill extremely late notes and cause misses
				if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
				{
					if (desireNote(daNote.mustPress) && !cpuControlled && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
					{
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();

		#if debug
		if (!endingSong && !startingSong)
		{
			if (FlxG.keys.justPressed.ONE)
			{
				KillNotes();
				FlxG.sound.music.onComplete();
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			if (FlxG.keys.justPressed.TWO)
			{ // Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);

				DiscordClient.changePresence(detailsText, SONG.song
					+ " ("
					+ storyDifficultyText
					+ ")", iconP2.getCharacter(), true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
			}
			if (FlxG.keys.justPressed.G && SONG.song.toLowerCase() == "wrong house")
				callOnLuas('gtg', []);
		}
		#end

		if (whatInTheWorldLua && vocalsLeft.volume > 0)
			vocalsLeft.volume = 0;

		camHUD.visible = PauseSubState.parentalControls_vals[3] && !cpuControlled;
		botplayTxt.visible = false;

		if (Main.fpsVar != null) {
			Main.fpsVar.showFps = !cpuControlled;
			Main.fpsVar.showMemory = Main.fpsVar.showFps && (CoolUtil.difficultyString().toLowerCase() != "alpha");
		}

		if (inCutscene && DiscordClient.lastDetails != detailsCutsceneText)
			DiscordClient.changePresence(detailsCutsceneText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());

		health_display = (SONG.soloMode || SONG.leftMode) ? 2 - health : health;
		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				cancelMusicFadeTween();
				MusicBeatState.switchState(new GitarooPause());
			}
			else { */
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			if (splitVocals)
			{
				vocalsLeft.pause();
				vocalsRight.pause();
			}
			else
				vocals.pause();
			songExtra.pause();
		}
		openSubState(new PauseSubState((isLeftMode ? dad : boyfriend).getScreenPosition().x, (isLeftMode ? dad : boyfriend).getScreenPosition().y));
		// }

		DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
	}

	var squareChecks:Array<String> = ['house', 'brrrrr', 'chaotically-stupid', 'bup'];

	function chartKeyFormat(songName:String)
		return songName.toLowerCase().replace(" ", "-") + "-chart";

	function shouldGoToSquare()
	{
		for (i in squareChecks)
			if (!ClientPrefs.getKeyUnlocked(chartKeyFormat(i)))
				return false;
		return true;
	}

	function openChartEditor(?force:Bool = false)
	{
		var fsong:String = SONG.song.toLowerCase().replace(" ", "-");
		var chsong:String = chartKeyFormat(SONG.song);
		var hasDoneThisBefore:Bool = ClientPrefs.getKeyUnlocked(chsong);
		if (squareChecks.contains(fsong) && !hasDoneThisBefore)
		{
			FlxG.sound.play(Paths.sound("chart_activated", "shared"), 0.875).persist = true;
			ClientPrefs.setKeyUnlocked(chsong, true);

			if (shouldGoToSquare()) {
				persistentUpdate = false;
				paused = true;
				cancelMusicFadeTween();
				CoolUtil.loadFreeplaySong("3the1point5extras", "Square");
				return;
			}
		}
		else
			FlxG.sound.play(Paths.sound("chart_ok", "shared"), 0.65).persist = true;

		#if debug
		var ret:Dynamic;

		if (!FlxG.keys.pressed.SHIFT && !force)
			ret = callOnLuas('onChartAccessed', [], false);
		else
			ret = FunkinLua.Function_Continue;

		if (ret != FunkinLua.Function_Stop)
		{
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			ChartingState.leftSingParam = dad.singParam;
			ChartingState.rightSingParam = boyfriend.singParam;
			MusicBeatState.switchState(new ChartingState());
			chartingMode = true;
			DiscordClient.changePresence("Chart Editor", null, null, true);
		}
		#else
		callOnLuas('onChartAccessed', [], false);
		#end
	}

	public var isDead:Bool = false; // Don't mess with this on Lua!!!

	function doDeathCheck(?skipHealthCheck:Bool = false)
	{
		if (PauseSubState.parentalControls_vals[5])
			return false;

		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			if (CoolUtil.fredMode) {
				CoolUtil.loadFreeplaySong(CoolUtil.fredCrossoverWeekName, "Karrd Kollision");
				return true;
			}
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if (ret != FunkinLua.Function_Stop)
			{
				(isLeftMode ? dad : boyfriend).stunned = true;
				deathCounter++;

				paused = true;

				if (splitVocals)
				{
					vocalsLeft.stop();
					vocalsRight.stop();
				}
				else
					vocals.stop();
				FlxG.sound.music.stop();
				songExtra.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens)
				{
					tween.active = true;
				}
				for (timer in modchartTimers)
				{
					timer.active = true;
				}
				openSubState(new GameOverSubstate((isLeftMode ? dad : boyfriend).getScreenPosition().x - (isLeftMode ? dad : boyfriend).positionArray[0],
				(isLeftMode ? dad : boyfriend).getScreenPosition().y - (isLeftMode ? dad : boyfriend).positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote()
	{
		while (eventNotes.length > 0)
		{
			var leStrumTime:Float = eventNotes[0].strumTime;
			if (Conductor.songPosition < leStrumTime)
			{
				break;
			}

			var value1:String = '';
			if (eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if (eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String)
	{
		var pressed:Bool = Reflect.getProperty(controls, key);
		// trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String)
	{
		switch (eventName)
		{
			case 'Hey!':
				var value:Int = 2;
				switch (value1.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if (Math.isNaN(time) || time <= 0)
					time = 0.6;

				if (value != 0)
				{
					if (gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					} 
					else if (gf.animOffsets.exists('hey')) {
						gf.playAnim('hey', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if (value != 1)
				{
					if (boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = time;
					} 
					else if (boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = time;
					}
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if (Math.isNaN(value) || value < 1)
					value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if (ClientPrefs.camZooms && FlxG.camera.zoom < 1.35)
				{
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if (Math.isNaN(camZoom))
						camZoom = 0.015;
					if (Math.isNaN(hudZoom))
						hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Play Animation':
				// trace('Anim to play: ' + value1);
				for (control in modchartCharacterControllers) {
					if (control.sprite.singParam.toLowerCase().trim() == value2.toLowerCase().trim()) {
						control.playAnim(value1, true);
						control.specialAnim = true;
						break;
					}
				}

				var char:Character = dad;
				var controlThing:String = 'left';
				switch (value2.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend':
						char = boyfriend;
						controlThing = 'right';
					case 'gf' | 'girlfriend':
						char = gf;
						controlThing = 'mid';
					default:
						var val2:Int = Std.parseInt(value2);
						if (Math.isNaN(val2))
							val2 = 0;

						switch (val2)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				for (control in modchartCharacterControllers) {
					if (control.sprite.singParam.toLowerCase().trim() == controlThing) {
						control.playAnim(value1, true);
						control.specialAnim = true;
						break;
					}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 0;
				if (Math.isNaN(val2))
					val2 = 0;

				isCameraOnForcedPos = false;
				if (!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2)))
				{
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch (value1.toLowerCase())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if (Math.isNaN(val))
							val = 0;

						switch (val)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length)
				{
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if (split[0] != null)
						duration = Std.parseFloat(split[0].trim());
					if (split[1] != null)
						intensity = Std.parseFloat(split[1].trim());
					if (Math.isNaN(duration))
						duration = 0;
					if (Math.isNaN(intensity))
						intensity = 0;

					if (duration > 0 && intensity != 0)
					{
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'Change Character':
				var charType:Int = 0;
				switch (value1)
				{
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				switch (charType)
				{
					case 0:
						if (boyfriend.curCharacter != value2)
						{
							if (!boyfriendMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							boyfriend.isPlayer = !isLeftMode;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if (dad.curCharacter != value2)
						{
							if (!dadMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if (!dad.curCharacter.startsWith('gf'))
							{
								if (wasGf && gf != null)
								{
									gf.visible = true;
								}
							}
							else if (gf != null)
							{
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							dad.isPlayer = isLeftMode;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if (gf != null)
						{
							if (gf.curCharacter != value2)
							{
								if (!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 1;
				if (Math.isNaN(val2))
					val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if (val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if (killMe.length > 1)
				{
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length - 1], value2);
				}
				else
				{
					FunkinLua.setVarInArray(this, value1, value2);
				}

			case 'Key Count Swap':
				changeKeyCount(Std.parseInt(value1));
			case 'Closed Captions':
				closedCaptions.text = value1;
			case 'Show Countdown Index':
				showCountdownPiece(Std.parseInt(value1), (value2 == "true" || value2 == "t" || value2 == "1" || value2 == "yes" || value2 == "y"));
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void
	{
		if (SONG.notes[curSection] == null)
			return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;

	public function moveCamera(isDad:Bool)
	{
		if (isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {
					ease: FlxEase.elasticInOut,
					onComplete: function(twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn()
	{
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3)
		{
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {
				ease: FlxEase.elasticInOut,
				onComplete: function(twn:FlxTween)
				{
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float)
	{
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	// Any way to do this without using a different function? kinda dumb
	private function onSongComplete()
	{
		finishSong(false);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; // In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		if (splitVocals)
		{
			vocalsLeft.volume = 0;
			vocalsRight.volume = 0;
			vocalsLeft.pause();
			vocalsRight.pause();
		}
		else
		{
			vocals.volume = 0;
			vocals.pause();
		}
		songExtra.volume = 0;
		songExtra.pause();
		
		if (ClientPrefs.noteOffset <= 0 || ignoreNoteOffset)
		{
			finishCallback();
		}
		else
		{
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer)
			{
				finishCallback();
			});
		}
	}

	public var transitioning = false;

	public function endSong():Void
	{
		if (CoolUtil.fredMode) {
			CoolUtil.loadFreeplaySong(CoolUtil.fredCrossoverWeekName, "Karrd Kollision");
			return;
		}

		// Should kill you if you tried to cheat
		if (!startingSong)
		{
			notes.forEach(function(daNote:Note)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.05 * healthLoss;
				}
			}

			if (doDeathCheck())
			{
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if (achievementObj != null)
		{
			return;
		}
		else
		{
			var achieve:String = checkForAchievement([
				'weekmushroom', 'weekmushroom_nomiss',
				'ur_bad', 'ur_good', 'hype',
				'two_keys', 'toastie', 'debugger'
			]);

			if (achieve != null)
			{
				startAchievement(achieve);
				return;
			}
		}
		#end

		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		if (ret != FunkinLua.Function_Stop && !transitioning)
		{
			ClientPrefs.setKeyUnlocked('${SONG.song}-end', true);

			if (SONG.validScore)
			{
				var percent:Float = ratingPercent;
				if (Math.isNaN(percent))
					percent = 0;
				if (songScore < 10)
					songScore = 10;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
			}

			if (chartingMode)
			{
				openChartEditor(true);
				return;
			}

			if (CoolUtil.babyMode() && SONG.song.toLowerCase() == "jhonny")
			{
				cancelMusicFadeTween();
				if (FlxTransitionableState.skipNextTransIn)
					CustomFadeTransition.nextCamera = null;
				changedDifficulty = false;
				transitioning = true;
				CoolUtil.toggleBabyMode(false);
				return;
			}

			trace(SONG.song.toLowerCase() + " " + havingAnEpicFail);
			if (SONG.song.toLowerCase() == "no way" && havingAnEpicFail)
			{
				PlayState.storyDifficulty = CoolUtil.loadSongDiffs("Bup", "Alpha");
				var songLowercase:String = Paths.formatToSongPath("Bup");
				PlayState.SONG = Song.loadFromJson(Highscore.formatSong(songLowercase, PlayState.storyDifficulty), songLowercase);
				LoadingState.loadAndSwitchState(new PlayState());
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					CoolUtil.playMenuTheme();

					cancelMusicFadeTween();
					if (FlxTransitionableState.skipNextTransIn)
					{
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if (!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false))
					{
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					PlayState.storyDifficulty = CoolUtil.loadSongDiffs(PlayState.storyPlaylist[0], originallyWantedDiffName);
					var difficulty:String = CoolUtil.getDifficultyFilePath();
					var nextSong = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);

					// trace('LOADING NEXT SONG');
					// trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					var nextSongGonnaSuck:Bool = originallyWantedDiffName.toLowerCase() == "hard" && nextSong.mania != 0;
					var bruhFunction = function(theSong:SwagSong)
					{
						PlayState.SONG = theSong;
						FlxG.sound.music.stop();
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					};
					if (nextSongGonnaSuck)
						openSubState(new PlayStateManiaOptionSubState(bruhFunction));
					else
						bruhFunction(nextSong);
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				cancelMusicFadeTween();
				if (FlxTransitionableState.skipNextTransIn)
				{
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				CoolUtil.playMenuTheme();
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;

	function startAchievement(achieve:String)
	{
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}

	function achievementEnd():Void
	{
		achievementObj = null;
		if (endingSong && !inCutscene)
		{
			endSong();
		}
	}
	#end

	public function KillNotes()
	{
		while (notes.length > 0)
		{
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;
	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	var addedRating:Bool = true;
	var rating:FlxSprite;
	var ratingtween:FlxTween;
	var lastratingpath:String = "";

	var comboamtstuff:Array<FlxSprite> = [];
	var combotweenstuff:Array<FlxTween> = [];

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		// trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		(splitVocals ? (isLeftMode ? vocalsLeft : vocalsRight) : vocals).volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		if (!ClientPrefs.simpleRatingPopup || rating == null) {
			addedRating = false;
			rating = new FlxSprite();
		}
		rating.alpha = 1;
		var score:Int = 350;

		if (ClientPrefs.simpleRatingPopup && ratingtween != null) {
			ratingtween.cancel();
			ratingtween.destroy();
		}

		if (ClientPrefs.simpleRatingPopup) {
			for (i in 0...combotweenstuff.length) {
				var tweeeen:FlxTween = combotweenstuff[i];

				if (tweeeen != null) {
					tweeeen.cancel();
					tweeeen.destroy();
				}
			}
		}

		// tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff);
		var ratingNum:Int = 0;

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if (!note.ratingDisabled)
			daRating.increase();
		note.rating = daRating.name;

		if (daRating.noteSplash && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if (!practiceMode && !cpuControlled)
		{
			songScore += score;
			if (!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		if (ClientPrefs.hideHud || !showRating)
			return;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		var newratingpath:String = pixelShitPart1 + daRating.image + pixelShitPart2;

		if (!ClientPrefs.simpleRatingPopup || newratingpath != lastratingpath) {
			rating.loadGraphic(Paths.image(newratingpath));
			lastratingpath = newratingpath;
		}
		rating.cameras = [camHUD];
		if (!ClientPrefs.simpleRatingPopup)
		{
			rating.screenCenter();
			rating.x = coolText.x - 40;
			rating.y -= 60;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			rating.x += ClientPrefs.comboOffset[0];
			rating.y -= ClientPrefs.comboOffset[1];
		}
		else {
			rating.x = FlxG.width - 180 - ((rating.width/2) * 0.7);
			rating.y = FlxG.height - 200 - ((rating.height/2) * 0.7);
		}

		if (addedRating)
			remove(rating);
		insert(members.indexOf(strumLineNotes), rating);

		rating.scale.x = rating.scale.y = 0.7;
		rating.antialiasing = ClientPrefs.globalAntialiasing;

		var seperatedScore:Array<Int> = [];

		if (combo >= 1000)
		{
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
		{
			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.cameras = [camHUD];
			comboSpr.screenCenter();
			comboSpr.x = coolText.x;
			comboSpr.acceleration.y = FlxG.random.int(200, 300);
			comboSpr.velocity.y -= FlxG.random.int(140, 160);
			comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
			comboSpr.x += ClientPrefs.comboOffset[0];
			comboSpr.y -= ClientPrefs.comboOffset[1];
			comboSpr.y += 60;
			comboSpr.velocity.x += FlxG.random.int(1, 10);

			comboSpr.scale.x = comboSpr.scale.y = 0.7;
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.updateHitbox();

			if (!addedRating)
				insert(members.indexOf(strumLineNotes), comboSpr);

			comboSpr.x = xThing + 50;
			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					comboSpr.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});
		}
		if (showComboNum)
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite();
				var addedNumScore:Bool = false;

				if (!ClientPrefs.simpleRatingPopup)
					numScore = new FlxSprite();
				else if (comboamtstuff.length <= daLoop)
				{
					numScore = new FlxSprite();
					comboamtstuff.push(numScore);
				}
				else {
					addedNumScore = true;
					numScore = comboamtstuff[daLoop];
					numScore.alpha = 1;
				}

				numScore.loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.cameras = [camHUD];
				numScore.screenCenter();
				
				if (!ClientPrefs.simpleRatingPopup) {
					numScore.x = coolText.x + (43 * daLoop) - 90;
					numScore.y += 80;

					numScore.x += ClientPrefs.comboOffset[2];
					numScore.y -= ClientPrefs.comboOffset[3];

					numScore.acceleration.y = FlxG.random.int(200, 300);
					numScore.velocity.y -= FlxG.random.int(140, 160);
					numScore.velocity.x = FlxG.random.float(-5, 5);
				}
				else {
					var numwdth:Float = numScore.width * 0.5;
					numScore.x = (rating.x + rating.width * rating.scale.x) - (numwdth * (seperatedScore.length - daLoop));
					numScore.y = rating.y + (rating.height * rating.scale.y) - 25;
				}
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.scale.x = numScore.scale.y = 0.5;

				// if (combo >= 10 || combo == 0)
				if (addedNumScore)
					remove(numScore);
				insert(members.indexOf(strumLineNotes), numScore);

				var oldnuscore:FlxSprite = numScore;
				combotweenstuff.push(FlxTween.tween(oldnuscore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						if (!ClientPrefs.simpleRatingPopup)
							oldnuscore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				}));

				daLoop++;
				if (numScore.x > xThing)
					xThing = numScore.x;
			}
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		var oldrating:FlxSprite = rating;
		ratingtween = FlxTween.tween(oldrating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001,
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				if (!ClientPrefs.simpleRatingPopup)
					oldrating.destroy();
			},
		});

		addedRating = true;
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		if (!PauseSubState.parentalControls_vals[0])
			return;

		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		// trace('Pressed: ' + eventKey);

		if (!cpuControlled
			&& startedCountdown
			&& !paused
			&& key > -1
			&& (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if (!(isLeftMode ? dad : boyfriend).stunned && generatedMusic && !endingSong)
			{
				// more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				// var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && desireNote(daNote.mustPress) && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if (daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							// notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0)
				{
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes)
						{
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1)
							{
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							}
							else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped)
						{
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}
					}
				}
				else
				{
					callOnLuas('onGhostTap', [key]);
					if (canMiss)
					{
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario

				// can you guys just discuss this over something normal and not a series of comments
				//                                  - DillyzThe1
				keysPressed[key] = true;

				// more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = (isLeftMode ? opponentStrums : playerStrums).members[key];
			if (spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		// trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if (!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = (isLeftMode ? opponentStrums : playerStrums).members[key];
			if (spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		// trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		/*var up = controls.NOTE_UP;
			var right = controls.NOTE_RIGHT;
			var down = controls.NOTE_DOWN;
			var left = controls.NOTE_LEFT; */
		var allArrays:Array<Array<Bool>> = [
			// this programming is sponsored by raid shadow legends
			[],
			[controls.NOTE_SPACE_9K],
			[controls.NOTE_LEFT, controls.NOTE_RIGHT],
			[controls.NOTE_LEFT, controls.NOTE_SPACE_9K, controls.NOTE_RIGHT],
			[controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT],
			[
				controls.NOTE_LEFT,
				controls.NOTE_DOWN,
				controls.NOTE_SPACE_9K,
				controls.NOTE_UP,
				controls.NOTE_RIGHT
			],
			[
				controls.NOTE_LEFT_6K,
				controls.NOTE_UP_6K,
				controls.NOTE_RIGHT_6K,
				controls.NOTE_LEFT2_6K,
				controls.NOTE_DOWN_6K,
				controls.NOTE_RIGHT2_6K
			],
			[
				controls.NOTE_LEFT_6K,
				controls.NOTE_UP_6K,
				controls.NOTE_RIGHT_6K,
				controls.NOTE_SPACE_9K,
				controls.NOTE_LEFT2_6K,
				controls.NOTE_DOWN_6K,
				controls.NOTE_RIGHT2_6K
			],
			[
				controls.NOTE_LEFT_9K,
				controls.NOTE_DOWN_9K,
				controls.NOTE_UP_9K,
				controls.NOTE_RIGHT_9K,
				controls.NOTE_LEFT2_9K,
				controls.NOTE_DOWN2_9K,
				controls.NOTE_UP2_9K,
				controls.NOTE_RIGHT2_9K
			],
			[
				controls.NOTE_LEFT_9K,
				controls.NOTE_DOWN_9K,
				controls.NOTE_UP_9K,
				controls.NOTE_RIGHT_9K,
				controls.NOTE_SPACE_9K,
				controls.NOTE_LEFT2_9K,
				controls.NOTE_DOWN2_9K,
				controls.NOTE_UP2_9K,
				controls.NOTE_RIGHT2_9K
			]
		];
		var allArrays_P:Array<Array<Bool>> = [
			// this programming is sponsored by raid shadow legends
			[],
			[controls.NOTE_SPACEP_9K],
			[controls.NOTE_LEFT_P, controls.NOTE_RIGHT_P],
			[controls.NOTE_LEFT_P, controls.NOTE_SPACEP_9K, controls.NOTE_RIGHT_P],
			[
				controls.NOTE_LEFT_P,
				controls.NOTE_DOWN_P,
				controls.NOTE_UP_P,
				controls.NOTE_RIGHT_P
			],
			[
				controls.NOTE_LEFT_P,
				controls.NOTE_DOWN_P,
				controls.NOTE_SPACEP_9K,
				controls.NOTE_UP_P,
				controls.NOTE_RIGHT_P
			],
			[
				controls.NOTE_LEFTP_6K,
				controls.NOTE_UPP_6K,
				controls.NOTE_RIGHTP_6K,
				controls.NOTE_LEFT2P_6K,
				controls.NOTE_DOWNP_6K,
				controls.NOTE_RIGHT2P_6K
			],
			[
				controls.NOTE_LEFTP_6K,
				controls.NOTE_UPP_6K,
				controls.NOTE_RIGHTP_6K,
				controls.NOTE_SPACEP_9K,
				controls.NOTE_LEFT2P_6K,
				controls.NOTE_DOWNP_6K,
				controls.NOTE_RIGHT2P_6K
			],
			[
				controls.NOTE_LEFTP_9K,
				controls.NOTE_DOWNP_9K,
				controls.NOTE_UPP_9K,
				controls.NOTE_RIGHTP_9K,
				controls.NOTE_LEFT2P_9K,
				controls.NOTE_DOWN2P_9K,
				controls.NOTE_UP2P_9K,
				controls.NOTE_RIGHT2P_9K
			],
			[
				controls.NOTE_LEFTP_9K,
				controls.NOTE_DOWNP_9K,
				controls.NOTE_UPP_9K,
				controls.NOTE_RIGHTP_9K,
				controls.NOTE_SPACEP_9K,
				controls.NOTE_LEFT2P_9K,
				controls.NOTE_DOWN2P_9K,
				controls.NOTE_UP2P_9K,
				controls.NOTE_RIGHT2P_9K
			]
		];
		var allArrays_R:Array<Array<Bool>> = [
			// this programming is sponsored by raid shadow legends
			[],
			[controls.NOTE_SPACER_9K],
			[controls.NOTE_LEFT_R, controls.NOTE_RIGHT_R],
			[controls.NOTE_LEFT_R, controls.NOTE_SPACER_9K, controls.NOTE_RIGHT_R],
			[
				controls.NOTE_LEFT_R,
				controls.NOTE_DOWN_R,
				controls.NOTE_UP_R,
				controls.NOTE_RIGHT_R
			],
			[
				controls.NOTE_LEFT_R,
				controls.NOTE_DOWN_R,
				controls.NOTE_SPACER_9K,
				controls.NOTE_UP_R,
				controls.NOTE_RIGHT_R
			],
			[
				controls.NOTE_LEFTR_6K,
				controls.NOTE_UPR_6K,
				controls.NOTE_RIGHTR_6K,
				controls.NOTE_LEFT2R_6K,
				controls.NOTE_DOWNR_6K,
				controls.NOTE_RIGHT2R_6K
			],
			[
				controls.NOTE_LEFTR_6K,
				controls.NOTE_UPR_6K,
				controls.NOTE_RIGHTR_6K,
				controls.NOTE_SPACER_9K,
				controls.NOTE_LEFT2R_6K,
				controls.NOTE_DOWNR_6K,
				controls.NOTE_RIGHT2R_6K
			],
			[
				controls.NOTE_LEFTR_9K,
				controls.NOTE_DOWNR_9K,
				controls.NOTE_UPR_9K,
				controls.NOTE_RIGHTR_9K,
				controls.NOTE_LEFT2R_9K,
				controls.NOTE_DOWN2R_9K,
				controls.NOTE_UP2R_9K,
				controls.NOTE_RIGHT2R_9K
			],
			[
				controls.NOTE_LEFTR_9K,
				controls.NOTE_DOWNR_9K,
				controls.NOTE_UPR_9K,
				controls.NOTE_RIGHTR_9K,
				controls.NOTE_SPACER_9K,
				controls.NOTE_LEFT2R_9K,
				controls.NOTE_DOWN2R_9K,
				controls.NOTE_UP2R_9K,
				controls.NOTE_RIGHT2R_9K
			]
		];

		var swapHoldArrays:Array<Array<Bool>> = [
			// this programming is sponsored by raid shadow legends
			[false, false, false, false, false, false, false, false, false],
			[false, false, false, false, controls.NOTE_SPACE_9K, false, false, false, false,],
			[
				controls.NOTE_LEFT,
				false,
				false,
				controls.NOTE_RIGHT,
				false,
				false,
				false,
				false,
				false
			],
			[
				controls.NOTE_LEFT,
				false,
				false,
				controls.NOTE_RIGHT,
				controls.NOTE_SPACE_9K,
				false,
				false,
				false,
				false
			],
			[
				controls.NOTE_LEFT,
				controls.NOTE_DOWN,
				controls.NOTE_UP,
				controls.NOTE_RIGHT,
				false,
				false,
				false,
				false,
				false
			],
			[
				controls.NOTE_LEFT,
				controls.NOTE_DOWN,
				controls.NOTE_UP,
				controls.NOTE_RIGHT,

				controls.NOTE_SPACE_9K,
				false,
				false,
				false,
				false
			],
			[
				controls.NOTE_LEFT_6K,
				controls.NOTE_DOWN_6K,
				controls.NOTE_UP_6K,
				controls.NOTE_RIGHT_6K,
				false,
				controls.NOTE_LEFT2_6K,
				false,
				false,
				controls.NOTE_RIGHT2_6K
			],
			[
				controls.NOTE_LEFT_6K,
				controls.NOTE_DOWN_6K,
				controls.NOTE_UP_6K,
				controls.NOTE_RIGHT_6K,
				controls.NOTE_SPACE_9K,
				controls.NOTE_LEFT2_6K,
				false,
				false,
				controls.NOTE_RIGHT2_6K
			],
			[
				controls.NOTE_LEFT_9K,
				controls.NOTE_DOWN_9K,
				controls.NOTE_UP_9K,
				controls.NOTE_RIGHT_9K,
				false,
				controls.NOTE_LEFT2_9K,
				controls.NOTE_DOWN2_9K,
				controls.NOTE_UP2_9K,
				controls.NOTE_RIGHT2_9K
			],
			[
				controls.NOTE_LEFT_9K,
				controls.NOTE_DOWN_9K,
				controls.NOTE_UP_9K,
				controls.NOTE_RIGHT_9K,
				controls.NOTE_SPACE_9K,
				controls.NOTE_LEFT2_9K,
				controls.NOTE_DOWN2_9K,
				controls.NOTE_UP2_9K,
				controls.NOTE_RIGHT2_9K
			]
		];

		var controlHoldArray:Array<Bool> = keysGonnaSwap ? swapHoldArrays[keyCount] : allArrays[keyCount];

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = allArrays_P[ogCount];
			if (controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if (controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !(isLeftMode ? dad : boyfriend).stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit && desireNote(daNote.mustPress) && !daNote.tooLate && !daNote.wasGoodHit)
				{
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong)
			{
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null)
				{
					startAchievement(achieve);
				}
				#end
			}
			else if ((isLeftMode ? dad : boyfriend).holdTimer > Conductor.stepCrochet * 0.0011 * (isLeftMode ? dad : boyfriend).singDuration
				&& (isLeftMode ? dad : boyfriend).animation.curAnim.name.startsWith('sing')
				&& !(isLeftMode ? dad : boyfriend).animation.curAnim.name.endsWith('miss'))
			{
				(isLeftMode ? dad : boyfriend).dance();
				// boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = allArrays_R[ogCount];
			if (controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if (controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function noteMiss(daNote:Note):Void
	{ 
		// prevent missing notes you can't hit
		if (daNote != null && Note.noteManiaSettings[PlayState.keyCount].length > 10) {
			var intsofalltime:Array<Int> = Note.noteManiaSettings[PlayState.keyCount][10];
			if (!daNote.isSustainNote)
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.7, 0.9));
			if (intsofalltime != null && intsofalltime[daNote.noteData % intsofalltime.length] == -1) {
				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
				return;
			}
		}

		// You didn't hit the key and let it go offscreen, also used by Hurt Notes
		// Dupe note remove
		notes.forEachAlive(function(note:Note)
		{
			if (daNote != note
				&& desireNote(daNote.mustPress)
				&& daNote.noteData == note.noteData
				&& daNote.isSustainNote == note.isSustainNote
				&& Math.abs(daNote.strumTime - note.strumTime) < 1)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		
		if (daNote.missPenalty) {
			combo = 0;
			health -= daNote.missHealth * healthLoss;

			if (instakillOnMiss)
			{
				if (splitVocals)
				{
					vocalsLeft.volume = 0;
					vocalsRight.volume = 0;
				}
				else
					vocals.volume = 0;
				doDeathCheck(true);
			}

			// For testing purposes
			// trace(daNote.missHealth);
			songMisses++;
			if (PauseSubState.parentalControls_vals[6])
			{
				(splitVocals ? (isLeftMode ? vocalsLeft : vocalsRight) : vocals).volume = 0;
			}
			if (!practiceMode)
				songScore -= 10;

			totalPlayed++;
			RecalculateRating(true);
		}

		resetLastPlayer();
		var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
		if (daNote.characterController != null) {
			for (control in modchartCharacterControllers) {
				if (control.sprite.singParam.toLowerCase().trim() == daNote.characterController.toLowerCase().trim())
					control.playAnim(animToPlay, true);
			}
		}
		else {
			var char:Character = isLeftMode ? dad : boyfriend;
			var awesomeThing:String = isLeftMode ? 'left' : 'right';
			if (daNote.gfNote) {
				char = gf;
				awesomeThing = 'mid';
			}

			if (char != null && !daNote.noMissAnimation && char.hasMissAnimations)
				char.playAnim(animToPlay, true);

			for (control in modchartCharacterControllers) {
				if (control.sprite.singParam.toLowerCase().trim() == awesomeThing)
					control.playAnim(animToPlay, true);
			}
		}

		if (daNote.missPenalty) {
			callOnLuas('noteMiss', [
				notes.members.indexOf(daNote),
				daNote.noteData,
				daNote.noteType,
				daNote.isSustainNote
			]);
		}
	}

	function noteMissPress(direction:Int = 1):Void // You pressed a key when there was no notes to press for this key
	{
		if (!PauseSubState.parentalControls_vals[0])
			return;

		if (ClientPrefs.ghostTapping)
			return; // fuck it

		if (!(isLeftMode ? dad : boyfriend).stunned)
		{
			health -= 0.05 * healthLoss;
			if (instakillOnMiss)
			{
				if (splitVocals)
				{
					vocalsLeft.volume = 0;
					vocalsRight.volume = 0;
				}
				else
					vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if (!practiceMode)
				songScore -= 10;
			if (!endingSong)
			{
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.7, 0.9));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

				// get stunned for 1/60 of a second, makes you able to
				new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
				{
					boyfriend.stunned = false;
			});*/

			if ((isLeftMode ? dad : boyfriend).hasMissAnimations)
			{
				(isLeftMode ? dad : boyfriend).playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			if (PauseSubState.parentalControls_vals[6])
			{
				(splitVocals ? (isLeftMode ? vocalsLeft : vocalsRight) : vocals).volume = 0;
			}
		}
		callOnLuas('noteMissPress', [direction]);
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if (note.noteType == 'Hey!')
		{
			if (note.characterController != null) {
				for (control in modchartCharacterControllers) {
					if (control.sprite.singParam.toLowerCase().trim() == note.characterController.toLowerCase().trim()) {
						control.playAnim('hey', true);
						control.specialAnim = true;
					}
				}
			}
			else if (dad.animOffsets.exists('hey')) {
				dad.playAnim('hey', true);
				dad.specialAnim = true;
				dad.heyTimer = 0.6;

				for (control in modchartCharacterControllers) {
					if (control.sprite.singParam.toLowerCase().trim() == 'left') {
						control.playAnim('hey', true);
						control.specialAnim = true;
					}
				}
			}
		}
		else if (!note.noAnimation)
		{
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection)
				{
					altAnim = '-alt';
				}
			}

			var char:Character = isLeftMode ? boyfriend : dad;
			var awesomeController:String = isLeftMode ? 'right' : 'left';
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;

			if (note.characterController != null) {
				for (control in modchartCharacterControllers) {
					if (control.sprite.singParam.toLowerCase().trim() == note.characterController.toLowerCase().trim()) {
						control.playAnim(animToPlay, true);
						control.holdTimer = 0;
					}
				}
			}
			else {
				if (note.gfNote) {
					char = gf;
					awesomeController = 'mid';
				}

				if (char != null)
				{
					char.playAnim(animToPlay, true);
					char.holdTimer = 0;
				}

				for (control in modchartCharacterControllers) {
					if (control.sprite.singParam.toLowerCase().trim() == awesomeController) {
						control.playAnim(animToPlay, true);
						control.holdTimer = 0;
					}
				}
			}
		}

		if (SONG.needsVoices)
		{
			(splitVocals ? (!isLeftMode ? vocalsLeft : vocalsRight) : vocals).volume = 1;
		}

		var time:Float = 0.15;
		if (note.isSustainNote && note.animation.curAnim != null && !note.animation.curAnim.name.endsWith('end'))
		{
			time += 0.15;
		}
		StrumPlayAnim(!isLeftMode, Std.int(Math.abs(note.noteData)) % PlayState.ogCount, time, note);
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [
			notes.members.indexOf(note),
			Math.abs(note.noteData),
			note.noteType,
			note.isSustainNote
		]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	#if (!flash)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();

	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if (!ClientPrefs.shaders)
			return new FlxRuntimeShader();

		if (!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if (!ClientPrefs.shaders)
			return false;

		if (runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if (Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for (mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));

		for (folder in foldersToCheck)
		{
			if (FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if (FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else
					frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else
					vert = null;

				if (found)
				{
					runtimeShaders.set(name, [frag, vert]);
					// trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function goodNoteHit(note:Note):Void
	{
		if (!PauseSubState.parentalControls_vals[0])
			return;

		resetLastPlayer();
		if (!note.wasGoodHit)
		{
			if (cpuControlled && (note.ignoreNote || note.hitCausesMiss))
				return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if (note.hitCausesMiss)
			{
				noteMiss(note);
				if (!note.noteSplashDisabled && !note.isSustainNote)
				{
					spawnNoteSplashOnNote(note);
				}

				if (!note.noMissAnimation)
				{
					switch (note.noteType)
					{
						case 'Hurt Note': // Hurt note
							if (note.characterController != null) {
								for (control in modchartCharacterControllers) {
									if (control.sprite.singParam.toLowerCase().trim() == note.characterController.toLowerCase().trim()
										&& control.sprite.animation.getByName('hurt') != null) {
										control.playAnim('hurt', true);
										control.specialAnim = true;
										control.lastPlayerHit = true;
									}
								}
							}
							else {
								if ((isLeftMode ? dad : boyfriend).animation.getByName('hurt') != null)
								{
									(isLeftMode ? dad : boyfriend).playAnim('hurt', true);
									(isLeftMode ? dad : boyfriend).specialAnim = true;
								}

								for (control in modchartCharacterControllers) {
									if (control.sprite.singParam.toLowerCase().trim() == (isLeftMode ? 'left' : 'right')
										&& control.sprite.animation.getByName('hurt') != null) {
										control.playAnim('hurt', true);
										control.specialAnim = true;
										control.lastPlayerHit = true;
									}
								}
							}
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				if (combo > 9999)
					combo = 9999;
				popUpScore(note);
			}
			health += note.hitHealth * healthGain;

			if (!note.noAnimation)
			{
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if (note.characterController != null) {
					for (control in modchartCharacterControllers) {
						if (control.sprite.singParam.toLowerCase().trim() == note.characterController.toLowerCase().trim()) {
							control.playAnim(animToPlay + note.animSuffix, true);
							control.holdTimer = 0;
							control.lastPlayerHit = true;
						}
					}
				}
				else {
					if (note.gfNote)
					{
						if (gf != null)
						{
							gf.playAnim(animToPlay + note.animSuffix, true);
							gf.holdTimer = 0;
						}
					}
					else
					{
						(isLeftMode ? dad : boyfriend).playAnim(animToPlay + note.animSuffix, true);
						(isLeftMode ? dad : boyfriend).holdTimer = 0;
					}

					for (control in modchartCharacterControllers) {
						if (control.sprite.singParam.toLowerCase().trim() == (note.gfNote ? 'mid' : (isLeftMode ? 'left' : 'right'))) {
							control.playAnim(animToPlay + note.animSuffix, true);
							control.holdTimer = 0;
							control.lastPlayerHit = true;
						}
					}
				}

				if (note.noteType == 'Hey!')
				{
					if (note.characterController != null) {
						for (control in modchartCharacterControllers) {
							if (control.sprite.singParam.toLowerCase().trim() == note.characterController.toLowerCase().trim()
								&& control.sprite.animOffsets.exists('hey')) {
								control.playAnim('hey', true);
								control.specialAnim = true;
							}
						}
					}
					else {
						if ((isLeftMode ? dad : boyfriend).animOffsets.exists('hey'))
						{
							(isLeftMode ? dad : boyfriend).playAnim('hey', true);
							(isLeftMode ? dad : boyfriend).specialAnim = true;
							(isLeftMode ? dad : boyfriend).heyTimer = 0.6;
						}

						for (control in modchartCharacterControllers) {
							if (control.sprite.singParam.toLowerCase().trim() == (isLeftMode ? 'left' : 'right')
								&& control.sprite.animOffsets.exists('hey')) {
								control.playAnim('hey', true);
								control.specialAnim = true;
							}
						}
					}

					if (!isLeftMode && gf != null && gf.animOffsets.exists('cheer'))
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if (cpuControlled)
			{
				var time:Float = 0.15;
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					time += 0.15;
				}
				StrumPlayAnim(isLeftMode, Std.int(Math.abs(note.noteData)) % PlayState.ogCount, time, note);
			}
			else
			{
				(isLeftMode ? opponentStrums : playerStrums).forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			(splitVocals ? (!isLeftMode ? vocalsLeft : vocalsRight) : vocals).volume = 1;

			var isSus:Bool = note.isSustainNote; // GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note)
	{
		if (ClientPrefs.noteSplashes && note != null)
		{
			var strum:StrumNote = (isLeftMode ? opponentStrums : playerStrums).members[note.noteData];
			if (strum != null)
			{
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null)
	{
		var skin:String = 'noteSplashes';
		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
			skin = PlayState.SONG.splashSkin;

		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if (note != null)
		{
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		//var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		var splash:NoteSplash = null;

		if (!ClientPrefs.simpleNoteSplash) {
			splash = grpNoteSplashes.recycle(NoteSplash);
			splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
			grpNoteSplashes.add(splash);
			return;
		}
		for (i in grpNoteSplashes) {
			if (i.prevNote != data)
				continue;
			splash = i;
			splash.revive();
			splash.visible = true;
			break;
		}
		if (splash == null) {
			splash = grpNoteSplashes.recycle(NoteSplash);
			splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
			grpNoteSplashes.add(splash);
			return;
		}
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
	}

	override function destroy()
	{
		Mhat.call("playstate_end");
		Mhat.call("song_" + SONG.song + "_end");
		Mhat.call("bg_" + curStage + "_remove");
		lime.app.Application.current.window.title = "': Mushroom Kingdom Madness";
		for (lua in luaArray)
		{
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];

		if (!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		#if hscript
		FunkinLua.haxeInterp = null;
		#end
		super.destroy();
	}

	public static function cancelMusicFadeTween()
	{
		if (FlxG.sound.music.fadeTween != null)
		{
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;

	override function stepHit()
	{
		super.stepHit();
		if (splitVocals)
		{
			if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
				|| (SONG.needsVoices && Math.abs(vocalsLeft.time - (Conductor.songPosition - Conductor.offset)) > 20))
				resyncVocals();
		}
		else
		{
			if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
				|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
				resyncVocals();
		}
		if (hasExtra && Math.abs(songExtra.time - (Conductor.songPosition - Conductor.offset)) > 20)
			resyncVocals();

		if (curStep == lastStepHit)
		{
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if (lastBeatHit >= curBeat)
		{
			// trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null
			&& curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
			&& gf.animation.curAnim != null
			&& !gf.animation.curAnim.name.startsWith("sing")
			&& !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0
			&& boyfriend.animation.curAnim != null
			&& !boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0
			&& dad.animation.curAnim != null
			&& !dad.animation.curAnim.name.startsWith('sing')
			&& !dad.stunned)
		{
			dad.dance();
		}

		for (control in modchartCharacterControllers) {
			if (curBeat % control.danceNumBeats == 0
				&& control.sprite.animation.curAnim != null
				&& !control.sprite.animation.curAnim.name.startsWith('sing')
				&& !control.stunned)
			{
				control.dance();
			}
		}

		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); // DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}

		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic
	{
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if (exclusions == null)
			exclusions = [];
		for (script in luaArray)
		{
			if (exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if (ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;

			if (ret != FunkinLua.Function_Continue)
				returnVal = ret;
		}
		#end
		// trace(event, returnVal);
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic)
	{
		#if LUA_ALLOWED
		for (i in 0...luaArray.length)
		{
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float, ?note:Note = null)
	{
		if (note != null && note.noStrumAnim)
			return;
		var spr:StrumNote = null;
		if ((isDad && !isLeftMode) || (!isDad && isLeftMode))
		{
			if (isLeftMode && !PauseSubState.parentalControls_vals[0])
				return;
			spr = (!isLeftMode ? opponentStrums : playerStrums).members[id];
		}
		else
		{
			if (!isLeftMode && !PauseSubState.parentalControls_vals[0])
				return;
			spr = (isLeftMode ? opponentStrums : playerStrums).members[id];
		}

		if (spr != null)
		{
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;

	public function RecalculateRating(badHit:Bool = false)
	{
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		if (badHit)
			updateScore(true); // miss notes shouldn't make the scoretxt bounce -Ghost
		else
			updateScore(false);

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if (ret != FunkinLua.Function_Stop)
		{
			if (totalPlayed < 1) // Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				// trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if (ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length - 1][0]; // Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length - 1)
					{
						if (ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0)
				ratingFC = "SFC";
			if (goods > 0)
				ratingFC = "GFC";
			if (bads > 0 || shits > 0)
				ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10)
				ratingFC = "SDCB";
			else if (songMisses >= 10)
				ratingFC = "Clear";
		}
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if (chartingMode)
			return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length)
		{
			var achievementName:String = achievesToCheck[i];
			if (!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled)
			{
				var unlock:Bool = false;
				switch (achievementName)
				{
					case 'weekmushroom':
						if (isStoryMode
							&& originallyWantedDiffName.toUpperCase() == 'HARD'
							&& storyPlaylist.length <= 1
							&& !changedDifficulty
							&& !usedPractice)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch (weekName) // I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
							{
								case '0weekToad':
									if (achievementName == 'weekmushroom') 
										unlock = true;
							}
						}
					case 'weekmushroom_nomiss':
						if (isStoryMode
							&& campaignMisses + songMisses < 1
							&& originallyWantedDiffName.toUpperCase() == 'HARD'
							&& storyPlaylist.length <= 1
							&& !changedDifficulty
							&& !usedPractice)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch (weekName) // I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
							{
								case '0weekToad':
									if (achievementName == 'weekmushroom_nomiss') 
										unlock = true;
							}
						}
					case 'ur_bad':
						if (ratingPercent < 0.2 && !practiceMode)
						{
							unlock = true;
						}
					case 'ur_good':
						if (ratingPercent >= 1 && !usedPractice)
						{
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if (Achievements.henchmenDeath >= 100)
						{
							unlock = true;
						}
					case 'oversinging':
						if ((isLeftMode ? dad : boyfriend).holdTimer >= 10 && !usedPractice)
						{
							unlock = true;
						}
					case 'hype':
						if (!boyfriendIdled && !usedPractice)
						{
							unlock = true;
						}
					case 'two_keys':
						if (!usedPractice)
						{
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length)
							{
								if (keysPressed[j])
									howManyPresses++;
							}

							if (howManyPresses <= 2)
							{
								unlock = true;
							}
						}
					case 'toastie':
						if (/*ClientPrefs.framerate <= 60 &&*/ ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing && !ClientPrefs.imagesPersist
							&& !ClientPrefs.shaders)
						{
							unlock = true;
						}
					case 'debugger':
						if (Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice)
						{
							unlock = true;
						}
				}

				if (unlock)
				{
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end
}

// hiding this in playstate so other devs won't suspect a thing
// btw this was entirely lazer's idea
class PeeYourPantsState extends MusicBeatState {
	var chatGPTsInterpretationOfLuigi:FlxSprite;
	var theQuestion:FlxSprite; // new gumball episode
	var luigiTween:FlxTween;
	var questionTween:FlxTween;

	var doomingResponses:Array<FlxSprite> = [];
	var responsesEnabled:Bool = false;

    public override function create() {
        super.create();

		MusicBeatState.terror = -150000;
		DiscordClient.changePresence(null, null);

		// hardcoded on purpose
		chatGPTsInterpretationOfLuigi = new FlxSprite().loadGraphic(Paths.image("mainmenu/a"));
		chatGPTsInterpretationOfLuigi.screenCenter();
		add(chatGPTsInterpretationOfLuigi);

		theQuestion = new FlxSprite().loadGraphic(Paths.image("mainmenu/b"));
		theQuestion.screenCenter();
		theQuestion.alpha = 0;
		theQuestion.y -= theQuestion.height / 2;
		
		FlxG.sound.play(Paths.sound("b"), 2);
		FlxG.sound.playMusic(Paths.music("gameOver"), 0.5);

		chatGPTsInterpretationOfLuigi.scale.set(2, 2);
		luigiTween = FlxTween.tween(chatGPTsInterpretationOfLuigi.scale, {x: 1, y: 1}, 0.5, {ease: FlxEase.cubeOut});

		new FlxTimer().start(2.75, (timer:FlxTimer) -> {
			if (luigiTween != null)
				luigiTween.cancel();
			FlxG.sound.play(Paths.sound("c"), 2);
			luigiTween = FlxTween.tween(chatGPTsInterpretationOfLuigi, {y: FlxG.height / 2 - chatGPTsInterpretationOfLuigi.height * 0.85}, 0.85, {ease: FlxEase.cubeInOut});
			questionTween = FlxTween.tween(theQuestion, {y: FlxG.height / 2 + theQuestion.height, alpha: 1}, 0.875, {ease: FlxEase.cubeInOut});

			var questions:Float = 3;
			for (i in 0...Std.int(questions)) {
				var targetX:Float = FlxG.width / 2 - 50 + (250 * (i - (questions - 1) / 2));
				var newSpr:FlxSprite = new FlxSprite(FlxG.width / 2 - 50, FlxG.height / 2 + theQuestion.height * 2).loadGraphic(Paths.image("mainmenu/c"), true, 100, 60);
				newSpr.alpha = 0;
				newSpr.animation.add("idle", [i], 0, true, false);
				newSpr.animation.play("idle", true);
				FlxTween.tween(newSpr, {x: targetX, alpha: 1}, 0.75, {ease: FlxEase.cubeInOut, startDelay: 1.225});
				add(newSpr);
				doomingResponses.push(newSpr);
			}
			add(theQuestion);

			new FlxTimer().start(1, (timer:FlxTimer) -> {
				responsesEnabled = true;
				FlxG.mouse.visible = true;
			});
		});
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (!responsesEnabled)
			return;

		var currentlyHovering:Int = -1;
		for (i in 0...doomingResponses.length) {
			var curOpt:FlxSprite = doomingResponses[i];
			// doomingTween[i]
			if (FlxG.mouse.overlaps(curOpt))
				currentlyHovering = i;

			var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
			curOpt.scale.x = curOpt.scale.y = FlxMath.lerp(curOpt.scale.x, currentlyHovering == i ? 1.25 : 1, lerpVal);
		}

		if (currentlyHovering == -1 || !FlxG.mouse.justPressed)
			return;

		responsesEnabled = false;
		FlxG.sound.play(Paths.sound("b"), 2);
		for (i in 0...doomingResponses.length)
			doomingResponses[i].visible = currentlyHovering == i;
		theQuestion.visible = false;
		FlxG.sound.music.stop();
		MusicBeatState.terror = FlxG.random.float(900, 7200) * 1.2;
		doomingResponses[currentlyHovering].scale.set(1.5, 1.5);

		new FlxTimer().start(3.5, (timer:FlxTimer) -> {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			LoadingState.loadAndSwitchState(new MainMenuState());
		});
	}
}