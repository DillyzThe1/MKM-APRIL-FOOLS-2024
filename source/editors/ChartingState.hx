package editors;

import Conductor.BPMChangeEvent;
import Discord.DiscordClient;
import Section.SwagSection;
import Song.SwagSong;
import cpp.Int32;
import flash.geom.Rectangle;
import flash.media.Sound;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import haxe.Json;
import haxe.format.JsonParser;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.ByteArray;
import sys.FileSystem;
import sys.io.File;

using StringTools;

@:access(flixel.system.FlxSound._sound)
@:access(openfl.media.Sound.__buffer)
class ChartingState extends MusicBeatState
{
	public static var noteTypeList:Array<String> = // Used for backwards compatibility with 0.1 - 0.3.2 charts, though, you should add your hardcoded custom note types here too.
		['', 'Alt Animation', 'Hey!', 'Hurt Note', 'GF Sing', 'No Animation'];

	private var noteTypeIntMap:Map<Int, String> = new Map<Int, String>();
	private var noteTypeMap:Map<String, Null<Int>> = new Map<String, Null<Int>>();

	private var splitVocals:Bool = false;

	public var ignoreWarnings = false;

	var undos = [];
	var redos = [];
	var eventStuff:Array<Dynamic> = [
		['', "Nothing. Yep, that's right."],
		[
			'Hey!',
			"Plays the \"Hey!\" animation from Bopeebo,\nValue 1: BF = Only IDK, GF = Only Still Dunno,\nSomething else = Both.\nValue 2: Custom animation duration,\nleave it blank for 0.6s"
		],
		[
			'Set Who? Speed',
			"Sets Who? head bopping speed,\nValue 1: 1 = Normal speed,\n2 = 1/2 speed, 4 = 1/4 speed etc.\nUsed on Fresh during the beatbox parts.\n\nWarning: Value must be integer!"
		],
		[
			'Add Camera Zoom',
			"Used on idk on that one \"hard\" part\nValue 1: Camera zoom add (Default: 0.015)\nValue 2: UI zoom add (Default: 0.03)\nLeave the values blank if you want to use Default."
		],
		[
			'Play Animation',
			"Plays an animation on a Character,\nonce the animation is completed,\nthe animation changes to Idle\n\nValue 1: Animation to play.\nValue 2: Character (Dad, BF, GF)"
		],
		[
			'Camera Follow Pos',
			"Value 1: X\nValue 2: Y\n\nThe camera won't change the follow point\nafter using this, for getting it back\nto normal, leave both values blank."
		],
		[
			'Alt Idle Animation',
			"Sets a specified suffix after the idle animation name.\nYou can use this to trigger 'idle-alt' if you set\nValue 2 to -alt\n\nValue 1: Character to set (Dad, BF or GF)\nValue 2: New suffix (Leave it blank to disable)"
		],
		[
			'Screen Shake',
			"Value 1: Camera shake\nValue 2: HUD shake\n\nEvery value works as the following example: \"1, 0.05\".\nThe first number (1) is the duration.\nThe second number (0.05) is the intensity."
		],
		[
			'Change Character',
			"Value 1: Character to change (Dad, BF, GF)\nValue 2: New character's name"
		],
		[
			'Change Scroll Speed',
			"Value 1: Scroll Speed Multiplier (1 is default)\nValue 2: Time it takes to change fully in seconds."
		],
		[
			'Set Property', 
			"Value 1: Variable name\nValue 2: New value"
		],
		[
			'Key Count Swap',
			"Enter a keycount, and\nit'll change the input.\n\nNote: Requires 9K"
		], // "🤓"]
		[
			'Closed Captions',
			"Set the current captions in the first box.\nThe lower text box does nothing.\n\nBox auto-hides when blank."
		],
		[
			'Show Countdown Index',
			"Shows one of the sprites of the countdown.\nThe first box is the number between 1-4 to do.\nThe second box is a true/false for sounds."
		],
		[
			'Change IconP1',
			"Changes the icon for the right side.\nV1: Icon name.\nV2: Icon color. (Hexidecimal)"
		],
		[
			'Change IconP2',
			"Changes the icon for the left side.\nV1: Icon name.\nV2: Icon color. (Hexidecimal)"
		]
	];

	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	public static var goToPlayState:Bool = false;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	public static var curSec:Int = 0;

	public static var lastSection:Int = 0;
	private static var lastSong:String = '';

	var bpmTxt:FlxText;

	var camPos:FlxObject;
	var strumLine:FlxSprite;
	var quant:AttachedSprite;
	var strumLineNotes:FlxTypedGroup<StrumNote>;
	var curSong:String = 'Test';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	public static var GRID_SIZE:Int = 40;

	var CAM_OFFSET:Int = 360;

	var dummyArrow:FlxSprite;

	var curRenderedSustains:FlxTypedGroup<SusSprite>;
	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedNoteType:FlxTypedGroup<AttachedFlxText>;

	var nextRenderedSustains:FlxTypedGroup<SusSprite>;
	var nextRenderedNotes:FlxTypedGroup<Note>;

	var gridBG:FlxSprite;
	var nextGridBG:FlxSprite;

	var daquantspot = 0;
	var curEventSelected:Int = 0;
	var curUndoIndex = 0;
	var curRedoIndex = 0;
	var _song:SwagSong;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic> = null;

	var tempBpm:Float = 0;

	var vocals:FlxSound = null;
	var songExtra:FlxSound = null;
	var vocalsLeft:FlxSound = null;
	var vocalsRight:FlxSound = null;

	public static var leftSingParam:String;
	public static var rightSingParam:String;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var value1InputText:FlxUIInputText;
	var value2InputText:FlxUIInputText;
	var currentSongName:String;

	var zoomTxt:FlxText;

	var zoomList:Array<Float> = [0.25, 0.5, 1, 2, 3, 4, 6, 8, 12, 16, 24];
	var curZoom:Int = 2;

	private var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	private var blockPressWhileTypingOnStepper:Array<FlxUINumericStepper> = [];
	private var blockPressWhileScrolling:Array<FlxUIDropDownMenuCustom> = [];

	var waveformSprite:FlxSprite;
	var gridLayer:FlxTypedGroup<FlxSprite>;

	public static var quantization:Int = 16;
	public static var curQuant = 3;

	public var quantizations:Array<Int> = [4, 8, 12, 16, 20, 24, 32, 48, 64, 96, 192];

	var text:String = "";

	public static var vortex:Bool = false;

	public var mouseQuant:Bool = false;

	var peeYourPantsOffset:Int = -350;

	var peeMyPantsOffset:Int = 175;

	var eventIcon:FlxSprite;

	override function create()
	{
		if (PlayState.SONG != null)
		{
			_song = PlayState.SONG;

			var songName:String = Paths.formatToSongPath(_song.song);
			var mario:String = _song.audioPostfix;

			if ((FileSystem.exists('assets/songs/$songName/Voices$mario-left') || FileSystem.exists('mkm_content/songs/$songName/Voices$mario-left'))
				&& (FileSystem.exists('assets/songs/$songName/Voices$mario-right') || FileSystem.exists('mkm_content/songs/$songName/Voices$mario-right')))
				splitVocals = true;

			trace('split vocals? $splitVocals...');
		}
		else
		{
			CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();

			_song = {
				song: 'Test',
				notes: [],
				events: [],
				bpm: 150.0,
				needsVoices: true,
				arrowSkin: '',
				splashSkin: 'noteSplashes', // idk it would crash if i didn't
				player1: 'bf',
				player2: 'dad',
				gfVersion: 'gf',
				speed: 1,
				stage: 'stage',
				validScore: false,
				mania: 0,
				audioPostfix: "",
				soloMode: false,
				leftMode: false
			};
			addSection();
			PlayState.SONG = _song;
		}

		// Paths.clearMemory();

		// Updating Discord Rich Presence
		DiscordClient.changePresence("Chart Editor", StringTools.replace(_song.song, '-', ' '));

		trace('left sing param: $leftSingParam');
		trace('right sing param: $rightSingParam');

		vortex = FlxG.save.data.chart_vortex;
		ignoreWarnings = FlxG.save.data.ignoreWarnings;
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF222222;
		add(bg);

		gridLayer = new FlxTypedGroup<FlxSprite>();
		add(gridLayer);

		waveformSprite = new FlxSprite(GRID_SIZE, 0).makeGraphic(FlxG.width, FlxG.height, 0x00FFFFFF);
		add(waveformSprite);

		eventIcon = new FlxSprite(-GRID_SIZE - 5, -90).loadGraphic(Paths.image('eventArrow'));
		leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('dad');
		eventIcon.scrollFactor.set(1, 1);
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		eventIcon.setGraphicSize(30, 30);
		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(eventIcon);
		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(GRID_SIZE + 10, -100);
		rightIcon.setPosition(GRID_SIZE * 5.2, -100);

		curRenderedSustains = new FlxTypedGroup<SusSprite>();
		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedNoteType = new FlxTypedGroup<AttachedFlxText>();

		nextRenderedSustains = new FlxTypedGroup<SusSprite>();
		nextRenderedNotes = new FlxTypedGroup<Note>();

		if (curSec >= _song.notes.length)
			curSec = _song.notes.length - 1;

		FlxG.mouse.visible = true;
		// FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		currentSongName = Paths.formatToSongPath(_song.song);
		loadSong();
		reloadGridLayer();
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000 + peeYourPantsOffset, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		bpmTxt.alignment = FlxTextAlign.RIGHT;
		bpmTxt.borderColor = FlxColor.BLACK;
		bpmTxt.borderSize = 2;
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(GRID_SIZE * 9), 4);
		add(strumLine);

		quant = new AttachedSprite('chart_quant', 'chart_quant');
		quant.animation.addByPrefix('q', 'chart_quant', 0, false);
		quant.animation.play('q', true, false, 0);
		quant.sprTracker = strumLine;
		quant.xAdd = -32;
		quant.yAdd = 8;
		add(quant);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		for (i in 0...getKeyCount() * 2)
		{
			var note:StrumNote = new StrumNote(GRID_SIZE * (i + 1), strumLine.y, i % getKeyCount(), 0);
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.playAnim('static', true);
			strumLineNotes.add(note);
			note.scrollFactor.set(1, 1);
		}
		add(strumLineNotes);

		camPos = new FlxObject(0, 0, 1, 1);
		camPos.setPosition(strumLine.x + CAM_OFFSET, strumLine.y);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Events", label: 'Events'},
			{name: "Charting", label: 'Charting'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = 640 + GRID_SIZE / 2 + peeMyPantsOffset;
		UI_box.y = 25;
		UI_box.scrollFactor.set();

		text = "W/S or Mouse Wheel - Change Conductor's strum time
		\nA/D - Go to the previous/next section
		\nLeft/Right - Change Snap
		\nUp/Down - Change Conductor's Strum Time with Snapping
		\nHold Shift to move 4x faster
		\nHold Control and click on an arrow to select it
		\nZ/X - Zoom in/out
		\n
		\nEsc - Test your chart inside Chart Editor
		\nEnter - Play your chart
		\nQ/E - Decrease/Increase Note Sustain Length
		\nSpace - Stop/Resume song";

		var tipTextArray:Array<String> = text.split('\n');
		for (i in 0...tipTextArray.length)
		{
			var tipText:FlxText = new FlxText(UI_box.x, UI_box.y + UI_box.height + 8, 0, tipTextArray[i], 16);
			tipText.y += i * 12;
			tipText.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, LEFT /*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
			// tipText.borderSize = 2;
			tipText.scrollFactor.set();
			add(tipText);
		}
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addEventsUI();
		addChartingUI();
		updateHeads();
		updateWaveform();
		// UI_box.selected_tab = 4;

		add(curRenderedSustains);
		add(curRenderedNotes);
		add(curRenderedNoteType);
		add(nextRenderedSustains);
		add(nextRenderedNotes);

		if (lastSong != currentSongName)
		{
			changeSection();
		}
		lastSong = currentSongName;

		zoomTxt = new FlxText(10, 10, 0, "Zoom: 1 / 1", 16);
		zoomTxt.scrollFactor.set();
		add(zoomTxt);

		if (_song.notes.length == 0)
			addSection(4);
		if (curSec >= _song.notes.length)
			curSec = 0;

		updateGrid();
		super.create();

		reloadGridLayer();
	}

	var check_mute_inst:FlxUICheckBox = null;
	var check_vortex:FlxUICheckBox = null;
	var check_warnings:FlxUICheckBox = null;
	var playSoundBf:FlxUICheckBox = null;
	var playSoundDad:FlxUICheckBox = null;
	var UI_songTitle:FlxUIInputText;
	var noteSkinInputText:FlxUIInputText;
	var noteSplashesInputText:FlxUIInputText;
	var stageDropDown:FlxUIDropDownMenuCustom;

	function addSongUI():Void
	{
		UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		blockPressWhileTypingOn.push(UI_songTitle);

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			// trace('CHECKED!');
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + 90, saveButton.y, "Reload Audio", function()
		{
			currentSongName = Paths.formatToSongPath(UI_songTitle.text);
			loadSong();
			updateWaveform();
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, function()
			{
				loadJson(_song.song.toLowerCase());
			}, null, ignoreWarnings));
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'Load Autosave', function()
		{
			PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
			MusicBeatState.resetState();
		});

		var loadEventJson:FlxButton = new FlxButton(loadAutosaveBtn.x, loadAutosaveBtn.y + 30, 'Load Events', function()
		{
			var songName:String = Paths.formatToSongPath(_song.song);
			var file:String = Paths.json(songName + '/events');
			if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file))
			{
				clearEvents();
				var events:SwagSong = Song.loadFromJson('events', songName);
				_song.events = events.events;
				changeSection(curSec);
			}
		});

		var saveEvents:FlxButton = new FlxButton(110, reloadSongJson.y, 'Save Events', function()
		{
			saveEvents();
		});

		var clear_events:FlxButton = new FlxButton(320, 310, 'Clear events', function()
		{
			openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, clearEvents, null, ignoreWarnings));
		});
		clear_events.color = FlxColor.RED;
		clear_events.label.color = FlxColor.WHITE;

		var clear_notes:FlxButton = new FlxButton(320, clear_events.y + 30, 'Clear notes', function()
		{
			openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, function()
			{
				for (sec in 0..._song.notes.length)
				{
					_song.notes[sec].sectionNotes = [];
				}
				updateGrid(false);
			}, null, ignoreWarnings));
		});
		clear_notes.color = FlxColor.RED;
		clear_notes.label.color = FlxColor.WHITE;

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 70, 1, 1, 1, 400, 3);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';
		blockPressWhileTypingOnStepper.push(stepperBPM);
		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, stepperBPM.y + 35, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';
		blockPressWhileTypingOnStepper.push(stepperSpeed);

		var keyCountThing:FlxUINumericStepper = new FlxUINumericStepper(stepperSpeed.x + 100, stepperSpeed.y, 1, 1, 1, 9, 3);
		keyCountThing.value = Note.maniaToKeyCount(_song.mania);
		keyCountThing.name = 'song_keycount';
		blockPressWhileTypingOnStepper.push(keyCountThing);

		var directories:Array<String> = [
			Paths.mods('characters/'),
			Paths.mods(Paths.currentModDirectory + '/characters/'),
			Paths.getPreloadPath('characters/')
		];
		for (mod in Paths.getGlobalMods())
			directories.push(Paths.mods(mod + '/characters/'));

		var tempMap:Map<String, Bool> = new Map<String, Bool>();
		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		for (i in 0...characters.length)
		{
			tempMap.set(characters[i], true);
		}

		for (i in 0...directories.length)
		{
			var directory:String = directories[i];
			if (FileSystem.exists(directory))
			{
				for (file in FileSystem.readDirectory(directory))
				{
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.json'))
					{
						var charToCheck:String = file.substr(0, file.length - 5);
						if (!charToCheck.endsWith('-dead') && !tempMap.exists(charToCheck))
						{
							tempMap.set(charToCheck, true);
							characters.push(charToCheck);
						}
					}
				}
			}
		}

		var player1DropDown = new FlxUIDropDownMenuCustom(10, stepperSpeed.y + 45, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true),
			function(character:String)
			{
				_song.player1 = characters[Std.parseInt(character)];
				updateHeads();
			});
		player1DropDown.selectedLabel = _song.player1;
		blockPressWhileScrolling.push(player1DropDown);

		var gfVersionDropDown = new FlxUIDropDownMenuCustom(player1DropDown.x, player1DropDown.y + 40,
			FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.gfVersion = characters[Std.parseInt(character)];
			updateHeads();
		});
		gfVersionDropDown.selectedLabel = _song.gfVersion;
		blockPressWhileScrolling.push(gfVersionDropDown);

		var player2DropDown = new FlxUIDropDownMenuCustom(player1DropDown.x, gfVersionDropDown.y + 40,
			FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
			updateHeads();
		});
		player2DropDown.selectedLabel = _song.player2;
		blockPressWhileScrolling.push(player2DropDown);

		var directories:Array<String> = [
			Paths.mods('stages/'),
			Paths.mods(Paths.currentModDirectory + '/stages/'),
			Paths.getPreloadPath('stages/')
		];
		for (mod in Paths.getGlobalMods())
			directories.push(Paths.mods(mod + '/stages/'));

		tempMap.clear();
		var stageFile:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));
		var stages:Array<String> = [];
		for (i in 0...stageFile.length)
		{ // Prevent duplicates
			var stageToCheck:String = stageFile[i];
			if (!tempMap.exists(stageToCheck))
			{
				stages.push(stageToCheck);
			}
			tempMap.set(stageToCheck, true);
		}
		for (i in 0...directories.length)
		{
			var directory:String = directories[i];
			if (FileSystem.exists(directory))
			{
				for (file in FileSystem.readDirectory(directory))
				{
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.json'))
					{
						var stageToCheck:String = file.substr(0, file.length - 5);
						if (!tempMap.exists(stageToCheck))
						{
							tempMap.set(stageToCheck, true);
							stages.push(stageToCheck);
						}
					}
				}
			}
		}

		if (stages.length < 1)
			stages.push('stage');

		stageDropDown = new FlxUIDropDownMenuCustom(player1DropDown.x + 140, player1DropDown.y, FlxUIDropDownMenuCustom.makeStrIdLabelArray(stages, true),
			function(character:String)
			{
				_song.stage = stages[Std.parseInt(character)];
			});
		stageDropDown.selectedLabel = _song.stage;
		blockPressWhileScrolling.push(stageDropDown);

		var skin = PlayState.SONG.arrowSkin;
		if (skin == null)
			skin = '';
		noteSkinInputText = new FlxUIInputText(player2DropDown.x, player2DropDown.y + 50, 150, skin, 8);
		blockPressWhileTypingOn.push(noteSkinInputText);

		noteSplashesInputText = new FlxUIInputText(noteSkinInputText.x, noteSkinInputText.y + 35, 150, _song.splashSkin, 8);
		blockPressWhileTypingOn.push(noteSplashesInputText);

		var reloadNotesButton:FlxButton = new FlxButton(noteSplashesInputText.x + 5, noteSplashesInputText.y + 20, 'Change Notes', function()
		{
			_song.arrowSkin = noteSkinInputText.text;
			updateGrid();
		});

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		// super checkio
		var soloMode_check = new FlxUICheckBox(stageDropDown.x, gfVersionDropDown.y, null, null, "Solo Mode", 100);
		soloMode_check.checked = _song.soloMode;
		soloMode_check.callback = function() { _song.soloMode = soloMode_check.checked; };

		var leftMode_check = new FlxUICheckBox(stageDropDown.x, player2DropDown.y, null, null, "Left-Play Mode", 100);
		leftMode_check.checked = _song.leftMode;
		leftMode_check.callback = function() { _song.leftMode = leftMode_check.checked; };

		
		var shiftSongUp:FlxButton = new FlxButton(reloadSong.x, noteSkinInputText.y, "Shift Up", function()
		{
			trace('hi go up');

			for (section in curSec..._song.notes.length)
				for (i in _song.notes[section].sectionNotes)
					i[0] -= (1000 * 60 / getSectionBPM());
			updateGrid(false);
		});

		var shiftSongDown:FlxButton = new FlxButton(reloadSong.x, noteSplashesInputText.y, "Shift Down", function()
		{
			trace('hi go down');

			for (section in curSec..._song.notes.length)
				for (i in _song.notes[section].sectionNotes)
					i[0] += (1000 * 60 / getSectionBPM());
			updateGrid(false);
		});

		var regroupNotes:FlxButton = new FlxButton(reloadSong.x, reloadNotesButton.y, "Regroup Notes", function()
		{
			regroupNotes();
		});

		tab_group_song.add(check_voices);
		tab_group_song.add(clear_events);
		tab_group_song.add(clear_notes);
		tab_group_song.add(saveButton);
		tab_group_song.add(saveEvents);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(loadEventJson);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(keyCountThing);
		tab_group_song.add(reloadNotesButton);
		tab_group_song.add(noteSkinInputText);
		tab_group_song.add(noteSplashesInputText);

		tab_group_song.add(soloMode_check);
		tab_group_song.add(leftMode_check);

		tab_group_song.add(new FlxText(stepperBPM.x, stepperBPM.y - 15, 0, 'Song BPM:'));
		//tab_group_song.add(new FlxText(stepperBPM.x + 100, stepperBPM.y - 15, 0, 'Song Offset:'));
		tab_group_song.add(new FlxText(stepperSpeed.x, stepperSpeed.y - 15, 0, 'Song Speed:'));
		tab_group_song.add(new FlxText(keyCountThing.x, keyCountThing.y - 15, 0, 'Key Count:'));
		tab_group_song.add(new FlxText(player2DropDown.x, player2DropDown.y - 15, 0, 'Opponent:'));
		tab_group_song.add(new FlxText(gfVersionDropDown.x, gfVersionDropDown.y - 15, 0, 'Huh?:'));
		tab_group_song.add(new FlxText(player1DropDown.x, player1DropDown.y - 15, 0, 'Who?:'));
		tab_group_song.add(new FlxText(stageDropDown.x, stageDropDown.y - 15, 0, 'Stage:'));
		tab_group_song.add(new FlxText(noteSkinInputText.x, noteSkinInputText.y - 15, 0, 'Note Texture:'));
		tab_group_song.add(new FlxText(noteSplashesInputText.x, noteSplashesInputText.y - 15, 0, 'Note Splashes Texture:'));
		tab_group_song.add(player2DropDown);
		tab_group_song.add(gfVersionDropDown);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(stageDropDown);

		tab_group_song.add(shiftSongUp);
		tab_group_song.add(shiftSongDown);
		tab_group_song.add(regroupNotes);

		UI_box.addGroup(tab_group_song);

		FlxG.camera.follow(camPos);
	}

	function regroupNotes() {
		var oldCurSec:Int = curSec;
		var allNotes:Array<Dynamic> = [];

		for (section in 0..._song.notes.length)
			for (i in 0..._song.notes[section].sectionNotes.length)
				allNotes.push(_song.notes[section].sectionNotes.pop());

		
		for (section in 0..._song.notes.length) {
			curSec = section;
			for (epicnote in 0...allNotes.length) {
				if (allNotes[epicnote][0] > sectionStartTime() && allNotes[epicnote][0] - 1 <= sectionStartTime(1))
					_song.notes[curSec].sectionNotes.push(allNotes[epicnote]);
			}
			sectionStartTime();
		}
		curSec = oldCurSec;
	}

	function flippedData(ogData:Int)
	{
		if (ogData >= getKeyCount())
			return ogData - getKeyCount();
		return ogData + getKeyCount();
	}

	var stepperBeats:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_gfSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	var sectionToCopy:Int = 0;
	var notesCopied:Array<Dynamic>;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		check_mustHitSection = new FlxUICheckBox(10, 15, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = _song.notes[curSec].mustHitSection;

		check_gfSection = new FlxUICheckBox(10, check_mustHitSection.y + 22, null, null, "GF section", 100);
		check_gfSection.name = 'check_gf';
		check_gfSection.checked = _song.notes[curSec].gfSection;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(check_gfSection.x + 120, check_gfSection.y, null, null, "Alt Animation", 100);
		check_altAnim.checked = _song.notes[curSec].altAnim;

		stepperBeats = new FlxUINumericStepper(10, 100, 1, 4, 1, 6, 2);
		stepperBeats.value = getSectionBeats();
		stepperBeats.name = 'section_beats';
		blockPressWhileTypingOnStepper.push(stepperBeats);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, stepperBeats.y + 30, null, null, 'Change BPM', 100);
		check_changeBPM.checked = _song.notes[curSec].changeBPM;
		check_changeBPM.name = 'check_changeBPM';

		stepperSectionBPM = new FlxUINumericStepper(10, check_changeBPM.y + 20, 1, Conductor.bpm, 0, 999, 1);
		if (check_changeBPM.checked)
		{
			stepperSectionBPM.value = _song.notes[curSec].bpm;
		}
		else
		{
			stepperSectionBPM.value = Conductor.bpm;
		}
		stepperSectionBPM.name = 'section_bpm';
		blockPressWhileTypingOnStepper.push(stepperSectionBPM);

		var check_eventsSec:FlxUICheckBox = null;
		var check_notesSec:FlxUICheckBox = null;
		var copyButton:FlxButton = new FlxButton(10, 190, "Copy Section", function()
		{
			notesCopied = [];
			sectionToCopy = curSec;
			for (i in 0..._song.notes[curSec].sectionNotes.length)
			{
				var note:Array<Dynamic> = _song.notes[curSec].sectionNotes[i];
				notesCopied.push(note);
			}

			var startThing:Float = sectionStartTime();
			var endThing:Float = sectionStartTime(1);
			for (event in _song.events)
			{
				var strumTime:Float = event[0];
				if (endThing > event[0] && event[0] >= startThing)
				{
					var copiedEventArray:Array<Dynamic> = [];
					for (i in 0...event[1].length)
					{
						var eventToPush:Array<Dynamic> = event[1][i];
						copiedEventArray.push([eventToPush[0], eventToPush[1], eventToPush[2]]);
					}
					notesCopied.push([strumTime, -1, copiedEventArray]);
				}
			}
		});

		var pasteButton:FlxButton = new FlxButton(copyButton.x + 100, copyButton.y, "Paste Section", function()
		{
			if (notesCopied == null || notesCopied.length < 1)
			{
				return;
			}

			var addToTime:Float = Conductor.stepCrochet * (getSectionBeats() * 4 * (curSec - sectionToCopy));
			// trace('Time to add: ' + addToTime);

			for (note in notesCopied)
			{
				var copiedNote:Array<Dynamic> = [];
				var newStrumTime:Float = note[0] + addToTime;
				if (note[1] < 0)
				{
					if (check_eventsSec.checked)
					{
						var copiedEventArray:Array<Dynamic> = [];
						for (i in 0...note[2].length)
						{
							var eventToPush:Array<Dynamic> = note[2][i];
							copiedEventArray.push([eventToPush[0], eventToPush[1], eventToPush[2]]);
						}
						_song.events.push([newStrumTime, copiedEventArray]);
					}
				}
				else
				{
					if (check_notesSec.checked)
					{
						if (note[4] != null)
						{
							copiedNote = [newStrumTime, note[1], note[2], note[3], note[4]];
						}
						else
						{
							copiedNote = [newStrumTime, note[1], note[2], note[3]];
						}
						_song.notes[curSec].sectionNotes.push(copiedNote);
					}
				}
			}
			updateGrid(false);
		});

		var clearSectionButton:FlxButton = new FlxButton(pasteButton.x + 100, pasteButton.y, "Clear", function()
		{
			if (check_notesSec.checked)
			{
				_song.notes[curSec].sectionNotes = [];
			}

			if (check_eventsSec.checked)
			{
				var i:Int = _song.events.length - 1;
				var startThing:Float = sectionStartTime();
				var endThing:Float = sectionStartTime(1);
				while (i > -1)
				{
					var event:Array<Dynamic> = _song.events[i];
					if (event != null && endThing > event[0] && event[0] >= startThing)
					{
						_song.events.remove(event);
					}
					--i;
				}
			}
			updateGrid(false);
			updateNoteUI();
		});
		clearSectionButton.color = FlxColor.RED;
		clearSectionButton.label.color = FlxColor.WHITE;

		check_notesSec = new FlxUICheckBox(10, clearSectionButton.y + 25, null, null, "Notes", 100);
		check_notesSec.checked = true;
		check_eventsSec = new FlxUICheckBox(check_notesSec.x + 100, check_notesSec.y, null, null, "Events", 100);
		check_eventsSec.checked = true;

		var swapSection:FlxButton = new FlxButton(10, check_notesSec.y + 40, "Swap section", function()
		{
			for (i in 0..._song.notes[curSec].sectionNotes.length)
			{
				var note:Array<Dynamic> = _song.notes[curSec].sectionNotes[i];
				note[1] = flippedData(note[1]);
				_song.notes[curSec].sectionNotes[i] = note;
			}
			updateGrid(false);
		});

		var stepperCopy:FlxUINumericStepper = null;
		var copyLastButton:FlxButton = new FlxButton(10, swapSection.y + 30, "Copy last section", function()
		{
			var value:Int = Std.int(stepperCopy.value);
			if (value == 0)
				return;

			var daSec = FlxMath.maxInt(curSec, value);

			var startThing:Float = sectionStartTime(-value);
			var starting:Float = sectionStartTime() - startThing;

			for (note in _song.notes[daSec - value].sectionNotes)
			{
				var strum = note[0] + starting;
				trace("strumtime " + strum);
				var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];
				_song.notes[daSec].sectionNotes.push(copiedNote);
			}
			var endThing:Float = sectionStartTime(-value + 1);
			for (event in _song.events)
			{
				var strumTime:Float = event[0];
				if (endThing > event[0] && event[0] >= startThing)
				{
					strumTime += Conductor.stepCrochet * (getSectionBeats(daSec) * 4 * value);
					var copiedEventArray:Array<Dynamic> = [];
					for (i in 0...event[1].length)
					{
						var eventToPush:Array<Dynamic> = event[1][i];
						copiedEventArray.push([eventToPush[0], eventToPush[1], eventToPush[2]]);
					}
					_song.events.push([strumTime, copiedEventArray]);
				}
			}
			updateGrid(false);
		});
		copyLastButton.setGraphicSize(80, 30);
		copyLastButton.updateHitbox();

		stepperCopy = new FlxUINumericStepper(copyLastButton.x + 100, copyLastButton.y, 1, 1, -999, 999, 0);
		blockPressWhileTypingOnStepper.push(stepperCopy);

		var duetButton:FlxButton = new FlxButton(10, copyLastButton.y + 45, "Duet Notes", function()
		{
			var duetNotes:Array<Array<Dynamic>> = [];
			for (note in _song.notes[curSec].sectionNotes)
			{
				var boob = note[1];
				if (boob > getKeyCount() - 1)
				{
					boob -= getKeyCount();
				}
				else
				{
					boob += getKeyCount();
				}

				var copiedNote:Array<Dynamic> = [note[0], boob, note[2], note[3]];
				duetNotes.push(copiedNote);
			}

			for (i in duetNotes)
			{
				_song.notes[curSec].sectionNotes.push(i);
			}

			updateGrid(false);
		});
		var mirrorButton:FlxButton = new FlxButton(duetButton.x + 100, duetButton.y, "Mirror Notes", function()
		{
			for (note in _song.notes[curSec].sectionNotes)
			{
				var keyssss:Int = getKeyCount();
				if (note[1] >= keyssss)
					note[1] = ((keyssss * 2) - 1) - (note[1] - keyssss);
				else
					note[1] = (keyssss - 1) - note[1];
			}

			updateGrid(false);
		});

		var trimButton:FlxButton = new FlxButton(mirrorButton.x + 100, duetButton.y, "Trim Notes", function()
		{
			// var offset:Float = (5 * 60 / daBPM);
			var secStart:Float = sectionStartTime(); // - offset;
			var secEnd:Float = sectionStartTime(1) - 1; // + offset;

			for (note in _song.notes[curSec].sectionNotes)
				if (note[0] < secStart || note[0] > secEnd)
					_song.notes[curSec].sectionNotes.remove(note);

			updateGrid(false);
		});

		var shiftUpButton:FlxButton = new FlxButton(10, duetButton.y + 25, "Shift Up", function()
		{
			for (i in _song.notes[curSec].sectionNotes)
				i[0] -= 1000 * 60 / getSectionBPM();
			updateGrid(false);
		});

		var shiftDownButton:FlxButton = new FlxButton(shiftUpButton.x + 100, shiftUpButton.y, "Shift Down", function()
		{
			for (i in _song.notes[curSec].sectionNotes)
				i[0] += 1000 * 60 / getSectionBPM();
			updateGrid(false);
		});

		tab_group_section.add(new FlxText(stepperBeats.x, stepperBeats.y - 15, 0, 'Beats per Section:'));
		tab_group_section.add(stepperBeats);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_gfSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(pasteButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(check_notesSec);
		tab_group_section.add(check_eventsSec);
		tab_group_section.add(swapSection);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(copyLastButton);
		tab_group_section.add(duetButton);
		tab_group_section.add(mirrorButton);
		// mkm 1.5 extras
		tab_group_section.add(trimButton);
		tab_group_section.add(shiftUpButton);
		tab_group_section.add(shiftDownButton);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;
	var strumTimeInputText:FlxUIInputText; // I wanted to use a stepper but we can't scale these as far as i know :(
	var noteTypeDropDown:FlxUIDropDownMenuCustom;
	var currentType:Int = 0;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 25, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 64);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';
		blockPressWhileTypingOnStepper.push(stepperSusLength);

		strumTimeInputText = new FlxUIInputText(10, 65, 180, "0");
		tab_group_note.add(strumTimeInputText);
		blockPressWhileTypingOn.push(strumTimeInputText);

		var key:Int = 0;
		var displayNameList:Array<String> = [];
		while (key < noteTypeList.length)
		{
			displayNameList.push(noteTypeList[key]);
			noteTypeMap.set(noteTypeList[key], key);
			noteTypeIntMap.set(key, noteTypeList[key]);
			key++;
		}

		#if LUA_ALLOWED
		var directories:Array<String> = [];

		directories.push(Paths.mods('custom_notetypes/'));
		directories.push(Paths.mods(Paths.currentModDirectory + '/custom_notetypes/'));
		for (mod in Paths.getGlobalMods())
			directories.push(Paths.mods(mod + '/custom_notetypes/'));

		for (i in 0...directories.length)
		{
			var directory:String = directories[i];
			if (FileSystem.exists(directory))
			{
				for (file in FileSystem.readDirectory(directory))
				{
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.lua'))
					{
						var fileToCheck:String = file.substr(0, file.length - 4);
						if (!noteTypeMap.exists(fileToCheck))
						{
							displayNameList.push(fileToCheck);
							noteTypeMap.set(fileToCheck, key);
							noteTypeIntMap.set(key, fileToCheck);
							key++;
						}
					}
				}
			}
		}
		#end

		for (i in 1...displayNameList.length)
		{
			displayNameList[i] = i + '. ' + displayNameList[i];
		}

		var scaryoffsetdotdotdot:Int = 25;
		noteTypeDropDown = new FlxUIDropDownMenuCustom(10, 105 + scaryoffsetdotdotdot, FlxUIDropDownMenuCustom.makeStrIdLabelArray(displayNameList, true), function(character:String)
		{
			currentType = Std.parseInt(character);
			if (curSelectedNote != null && curSelectedNote[1] > -1)
			{
				curSelectedNote[3] = noteTypeIntMap.get(currentType);
				updateGrid(false);
			}
		});
		blockPressWhileScrolling.push(noteTypeDropDown);

		tab_group_note.add(new FlxText(10, 10, 0, 'Sustain length:'));
		tab_group_note.add(new FlxText(10, 50, 0, 'Strum time (in miliseconds):'));
		tab_group_note.add(new FlxText(10, 90 + scaryoffsetdotdotdot, 0, 'Note type:'));
		var setMhToType:FlxButton = new FlxButton(10, 90, "Set \"Must Hits\"", function() {
			for (i in 0..._song.notes[curSec].sectionNotes.length)
			{
				var mustPress:Bool = _song.notes[curSec].mustHitSection;
				if (_song.notes[curSec].sectionNotes[i][1] > getKeyCount() - 1)
					mustPress = !mustPress;
				if(mustPress)
					_song.notes[curSec].sectionNotes[i][3] = noteTypeIntMap.get(currentType);
			}
			updateGrid(false);
		});
		tab_group_note.add(setMhToType);
		tab_group_note.add(new FlxButton(setMhToType.x + setMhToType.width + 10, setMhToType.y, "Set others", function() {
			for (i in 0..._song.notes[curSec].sectionNotes.length)
			{
				var mustPress:Bool = _song.notes[curSec].mustHitSection;
				if (_song.notes[curSec].sectionNotes[i][1] > getKeyCount() - 1)
					mustPress = !mustPress;
				if(!mustPress)
					_song.notes[curSec].sectionNotes[i][3] = noteTypeIntMap.get(currentType);
			}
			updateGrid(false);
		}));
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(strumTimeInputText);
		tab_group_note.add(noteTypeDropDown);

		UI_box.addGroup(tab_group_note);
	}

	var eventDropDown:FlxUIDropDownMenuCustom;
	var descText:FlxText;
	var selectedEventText:FlxText;

	function addEventsUI():Void
	{
		var tab_group_event = new FlxUI(null, UI_box);
		tab_group_event.name = 'Events';

		#if LUA_ALLOWED
		var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
		var directories:Array<String> = [];

		directories.push(Paths.mods('custom_events/'));
		directories.push(Paths.mods(Paths.currentModDirectory + '/custom_events/'));
		for (mod in Paths.getGlobalMods())
			directories.push(Paths.mods(mod + '/custom_events/'));

		for (i in 0...directories.length)
		{
			var directory:String = directories[i];
			if (FileSystem.exists(directory))
			{
				for (file in FileSystem.readDirectory(directory))
				{
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file != 'readme.txt' && file.endsWith('.txt'))
					{
						var fileToCheck:String = file.substr(0, file.length - 4);
						if (!eventPushedMap.exists(fileToCheck))
						{
							eventPushedMap.set(fileToCheck, true);
							eventStuff.push([fileToCheck, File.getContent(path)]);
						}
					}
				}
			}
		}
		eventPushedMap.clear();
		eventPushedMap = null;
		#end

		descText = new FlxText(20, 200, 0, eventStuff[0][0]);

		var leEvents:Array<String> = [];
		for (i in 0...eventStuff.length)
		{
			leEvents.push(eventStuff[i][0]);
		}

		var text:FlxText = new FlxText(20, 30, 0, "Event:");
		tab_group_event.add(text);
		eventDropDown = new FlxUIDropDownMenuCustom(20, 50, FlxUIDropDownMenuCustom.makeStrIdLabelArray(leEvents, true), function(pressed:String)
		{
			var selectedEvent:Int = Std.parseInt(pressed);
			descText.text = eventStuff[selectedEvent][1];
			if (curSelectedNote != null && eventStuff != null)
			{
				if (curSelectedNote != null && curSelectedNote[2] == null)
				{
					curSelectedNote[1][curEventSelected][0] = eventStuff[selectedEvent][0];
				}
				updateGrid(false);
			}
		});
		blockPressWhileScrolling.push(eventDropDown);

		var text:FlxText = new FlxText(20, 90, 0, "Value 1:");
		tab_group_event.add(text);
		value1InputText = new FlxUIInputText(20, 110, 100, "");
		blockPressWhileTypingOn.push(value1InputText);

		var text:FlxText = new FlxText(20, 130, 0, "Value 2:");
		tab_group_event.add(text);
		value2InputText = new FlxUIInputText(20, 150, 100, "");
		blockPressWhileTypingOn.push(value2InputText);

		// New event buttons
		var removeButton:FlxButton = new FlxButton(eventDropDown.x + eventDropDown.width + 10, eventDropDown.y, '-', function()
		{
			if (curSelectedNote != null && curSelectedNote[2] == null) // Is event note
			{
				if (curSelectedNote[1].length < 2)
				{
					_song.events.remove(curSelectedNote);
					curSelectedNote = null;
				}
				else
				{
					curSelectedNote[1].remove(curSelectedNote[1][curEventSelected]);
				}

				var eventsGroup:Array<Dynamic>;
				--curEventSelected;
				if (curEventSelected < 0)
					curEventSelected = 0;
				else if (curSelectedNote != null && curEventSelected >= (eventsGroup = curSelectedNote[1]).length)
					curEventSelected = eventsGroup.length - 1;

				changeEventSelected();
				updateGrid(false);
			}
		});
		removeButton.setGraphicSize(Std.int(removeButton.height), Std.int(removeButton.height));
		removeButton.updateHitbox();
		removeButton.color = FlxColor.RED;
		removeButton.label.color = FlxColor.WHITE;
		removeButton.label.size = 12;
		setAllLabelsOffset(removeButton, -30, 0);
		tab_group_event.add(removeButton);

		var addButton:FlxButton = new FlxButton(removeButton.x + removeButton.width + 10, removeButton.y, '+', function()
		{
			if (curSelectedNote != null && curSelectedNote[2] == null) // Is event note
			{
				var eventsGroup:Array<Dynamic> = curSelectedNote[1];
				eventsGroup.push(['', '', '']);

				changeEventSelected(1);
				updateGrid(false);
			}
		});
		addButton.setGraphicSize(Std.int(removeButton.width), Std.int(removeButton.height));
		addButton.updateHitbox();
		addButton.color = FlxColor.GREEN;
		addButton.label.color = FlxColor.WHITE;
		addButton.label.size = 12;
		setAllLabelsOffset(addButton, -30, 0);
		tab_group_event.add(addButton);

		var moveLeftButton:FlxButton = new FlxButton(addButton.x + addButton.width + 20, addButton.y, '<', function()
		{
			changeEventSelected(-1);
		});
		moveLeftButton.setGraphicSize(Std.int(addButton.width), Std.int(addButton.height));
		moveLeftButton.updateHitbox();
		moveLeftButton.label.size = 12;
		setAllLabelsOffset(moveLeftButton, -30, 0);
		tab_group_event.add(moveLeftButton);

		var moveRightButton:FlxButton = new FlxButton(moveLeftButton.x + moveLeftButton.width + 10, moveLeftButton.y, '>', function()
		{
			changeEventSelected(1);
		});
		moveRightButton.setGraphicSize(Std.int(moveLeftButton.width), Std.int(moveLeftButton.height));
		moveRightButton.updateHitbox();
		moveRightButton.label.size = 12;
		setAllLabelsOffset(moveRightButton, -30, 0);
		tab_group_event.add(moveRightButton);

		selectedEventText = new FlxText(addButton.x - 100, addButton.y + addButton.height + 6, (moveRightButton.x - addButton.x) + 186,
			'Selected Event: None');
		selectedEventText.alignment = CENTER;
		tab_group_event.add(selectedEventText);

		tab_group_event.add(descText);
		tab_group_event.add(value1InputText);
		tab_group_event.add(value2InputText);
		tab_group_event.add(eventDropDown);

		UI_box.addGroup(tab_group_event);
	}

	function changeEventSelected(change:Int = 0)
	{
		if (curSelectedNote != null && curSelectedNote[2] == null) // Is event note
		{
			curEventSelected += change;
			if (curEventSelected < 0)
				curEventSelected = Std.int(curSelectedNote[1].length) - 1;
			else if (curEventSelected >= curSelectedNote[1].length)
				curEventSelected = 0;
			selectedEventText.text = 'Selected Event: ' + (curEventSelected + 1) + ' / ' + curSelectedNote[1].length;
		}
		else
		{
			curEventSelected = 0;
			selectedEventText.text = 'Selected Event: None';
		}
		updateNoteUI();
	}

	function setAllLabelsOffset(button:FlxButton, x:Float, y:Float)
	{
		for (point in button.labelOffsets)
		{
			point.set(x, y);
		}
	}

	var metronome:FlxUICheckBox;
	var mouseScrollingQuant:FlxUICheckBox;
	var metronomeStepper:FlxUINumericStepper;
	var metronomeOffsetStepper:FlxUINumericStepper;
	var disableAutoScrolling:FlxUICheckBox;
	var waveformUseInstrumental:FlxUICheckBox;
	var waveformUseVoices:FlxUICheckBox;
	var waveformUseVoicesLeft:FlxUICheckBox;
	var waveformUseVoicesRight:FlxUICheckBox;
	var instVolume:FlxUINumericStepper;
	var voicesVolume:FlxUINumericStepper;
	var voicesLeftVolume:FlxUINumericStepper;
	var voicesRightVolume:FlxUINumericStepper;
	var extraVolume:FlxUINumericStepper;

	function addChartingUI()
	{
		var tab_group_chart = new FlxUI(null, UI_box);
		tab_group_chart.name = 'Charting';

		if (FlxG.save.data.chart_waveformInst == null)
			FlxG.save.data.chart_waveformInst = false;
		if (FlxG.save.data.chart_waveformVoices == null)
			FlxG.save.data.chart_waveformVoices = false;

		waveformUseInstrumental = new FlxUICheckBox(10, 90, null, null, "Waveform for Instrumental", 100);
		waveformUseInstrumental.checked = FlxG.save.data.chart_waveformInst;
		waveformUseInstrumental.callback = function()
		{
			if (splitVocals)
			{
				waveformUseVoicesLeft.checked = false;
				waveformUseVoicesRight.checked = false;
				FlxG.save.data.chart_waveformVoicesLeft = false;
				FlxG.save.data.chart_waveformVoicesRight = false;
			}
			else
				waveformUseVoices.checked = false;
				
			FlxG.save.data.chart_waveformVoices = false;
			FlxG.save.data.chart_waveformInst = waveformUseInstrumental.checked;
			updateWaveform();
		};

		if (splitVocals)
		{
			waveformUseVoicesLeft = new FlxUICheckBox(waveformUseInstrumental.x + 120, waveformUseInstrumental.y, null, null, "Waveform for Voices (Left)", 100);
			waveformUseVoicesLeft.checked = FlxG.save.data.chart_waveformVoicesLeft;
			waveformUseVoicesLeft.callback = function()
			{
				waveformUseInstrumental.checked = false;
				waveformUseVoicesRight.checked = false;
				FlxG.save.data.chart_waveformInst = false;
				FlxG.save.data.chart_waveformVoices = false;
				FlxG.save.data.chart_waveformVoicesRight = false;
				FlxG.save.data.chart_waveformVoicesLeft = waveformUseVoicesLeft.checked;
				updateWaveform();
			};

			waveformUseVoicesRight = new FlxUICheckBox(waveformUseInstrumental.x + 120, 120, null, null, "Waveform for Voices (Right)", 100);
			waveformUseVoicesRight.checked = FlxG.save.data.chart_waveformVoicesRight;
			waveformUseVoicesRight.callback = function()
			{
				waveformUseInstrumental.checked = false;
				waveformUseVoicesLeft.checked = false;
				FlxG.save.data.chart_waveformInst = false;
				FlxG.save.data.chart_waveformVoices = false;
				FlxG.save.data.chart_waveformVoicesLeft = false;
				FlxG.save.data.chart_waveformVoicesRight = waveformUseVoicesRight.checked;
				updateWaveform();
			};
		}
		else
		{
			waveformUseVoices = new FlxUICheckBox(waveformUseInstrumental.x + 120, waveformUseInstrumental.y, null, null, "Waveform for Voices", 100);
			waveformUseVoices.checked = FlxG.save.data.chart_waveformVoices;
			waveformUseVoices.callback = function()
			{
				waveformUseInstrumental.checked = false;
				FlxG.save.data.chart_waveformInst = false;
				FlxG.save.data.chart_waveformVoicesLeft = false;
				FlxG.save.data.chart_waveformVoicesRight = false;
				FlxG.save.data.chart_waveformVoices = waveformUseVoices.checked;
				updateWaveform();
			};
		}

		check_mute_inst = new FlxUICheckBox(10, 310, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};
		mouseScrollingQuant = new FlxUICheckBox(10, 200, null, null, "Mouse Scrolling Quantization", 100);
		if (FlxG.save.data.mouseScrollingQuant == null)
			FlxG.save.data.mouseScrollingQuant = false;
		mouseScrollingQuant.checked = FlxG.save.data.mouseScrollingQuant;

		mouseScrollingQuant.callback = function()
		{
			FlxG.save.data.mouseScrollingQuant = mouseScrollingQuant.checked;
			mouseQuant = FlxG.save.data.mouseScrollingQuant;
		};

		check_vortex = new FlxUICheckBox(10, 160, null, null, "Vortex Editor (BETA)", 100);
		if (FlxG.save.data.chart_vortex == null)
			FlxG.save.data.chart_vortex = false;
		check_vortex.checked = FlxG.save.data.chart_vortex;

		check_vortex.callback = function()
		{
			FlxG.save.data.chart_vortex = check_vortex.checked;
			vortex = FlxG.save.data.chart_vortex;
			reloadGridLayer();
		};

		check_warnings = new FlxUICheckBox(10, 120, null, null, "Ignore Progress Warnings", 100);
		if (FlxG.save.data.ignoreWarnings == null)
			FlxG.save.data.ignoreWarnings = false;
		check_warnings.checked = FlxG.save.data.ignoreWarnings;

		check_warnings.callback = function()
		{
			FlxG.save.data.ignoreWarnings = check_warnings.checked;
			ignoreWarnings = FlxG.save.data.ignoreWarnings;
		};

		var check_mute_vocals = new FlxUICheckBox(check_mute_inst.x + 120, check_mute_inst.y, null, null, "Mute Vocals (in editor)", 100);
		check_mute_vocals.checked = false;
		check_mute_vocals.callback = function()
		{
			if (splitVocals)
			{
				if (vocalsLeft != null)
					vocalsLeft.volume = check_mute_vocals.checked ? 0 : 1;
				if (vocalsRight != null)
					vocalsRight.volume = check_mute_vocals.checked ? 0 : 1;
			}
			else
			{
				if (vocals != null)
					vocals.volume = check_mute_vocals.checked ? 0 : 1;
			}

			if (songExtra != null) 
				songExtra.volume = check_mute_vocals.checked ? 0 : 1;
		};

		playSoundBf = new FlxUICheckBox(check_mute_inst.x, check_mute_vocals.y + 30, null, null, 'Play Sound (Who\'s notes?)', 100, function()
		{
			FlxG.save.data.chart_playSoundBf = playSoundBf.checked;
		});
		if (FlxG.save.data.chart_playSoundBf == null)
			FlxG.save.data.chart_playSoundBf = false;
		playSoundBf.checked = FlxG.save.data.chart_playSoundBf;

		playSoundDad = new FlxUICheckBox(check_mute_inst.x + 120, playSoundBf.y, null, null, 'Play Sound (Opponent notes)', 100, function()
		{
			FlxG.save.data.chart_playSoundDad = playSoundDad.checked;
		});
		if (FlxG.save.data.chart_playSoundDad == null)
			FlxG.save.data.chart_playSoundDad = false;
		playSoundDad.checked = FlxG.save.data.chart_playSoundDad;

		metronome = new FlxUICheckBox(10, 15, null, null, "Metronome Enabled", 100, function()
		{
			FlxG.save.data.chart_metronome = metronome.checked;
		});
		if (FlxG.save.data.chart_metronome == null)
			FlxG.save.data.chart_metronome = false;
		metronome.checked = FlxG.save.data.chart_metronome;

		metronomeStepper = new FlxUINumericStepper(15, 55, 5, _song.bpm, 1, 1500, 1);
		metronomeOffsetStepper = new FlxUINumericStepper(metronomeStepper.x + 100, metronomeStepper.y, 25, 0, 0, 1000, 1);
		blockPressWhileTypingOnStepper.push(metronomeStepper);
		blockPressWhileTypingOnStepper.push(metronomeOffsetStepper);

		disableAutoScrolling = new FlxUICheckBox(metronome.x + 120, metronome.y, null, null, "Disable Autoscroll (Not Recommended)", 120, function()
		{
			FlxG.save.data.chart_noAutoScroll = disableAutoScrolling.checked;
		});
		if (FlxG.save.data.chart_noAutoScroll == null)
			FlxG.save.data.chart_noAutoScroll = false;
		disableAutoScrolling.checked = FlxG.save.data.chart_noAutoScroll;

		instVolume = new FlxUINumericStepper(metronomeStepper.x, 230, 0.1, 1, 0, 1, 1);
		instVolume.value = FlxG.sound.music.volume;
		instVolume.name = 'inst_volume';
		blockPressWhileTypingOnStepper.push(instVolume);

		var lois:Float = instVolume.y + 20;
		if (splitVocals)
		{
			voicesLeftVolume = new FlxUINumericStepper(instVolume.x, instVolume.y + 20, 0.1, 1, 0, 1, 1);
			voicesLeftVolume.value = vocalsLeft.volume;
			voicesLeftVolume.name = 'voices_left_volume';
			blockPressWhileTypingOnStepper.push(voicesLeftVolume);

			voicesRightVolume = new FlxUINumericStepper(voicesLeftVolume.x, voicesLeftVolume.y + 20, 0.1, 1, 0, 1, 1);
			voicesRightVolume.value = vocalsRight.volume;
			voicesRightVolume.name = 'voices_right_volume';
			blockPressWhileTypingOnStepper.push(voicesLeftVolume);

			lois = voicesRightVolume.y;
		}
		else
		{
			voicesVolume = new FlxUINumericStepper(instVolume.x, instVolume.y + 20, 0.1, 1, 0, 1, 1);
			voicesVolume.value = vocals.volume;
			voicesVolume.name = 'voices_volume';
			blockPressWhileTypingOnStepper.push(voicesVolume);
		}

		extraVolume = new FlxUINumericStepper(instVolume.x, lois + 20, 0.1, 1, 0, 1, 1);
		extraVolume.value = songExtra.volume;
		extraVolume.name = 'extras_volume';
		blockPressWhileTypingOnStepper.push(extraVolume);

		tab_group_chart.add(new FlxText(metronomeStepper.x, metronomeStepper.y - 15, 0, 'BPM:'));
		tab_group_chart.add(new FlxText(metronomeOffsetStepper.x, metronomeOffsetStepper.y - 15, 0, 'Offset (ms):'));
		tab_group_chart.add(new FlxText(instVolume.x + instVolume.width + 10, instVolume.y, 0, 'Inst Volume'));
		if(splitVocals)
		{
			tab_group_chart.add(new FlxText(voicesLeftVolume.x + voicesLeftVolume.width + 10, voicesLeftVolume.y, 0, 'Voices Volume (Left)'));
			tab_group_chart.add(new FlxText(voicesRightVolume.x + voicesRightVolume.width + 10, voicesRightVolume.y, 0, 'Voices Volume (Right)'));
		}
		else
			tab_group_chart.add(new FlxText(voicesVolume.x + voicesVolume.width + 10, voicesVolume.y, 0, 'Voices Volume'));
		tab_group_chart.add(new FlxText(extraVolume.x + extraVolume.width + 10, extraVolume.y, 0, 'Extra Volume'));
		tab_group_chart.add(metronome);
		tab_group_chart.add(disableAutoScrolling);
		tab_group_chart.add(metronomeStepper);
		tab_group_chart.add(metronomeOffsetStepper);
		tab_group_chart.add(waveformUseInstrumental);
		if (splitVocals)
		{
			tab_group_chart.add(waveformUseVoicesLeft);
			tab_group_chart.add(waveformUseVoicesRight);
		}
		else
			tab_group_chart.add(waveformUseVoices);
		tab_group_chart.add(instVolume);
		if (splitVocals)
		{
			tab_group_chart.add(voicesLeftVolume);
			tab_group_chart.add(voicesRightVolume);
		}
		else
			tab_group_chart.add(voicesVolume);
		tab_group_chart.add(extraVolume);
		tab_group_chart.add(check_mute_inst);
		tab_group_chart.add(check_mute_vocals);
		tab_group_chart.add(check_vortex);
		tab_group_chart.add(mouseScrollingQuant);
		tab_group_chart.add(check_warnings);
		tab_group_chart.add(playSoundBf);
		tab_group_chart.add(playSoundDad);
		UI_box.addGroup(tab_group_chart);
	}

	function loadSong():Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		if (splitVocals)
		{
			if (leftSingParam == null)
				trace("uh oh, left sing param's null! (using character's name instead)");

			var file:Dynamic = Paths.voices(currentSongName, _song.audioPostfix, '-left', (leftSingParam != null ? leftSingParam : _song.player2));
			vocalsLeft = new FlxSound();
			if (Std.isOfType(file, Sound) || OpenFlAssets.exists(file))
			{
				vocalsLeft.loadEmbedded(file);
				FlxG.sound.list.add(vocalsLeft);
			}

			if (rightSingParam == null)
				trace("uh oh, right sing param's null! (using character's name instead)");

			file = Paths.voices(currentSongName, _song.audioPostfix, '-right', (rightSingParam != null ? rightSingParam : _song.player1));
			vocalsRight = new FlxSound();
			if (Std.isOfType(file, Sound) || OpenFlAssets.exists(file))
			{
				vocalsRight.loadEmbedded(file);
				FlxG.sound.list.add(vocalsRight);
			}
		}
		else
		{
			var file:Dynamic = Paths.voices(currentSongName, _song.audioPostfix);
			vocals = new FlxSound();
			if (Std.isOfType(file, Sound) || OpenFlAssets.exists(file))
			{
				vocals.loadEmbedded(file);
				FlxG.sound.list.add(vocals);
			}
		}
		var file:Dynamic = Paths.songExtra(currentSongName, _song.audioPostfix);
		songExtra = new FlxSound();
		if (Std.isOfType(file, Sound) || OpenFlAssets.exists(file))
		{
			songExtra.loadEmbedded(file);
			FlxG.sound.list.add(songExtra);
		}

		generateSong();
		FlxG.sound.music.pause();
		Conductor.songPosition = sectionStartTime();
		FlxG.sound.music.time = Conductor.songPosition;
	}

	function generateSong()
	{
		FlxG.sound.playMusic(Paths.inst(currentSongName, _song.audioPostfix), 0.6 /*, false*/);
		if (instVolume != null)
			FlxG.sound.music.volume = instVolume.value;
		if (check_mute_inst != null && check_mute_inst.checked)
			FlxG.sound.music.volume = 0;

		FlxG.sound.music.onComplete = function()
		{
			FlxG.sound.music.pause();
			Conductor.songPosition = 0;
			if (splitVocals)
			{
				if (vocalsLeft != null && vocalsRight != null)
				{
					vocalsLeft.pause();
					vocalsRight.pause();
					vocalsLeft.time = 0;
					vocalsRight.time = 0;
				}
			}
			else
			{
				if (vocals != null)
				{
					vocals.pause();
					vocals.time = 0;
				}
			}
			if (songExtra != null)
			{
				songExtra.pause();
				songExtra.time = 0;
			}
			changeSection();
			curSec = 0;
			updateGrid();
			updateSectionUI();
			if (splitVocals)
			{
				vocalsLeft.play();
				vocalsRight.play();
			}
			else
				vocals.play();
			songExtra.play();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSec].mustHitSection = check.checked;

					updateGrid(false);
					updateHeads();

				case 'GF section':
					_song.notes[curSec].gfSection = check.checked;

					updateGrid(false);
					updateHeads();

				case 'Change BPM':
					_song.notes[curSec].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSec].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_beats')
			{
				_song.notes[curSec].sectionBeats = nums.value;
				reloadGridLayer();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = nums.value;
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(nums.value);
			}
			else if (wname == 'song_keycount')
			{
				_song.mania = Note.keyCountToMania(Std.int(nums.value));
				reloadGridLayer();
			}
			else if (wname == 'note_susLength')
			{
				if (curSelectedNote != null && curSelectedNote[1] > -1)
				{
					curSelectedNote[2] = nums.value;
					lazyUpdateGrid(Std.int(Conductor.getBeatRounded(curSelectedNote[0])), curSelectedNote[1]);
				}
				else
				{
					sender.value = 0;
				}
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSec].bpm = nums.value;
				updateGrid(false);
			}
			else if (wname == 'inst_volume')
			{
				FlxG.sound.music.volume = nums.value;
			}
			else if (wname == 'voices_volume')
			{
				vocals.volume = nums.value;
			}
			else if (wname == 'voices_left_volume')
			{
				vocalsLeft.volume = nums.value;
			}
			else if (wname == 'voices_right_volume')
			{
				vocalsRight.volume = nums.value;
			}
			else if (wname == 'extra_volume')
			{
				songExtra.volume = nums.value;
			}
		}
		else if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText))
		{
			if (sender == noteSplashesInputText)
			{
				_song.splashSkin = noteSplashesInputText.text;
			}
			else if (curSelectedNote != null && curSelectedNote[1] != null && curSelectedNote[1][curEventSelected] != null)
			{
				if (sender == value1InputText && value1InputText.text != null)
				{
					curSelectedNote[1][curEventSelected][1] = value1InputText.text;
				}
				else if (sender == value2InputText && value2InputText.text != null)
				{
					curSelectedNote[1][curEventSelected][2] = value2InputText.text;
				}
				else if (sender == strumTimeInputText)
				{
					var value:Float = Std.parseFloat(strumTimeInputText.text);
					if (Math.isNaN(value))
						value = 0;
					curSelectedNote[0] = value;
				}
				lazyUpdateGrid(-1, -1);
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	function sectionStartTime(add:Int = 0):Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSec + add)
		{
			if (_song.notes[i] != null)
			{
				if (_song.notes[i].changeBPM)
				{
					daBPM = _song.notes[i].bpm;
				}
				daPos += getSectionBeats(i) * (1000 * 60 / daBPM);
			}
		}
		return daPos;
	}

	function getSectionBPM(?add:Int = 0)
	{
		var daBPM:Float = _song.bpm;
		for (i in 0...curSec + add)
			if (_song.notes[i] != null && _song.notes[i].changeBPM)
				daBPM = _song.notes[i].bpm;
		return daBPM;
	}

	var lastConductorPos:Float;
	var colorSine:Float = 0;

	override function update(elapsed:Float)
	{
		// curRenderedNoteType.clear();
		curStep = recalculateSteps();

		if (FlxG.sound.music.time < 0)
		{
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
		}
		else if (FlxG.sound.music.time > FlxG.sound.music.length)
		{
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = UI_songTitle.text;

		strumLineUpdateY();
		for (i in 0...strumLineNotes.length)
		{
			var strY:Float = strumLine.y;
			// COMPILER SHUT UP ABOUT THIS LINE ISTG
			// "compiler shut up about this line istg" 🤓
			if (strumLineNotes.members != null && strumLineNotes.members[i] != null)
				strumLineNotes.members[i].y = strY;
		}

		FlxG.mouse.visible = true; // cause reasons. trust me
		camPos.y = strumLine.y;
		if (!disableAutoScrolling.checked)
		{
			if (Math.ceil(strumLine.y) >= gridBG.height)
			{
				if (_song.notes[curSec + 1] == null)
				{
					addSection();
				}

				changeSection(curSec + 1, false);
			}
			else if (strumLine.y < -10)
			{
				changeSection(curSec - 1, false);
			}
		}
		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * getSectionBeats() * 4) * zoomList[curZoom])
		{
			dummyArrow.visible = true;
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
			{
				var gridmult = GRID_SIZE / (quantization / 16);
				dummyArrow.y = Math.floor(FlxG.mouse.y / gridmult) * gridmult;
			}
		}
		else
		{
			dummyArrow.visible = false;
		}

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEachAlive(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else if (FlxG.keys.pressed.ALT)
						{
							selectNote(note);
							curSelectedNote[3] = noteTypeIntMap.get(currentType);
							lazyUpdateGrid(Std.int(Conductor.getBeatRounded(curSelectedNote[0])), curSelectedNote[1]);
						}
						else
						{
							// trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * getSectionBeats() * 4) * zoomList[curZoom])
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn)
		{
			if (inputText.hasFocus)
			{
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;
				break;
			}
		}

		if (!blockInput)
		{
			for (stepper in blockPressWhileTypingOnStepper)
			{
				@:privateAccess
				var leText:Dynamic = stepper.text_field;
				var leText:FlxUIInputText = leText;
				if (leText.hasFocus)
				{
					FlxG.sound.muteKeys = [];
					FlxG.sound.volumeDownKeys = [];
					FlxG.sound.volumeUpKeys = [];
					blockInput = true;
					break;
				}
			}
		}

		if (!blockInput)
		{
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
			for (dropDownMenu in blockPressWhileScrolling)
			{
				if (dropDownMenu.dropPanel.visible)
				{
					blockInput = true;
					break;
				}
			}
		}

		if (!blockInput)
		{
			if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.ENTER)
			{
				autosaveSong();
				FlxG.mouse.visible = false;
				PlayState.SONG = _song;
				FlxG.sound.music.stop();
				if (splitVocals)
				{
					if (vocalsLeft != null && vocalsRight != null)
					{
						vocalsLeft.stop();
						vocalsRight.stop();
					}
				}
				else
				{
					if (vocals != null)
						vocals.stop();
				}

				if (songExtra != null)
					songExtra.stop();

				// if(_song.stage == null) _song.stage = stageDropDown.selectedLabel;
				StageData.loadDirectory(_song);
				LoadingState.loadAndSwitchState(new PlayState());
			}

			if (curSelectedNote != null && curSelectedNote[1] > -1)
			{
				if (FlxG.keys.justPressed.E)
				{
					changeNoteSustain(Conductor.stepCrochet);
				}
				if (FlxG.keys.justPressed.Q)
				{
					changeNoteSustain(-Conductor.stepCrochet);
				}
			}

			if (FlxG.keys.justPressed.BACKSPACE)
			{
				// if(onMasterEditor) {
				MusicBeatState.switchState(new editors.MasterEditorMenu());
				CoolUtil.playMenuTheme();
				// }
				FlxG.mouse.visible = false;
				return;
			}

			if (FlxG.keys.justPressed.Z && FlxG.keys.pressed.CONTROL)
			{
				undo();
			}

			if (FlxG.keys.justPressed.Z && curZoom > 0 && !FlxG.keys.pressed.CONTROL)
			{
				--curZoom;
				updateZoom();
			}
			if (FlxG.keys.justPressed.X && curZoom < zoomList.length - 1)
			{
				curZoom++;
				updateZoom();
			}

			if (FlxG.keys.justPressed.TAB)
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					UI_box.selected_tab -= 1;
					if (UI_box.selected_tab < 0)
						UI_box.selected_tab = 2;
				}
				else
				{
					UI_box.selected_tab += 1;
					if (UI_box.selected_tab >= 3)
						UI_box.selected_tab = 0;
				}
			}

			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					if (splitVocals)
					{
						if (vocalsLeft != null && vocalsRight != null)
						{
							vocalsLeft.pause();
							vocalsRight.pause();
						}
					}
					else
					{
						if (vocals != null)
							vocals.pause();
					}
					if (songExtra != null)
						songExtra.pause();
				}
				else
				{
					if (splitVocals)
					{
						if (vocalsLeft != null && vocalsRight != null)
							{
								//vocals.play(); 
								//vocals.pause();
								vocalsLeft.time = FlxG.sound.music.time;
								vocalsRight.time = FlxG.sound.music.time;
								vocalsLeft.play();
								vocalsRight.play();
							}
					}
					else
					{
						if (vocals != null)
							{
								//vocals.play();
								//vocals.pause();
								vocals.time = FlxG.sound.music.time;
								vocals.play();
							}
					}
					if (songExtra != null)
					{
						songExtra.time = FlxG.sound.music.time;
						songExtra.play();
					}
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				if (!mouseQuant)
					FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.8);
				else
				{
					var time:Float = FlxG.sound.music.time;
					var beat:Float = curDecBeat;
					var snap:Float = quantization / 4;
					var increase:Float = 1 / snap;
					if (FlxG.mouse.wheel > 0)
					{
						var fuck:Float = CoolUtil.quantize(beat, snap) - increase;
						FlxG.sound.music.time = Conductor.beatToSeconds(fuck);
					}
					else
					{
						var fuck:Float = CoolUtil.quantize(beat, snap) + increase;
						FlxG.sound.music.time = Conductor.beatToSeconds(fuck);
					}
				}
				if (splitVocals)
				{
					if (vocalsLeft != null && vocalsRight != null) //please help me this is so borin g
					{
						vocalsLeft.pause();
						vocalsRight.pause();
						vocalsLeft.time = FlxG.sound.music.time;
						vocalsRight.time = FlxG.sound.music.time;
					}
				}
				else
				{
					if (vocals != null)
					{
						vocals.pause();
						vocals.time = FlxG.sound.music.time;
					}
				}
				if (songExtra != null)
				{
					songExtra.pause();
					songExtra.time = FlxG.sound.music.time;
				}
			}

			// ARROW VORTEX SHIT NO DEADASS

			if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
			{
				FlxG.sound.music.pause();

				var holdingShift:Float = 1;
				if (FlxG.keys.pressed.CONTROL)
					holdingShift = 0.25;
				else if (FlxG.keys.pressed.SHIFT)
					holdingShift = 4;

				var daTime:Float = 700 * FlxG.elapsed * holdingShift;

				if (FlxG.keys.pressed.W)
				{
					FlxG.sound.music.time -= daTime;
				}
				else
					FlxG.sound.music.time += daTime;

				if (splitVocals)
				{
					if (vocalsLeft != null && vocalsRight != null) 
						{
							vocalsLeft.pause();
							vocalsRight.pause();
							vocalsLeft.time = FlxG.sound.music.time;
							vocalsRight.time = FlxG.sound.music.time;
						}
				}
				else
				{
					if (vocals != null) //why are there so many of these why are there so many of these why are there so many of these why are there so many of these why are there so many of these
						{
							vocals.pause();
							vocals.time = FlxG.sound.music.time;
						}
				}
				if (songExtra != null)
				{
					songExtra.pause();
					songExtra.time = FlxG.sound.music.time;
				}
			}

			if (!vortex)
			{
				if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
				{
					FlxG.sound.music.pause();
					updateCurStep();
					var time:Float = FlxG.sound.music.time;
					var beat:Float = curDecBeat;
					var snap:Float = quantization / 4;
					var increase:Float = 1 / snap;
					if (FlxG.keys.pressed.UP)
					{
						var fuck:Float = CoolUtil.quantize(beat, snap) - increase; // (Math.floor((beat+snap) / snap) * snap);
						FlxG.sound.music.time = Conductor.beatToSeconds(fuck);
					}
					else
					{
						var fuck:Float = CoolUtil.quantize(beat, snap) + increase; // (Math.floor((beat+snap) / snap) * snap);
						FlxG.sound.music.time = Conductor.beatToSeconds(fuck);
					}
				}
			}

			var style = currentType;

			if (FlxG.keys.pressed.SHIFT)
			{
				style = 3;
			}

			var conductorTime = Conductor.songPosition; // + sectionStartTime();Conductor.songPosition / Conductor.stepCrochet;

			// AWW YOU MADE IT SEXY <3333 THX SHADMAR

			if (!blockInput)
			{
				if (FlxG.keys.justPressed.RIGHT)
				{
					curQuant++;
					if (curQuant > quantizations.length - 1)
						curQuant = 0;

					quantization = quantizations[curQuant];
				}

				if (FlxG.keys.justPressed.LEFT)
				{
					curQuant--;
					if (curQuant < 0)
						curQuant = quantizations.length - 1;

					quantization = quantizations[curQuant];
				}
				quant.animation.play('q', true, false, curQuant);
			}
			if (vortex && !blockInput)
			{
				var controlArray:Array<Bool> = [
					 FlxG.keys.justPressed.ONE, FlxG.keys.justPressed.TWO, FlxG.keys.justPressed.THREE, FlxG.keys.justPressed.FOUR,
					FlxG.keys.justPressed.FIVE, FlxG.keys.justPressed.SIX, FlxG.keys.justPressed.SEVEN, FlxG.keys.justPressed.EIGHT
				];

				if (controlArray.contains(true))
				{
					for (i in 0...controlArray.length)
					{
						if (controlArray[i])
							doANoteThing(conductorTime, i, style);
					}
				}

				var feces:Float;
				if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
				{
					FlxG.sound.music.pause();

					updateCurStep();
					// FlxG.sound.music.time = (Math.round(curStep/quants[curQuant])*quants[curQuant]) * Conductor.stepCrochet;

					// (Math.floor((curStep+quants[curQuant]*1.5/(quants[curQuant]/2))/quants[curQuant])*quants[curQuant]) * Conductor.stepCrochet;//snap into quantization
					// var time:Float = FlxG.sound.music.time;
					var beat:Float = curDecBeat;
					var snap:Float = quantization / 4;
					var increase:Float = 1 / snap;
					if (FlxG.keys.pressed.UP)
					{
						var fuck:Float = CoolUtil.quantize(beat, snap) - increase;
						feces = Conductor.beatToSeconds(fuck);
					}
					else
					{
						var fuck:Float = CoolUtil.quantize(beat, snap) + increase; // (Math.floor((beat+snap) / snap) * snap);
						feces = Conductor.beatToSeconds(fuck);
					}

					// FlxTween.tween(FlxG.sound.music, {time: feces}, 0.1, {ease: FlxEase.circOut});
					FlxG.sound.music.time = feces;

					if (splitVocals)
					{
						if (vocalsLeft != null && vocalsRight != null)
						{
							vocalsLeft.pause();
							vocalsRight.pause();
							vocalsLeft.time = FlxG.sound.music.time;
							vocalsRight.time = FlxG.sound.music.time;
						}
					}
					else
					{
						if (vocals != null) //insert internal screaming here
						{
							vocals.pause();
							vocals.time = FlxG.sound.music.time;
						}
					}
					if (songExtra != null)
					{
						songExtra.pause();
						songExtra.time = FlxG.sound.music.time;
					}

					var dastrum = 0;

					if (curSelectedNote != null)
					{
						dastrum = curSelectedNote[0];
					}

					var secStart:Float = sectionStartTime();
					var datime = (feces - secStart) - (dastrum - secStart); // idk math find out why it doesn't work on any other section other than 0
					if (curSelectedNote != null)
					{
						var controlArray:Array<Bool> = [
							 FlxG.keys.pressed.ONE, FlxG.keys.pressed.TWO, FlxG.keys.pressed.THREE, FlxG.keys.pressed.FOUR,
							FlxG.keys.pressed.FIVE, FlxG.keys.pressed.SIX, FlxG.keys.pressed.SEVEN, FlxG.keys.pressed.EIGHT
						];

						if (controlArray.contains(true))
						{
							for (i in 0...controlArray.length)
							{
								if (controlArray[i])
									if (curSelectedNote[1] == i)
										curSelectedNote[2] += datime - curSelectedNote[2] - Conductor.stepCrochet;
							}
							lazyUpdateGrid(Std.int(Conductor.getBeatRounded(curSelectedNote[0])), curSelectedNote[1]);
							updateNoteUI();
						}
					}
				}
			}
			var shiftThing:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;

			if (FlxG.keys.justPressed.D)
				changeSection(curSec + shiftThing);
			if (FlxG.keys.justPressed.A)
			{
				if (curSec <= 0)
				{
					changeSection(_song.notes.length - 1);
				}
				else
				{
					changeSection(curSec - shiftThing);
				}
			}
		}
		else if (FlxG.keys.justPressed.ENTER)
		{
			for (i in 0...blockPressWhileTypingOn.length)
			{
				if (blockPressWhileTypingOn[i].hasFocus)
				{
					blockPressWhileTypingOn[i].hasFocus = false;
				}
			}
		}

		_song.bpm = tempBpm;

		strumLineNotes.visible = quant.visible = vortex;

		if (FlxG.sound.music.time < 0)
		{
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
		}
		else if (FlxG.sound.music.time > FlxG.sound.music.length)
		{
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
		strumLineUpdateY();
		camPos.y = strumLine.y;
		for (i in 0...strumLineNotes.length)
		{
			if (strumLineNotes.members != null && strumLineNotes.members[i] != null)
			{
				strumLineNotes.members[i].y = strumLine.y;
				strumLineNotes.members[i].alpha = FlxG.sound.music.playing ? 1 : 0.35;
			}
		}

		bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSec
			+ "\n\nBeat: "
			+ Std.string(curDecBeat).substring(0, 4)
			+ "\n\nStep: "
			+ curStep
			+ "\n\nBeat Snap: "
			+ quantization
			+ "th";

		var playedSound:Array<Bool> = [false, false, false, false]; // Prevents ouchy GF sex sounds
		curRenderedNotes.forEachAlive(function(note:Note)
		{
			note.alpha = 1;
			if (curSelectedNote != null)
			{
				var noteDataToCheck:Int = note.noteData;
				if (noteDataToCheck > -1 && note.mustPress != _song.notes[curSec].mustHitSection)
					noteDataToCheck += getKeyCount();

				if (curSelectedNote[0] == note.strumTime
					&& ((curSelectedNote[2] == null && noteDataToCheck < 0)
						|| (curSelectedNote[2] != null && curSelectedNote[1] == noteDataToCheck)))
				{
					colorSine += elapsed;
					var colorVal:Float = 0.7 + Math.sin(Math.PI * colorSine) * 0.3;
					note.color = FlxColor.fromRGBFloat(colorVal, colorVal, colorVal,
						0.999); // Alpha can't be 100% or the color won't be updated for some reason, guess i will die
				}
			}

			if (note.strumTime <= Conductor.songPosition)
			{
				note.alpha = 0.4;
				if (note.strumTime > lastConductorPos && FlxG.sound.music.playing && note.noteData > -1)
				{
					var data:Int = note.noteData % getKeyCount();
					var noteDataToCheck:Int = note.noteData;
					if (noteDataToCheck > -1 && note.mustPress != _song.notes[curSec].mustHitSection)
						noteDataToCheck += getKeyCount();
					if (strumLineNotes.members[noteDataToCheck] != null)
					{
						strumLineNotes.members[noteDataToCheck].playAnim('confirm', true);
						strumLineNotes.members[noteDataToCheck].resetAnim = (note.sustainLength / 1000) + 0.15;
					}
					if (!playedSound[data])
					{
						if ((playSoundBf.checked && note.mustPress) || (playSoundDad.checked && !note.mustPress))
						{
							var soundToPlay = 'hitsound';
							if (_song.player1 == 'gf')
							{ // Easter egg
								soundToPlay = 'GF_' + Std.string(data + 1);
							}

							FlxG.sound.play(Paths.sound(soundToPlay)).pan = note.noteData < getKeyCount() ? -0.3 : 0.3; // would be coolio
							playedSound[data] = true;
						}

						data = note.noteData;
						if (note.mustPress != _song.notes[curSec].mustHitSection)
						{
							data += getKeyCount();
						}
					}
				}
			}
		});

		if (metronome.checked && lastConductorPos != Conductor.songPosition)
		{
			var metroInterval:Float = 60 / metronomeStepper.value;
			var metroStep:Int = Math.floor(((Conductor.songPosition + metronomeOffsetStepper.value) / metroInterval) / 1000);
			var lastMetroStep:Int = Math.floor(((lastConductorPos + metronomeOffsetStepper.value) / metroInterval) / 1000);
			if (metroStep != lastMetroStep)
			{
				FlxG.sound.play(Paths.sound('Metronome_Tick'));
				// trace('Ticked');
			}
		}
		lastConductorPos = Conductor.songPosition;
		super.update(elapsed);

		for (i in curRenderedNotes)
		{
			var ind = i.noteData % (getKeyCount() * 2);
			if (i.noteData != -1 && i.mustPress != _song.notes[curSec].mustHitSection)
				ind += getKeyCount();

			if (i.noteData == -1)
				i.x = gridBG.x;
			if (strumLineNotes.members[ind] != null)
				i.x = strumLineNotes.members[ind].x;
		}
		for (i in curRenderedSustains)
		{
			var ind = i.parentNote.noteData % (getKeyCount() * 2);
			if (i.parentNote.noteData != -1 && i.parentNote.mustPress != _song.notes[curSec].mustHitSection)
				ind += getKeyCount();

			if (i.parentNote.noteData == -1)
				i.x = gridBG.x;
			else if (strumLineNotes.members[ind] != null)
				i.x = strumLineNotes.members[ind].x + strumLineNotes.members[ind].width / 2 - i.width / 2;
		}

		for (i in nextRenderedNotes)
		{
			var ind = i.noteData % (getKeyCount() * 2);
			if (i.noteData != -1 && i.mustPress != _song.notes[curSec].mustHitSection)
				ind += getKeyCount();

			if (i.noteData == -1)
				i.x = gridBG.x;
			if (strumLineNotes.members[ind] != null)
				i.x = strumLineNotes.members[ind].x;
		}
		for (i in nextRenderedSustains)
		{
			var ind = i.parentNote.noteData % (getKeyCount() * 2);
			if (i.parentNote.noteData != -1 && i.parentNote.mustPress != _song.notes[curSec].mustHitSection)
				ind += getKeyCount();

			if (i.parentNote.noteData == -1)
				i.x = gridBG.x;
			else if (strumLineNotes.members[ind] != null)
				i.x = strumLineNotes.members[ind].x + strumLineNotes.members[ind].width / 2 - i.width / 2;
		}
	}

	function updateZoom()
	{
		var daZoom:Float = zoomList[curZoom];
		var zoomThing:String = '1 / ' + daZoom;
		if (daZoom < 1)
			zoomThing = Math.round(1 / daZoom) + ' / 1';
		zoomTxt.text = 'Zoom: ' + zoomThing;
		reloadGridLayer();
	}
	
	var lastSecBeats:Float = 0;
	var lastSecBeatsNext:Float = 0;

	function reloadGridLayer()
	{
		gridLayer.clear();
		var keyCount:Int = getKeyCount();
		PlayState.keyCount = keyCount;
		Note.reloadNoteStuffs();
		var gridRealWidth:Int = Std.int(GRID_SIZE * ((keyCount * 2) + 1));
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, gridRealWidth, Std.int(GRID_SIZE * getSectionBeats() * 4 * zoomList[curZoom]));
		// if (keyCount > 4)
		var realOFfset:Float = -(GRID_SIZE * 2 * (keyCount - 4));
		gridBG.x += realOFfset;
		if (gridBG.x < -GRID_SIZE * 6)
		{
			realOFfset += Math.abs(gridBG.x) - GRID_SIZE * 6;
			gridBG.x = -GRID_SIZE * 6;
		}

		if (FlxG.save.data.chart_waveformInst || FlxG.save.data.chart_waveformVoices)
			updateWaveform();

		eventIcon.setPosition(-GRID_SIZE - 5 + realOFfset, -90);
		leftIcon.setPosition(((GRID_SIZE * (getKeyCount() / 2)) + realOFfset - GRID_SIZE) + (GRID_SIZE / 2 - 45 / 2), -100);
		rightIcon.setPosition(((GRID_SIZE * (getKeyCount() + (getKeyCount() / 2))) + realOFfset - GRID_SIZE) + (GRID_SIZE / 2 - 45 / 2), -100);

		var leHeight:Int = Std.int(gridBG.height);
		var foundNextSec:Bool = false;
		if (sectionStartTime(1) <= FlxG.sound.music.length)
		{
			nextGridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, gridRealWidth, Std.int(GRID_SIZE * getSectionBeats(curSec + 1) * 4 * zoomList[curZoom]));
			leHeight = Std.int(gridBG.height + nextGridBG.height);
			foundNextSec = true;
		}
		else
			nextGridBG = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
		nextGridBG.x = gridBG.x;
		nextGridBG.y = gridBG.height;

		gridLayer.add(nextGridBG);
		gridLayer.add(gridBG);

		if (foundNextSec)
		{
			var gridBlack:FlxSprite = new FlxSprite(gridBG.x, gridBG.height).makeGraphic(gridRealWidth, Std.int(nextGridBG.height), FlxColor.BLACK);
			gridBlack.alpha = 0.4;
			gridLayer.add(gridBlack);
		}

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width - (GRID_SIZE * keyCount)).makeGraphic(2, leHeight, FlxColor.BLACK);
		gridLayer.add(gridBlackLine);

		for (i in 1...4)
		{
			var beatsep1:FlxSprite = new FlxSprite(gridBG.x, (GRID_SIZE * (4 * curZoom)) * i).makeGraphic(Std.int(gridBG.width), 1, 0x44FF0000);
			if (vortex)
			{
				gridLayer.add(beatsep1);
			}
		}

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + GRID_SIZE).makeGraphic(2, leHeight, FlxColor.BLACK);
		gridLayer.add(gridBlackLine);

		remove(strumLine);
		if (strumLine != null)
			strumLine.destroy();
		strumLine = new FlxSprite(realOFfset, 50).makeGraphic(gridRealWidth, 4);
		if (quant != null)
		{
			quant.sprTracker = strumLine;
			quant.x = gridBG.x + realOFfset;
			if (quant.x < 0)
				quant.x = 0;
		}
		add(strumLine);

		if (strumLineNotes != null)
		{
			var bruh:Array<StrumNote> = [];
			for (i in strumLineNotes)
				bruh.push(i);
			for (i in 0...bruh.length)
			{
				strumLineNotes.remove(bruh[i]);
				bruh[i].destroy();
			}
			for (i in 0...getKeyCount() * 2)
			{
				var note:StrumNote = new StrumNote(GRID_SIZE * (i + 1), strumLine.y, i % getKeyCount(), 0);
				note.setGraphicSize(GRID_SIZE, GRID_SIZE);
				note.updateHitbox();
				note.playAnim('static', true);
				strumLineNotes.add(note);
				note.scrollFactor.set(1, 1);
				note.x += realOFfset;
			}
		}

		updateGrid();

		lastSecBeats = getSectionBeats();
		if (sectionStartTime(1) > FlxG.sound.music.length)
			lastSecBeatsNext = 0;
		else
			getSectionBeats(curSec + 1);
	}

	function strumLineUpdateY()
	{
		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) / zoomList[curZoom] % (Conductor.stepCrochet * 16)) / (getSectionBeats() / 4);
	}

	var waveformPrinted:Bool = true;
	var wavData:Array<Array<Array<Float>>> = [[[0], [0]], [[0], [0]]];

	function updateWaveform()
	{
		if (waveformPrinted)
		{
			waveformSprite.makeGraphic(Std.int(GRID_SIZE * getKeyCount() * 2), Std.int(gridBG.height), 0x00FFFFFF);
			waveformSprite.pixels.fillRect(new Rectangle(0, 0, gridBG.width, gridBG.height), 0x00FFFFFF);
		}
		waveformPrinted = false;

		if ((!splitVocals && !FlxG.save.data.chart_waveformInst && !FlxG.save.data.chart_waveformVoices) 
			|| (splitVocals && !FlxG.save.data.chart_waveformInst && !FlxG.save.data.chart_waveformVoicesLeft && !FlxG.save.data.chart_waveformVoicesRight))
		{
			// trace('Epic fail on the waveform lol');
			return;
		}

		wavData[0][0] = [];
		wavData[0][1] = [];
		wavData[1][0] = [];
		wavData[1][1] = [];

		var steps:Int = Math.round(getSectionBeats() * 4);
		var st:Float = sectionStartTime();
		var et:Float = st + (Conductor.stepCrochet * steps);

		if (FlxG.save.data.chart_waveformInst)
		{
			var sound:FlxSound = FlxG.sound.music;
			if (sound._sound != null && sound._sound.__buffer != null)
			{
				var bytes:Bytes = sound._sound.__buffer.data.toBytes();

				wavData = waveformData(sound._sound.__buffer, bytes, st, et, 1, wavData, Std.int(gridBG.height));
			}
		}

		if (splitVocals)
		{
			if (FlxG.save.data.chart_waveformVoicesLeft)
			{
				var sound:FlxSound = vocalsLeft;
				if (sound._sound != null && sound._sound.__buffer != null)
				{
					var bytes:Bytes = sound._sound.__buffer.data.toBytes();
			
					wavData = waveformData(sound._sound.__buffer, bytes, st, et, 1, wavData, Std.int(gridBG.height));
				}
			}
		
			if (FlxG.save.data.chart_waveformVoicesRight)
			{
				var sound:FlxSound = vocalsRight;
				if (sound._sound != null && sound._sound.__buffer != null)
				{
					var bytes:Bytes = sound._sound.__buffer.data.toBytes();
				
					wavData = waveformData(sound._sound.__buffer, bytes, st, et, 1, wavData, Std.int(gridBG.height));
				}
			}
		}
		else
		{
			if (FlxG.save.data.chart_waveformVoices) //FINALLY something DIFFERENT
			{
				var sound:FlxSound = vocals;
				if (sound._sound != null && sound._sound.__buffer != null)
				{
					var bytes:Bytes = sound._sound.__buffer.data.toBytes();
		
					wavData = waveformData(sound._sound.__buffer, bytes, st, et, 1, wavData, Std.int(gridBG.height));
				}
			}
		}

		// Draws
		var gSize:Int = Std.int(GRID_SIZE * getKeyCount() * 2);
		var hSize:Int = Std.int(gSize / 2);

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var size:Float = 1;

		var leftLength:Int = (wavData[0][0].length > wavData[0][1].length ? wavData[0][0].length : wavData[0][1].length);

		var rightLength:Int = (wavData[1][0].length > wavData[1][1].length ? wavData[1][0].length : wavData[1][1].length);

		var length:Int = leftLength > rightLength ? leftLength : rightLength;

		var index:Int;
		for (i in 0...length)
		{
			index = i;

			lmin = FlxMath.bound(((index < wavData[0][0].length && index >= 0) ? wavData[0][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			lmax = FlxMath.bound(((index < wavData[0][1].length && index >= 0) ? wavData[0][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			rmin = FlxMath.bound(((index < wavData[1][0].length && index >= 0) ? wavData[1][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			rmax = FlxMath.bound(((index < wavData[1][1].length && index >= 0) ? wavData[1][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			waveformSprite.pixels.fillRect(new Rectangle(hSize - (lmin + rmin), i * size, (lmin + rmin) + (lmax + rmax), size), FlxColor.BLUE);
		}

		waveformPrinted = true;
	}

	function waveformData(buffer:AudioBuffer, bytes:Bytes, time:Float, endTime:Float, multiply:Float = 1, ?array:Array<Array<Array<Float>>>,
			?steps:Float):Array<Array<Array<Float>>>
	{
		#if (lime_cffi && !macro)
		if (buffer == null || buffer.data == null)
			return [[[0], [0]], [[0], [0]]];

		var khz:Float = (buffer.sampleRate / 1000);
		var channels:Int = buffer.channels;

		var index:Int = Std.int(time * khz);

		var samples:Float = ((endTime - time) * khz);

		if (steps == null)
			steps = 1280;

		var samplesPerRow:Float = samples / steps;
		var samplesPerRowI:Int = Std.int(samplesPerRow);

		var gotIndex:Int = 0;

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var rows:Float = 0;

		var simpleSample:Bool = true; // samples > 17200;
		var v1:Bool = false;

		if (array == null)
			array = [[[0], [0]], [[0], [0]]];

		while (index < (bytes.length - 1))
		{
			if (index >= 0)
			{
				var byte:Int = bytes.getUInt16(index * channels * 2);

				if (byte > 65535 / 2)
					byte -= 65535;

				var sample:Float = (byte / 65535);

				if (sample > 0)
				{
					if (sample > lmax)
						lmax = sample;
				}
				else if (sample < 0)
				{
					if (sample < lmin)
						lmin = sample;
				}

				if (channels >= 2)
				{
					byte = bytes.getUInt16((index * channels * 2) + 2);

					if (byte > 65535 / 2)
						byte -= 65535;

					sample = (byte / 65535);

					if (sample > 0)
					{
						if (sample > rmax)
							rmax = sample;
					}
					else if (sample < 0)
					{
						if (sample < rmin)
							rmin = sample;
					}
				}
			}

			v1 = samplesPerRowI > 0 ? (index % samplesPerRowI == 0) : false;
			while (simpleSample ? v1 : rows >= samplesPerRow)
			{
				v1 = false;
				rows -= samplesPerRow;

				gotIndex++;

				var lRMin:Float = Math.abs(lmin) * multiply;
				var lRMax:Float = lmax * multiply;

				var rRMin:Float = Math.abs(rmin) * multiply;
				var rRMax:Float = rmax * multiply;

				if (gotIndex > array[0][0].length)
					array[0][0].push(lRMin);
				else
					array[0][0][gotIndex - 1] = array[0][0][gotIndex - 1] + lRMin;

				if (gotIndex > array[0][1].length)
					array[0][1].push(lRMax);
				else
					array[0][1][gotIndex - 1] = array[0][1][gotIndex - 1] + lRMax;

				if (channels >= 2)
				{
					if (gotIndex > array[1][0].length)
						array[1][0].push(rRMin);
					else
						array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + rRMin;

					if (gotIndex > array[1][1].length)
						array[1][1].push(rRMax);
					else
						array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + rRMax;
				}
				else
				{
					if (gotIndex > array[1][0].length)
						array[1][0].push(lRMin);
					else
						array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + lRMin;

					if (gotIndex > array[1][1].length)
						array[1][1].push(lRMax);
					else
						array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + lRMax;
				}

				lmin = 0;
				lmax = 0;

				rmin = 0;
				rmax = 0;
			}

			index++;
			rows++;
			if (gotIndex > steps)
				break;
		}

		return array;
		#else
		return [[[0], [0]], [[0], [0]]];
		#end
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote == null) {
			updateNoteUI();
			lazyUpdateGrid(-1, -2);
			return;
		}

		if (curSelectedNote[2] != null)
		{
			curSelectedNote[2] += value;
			curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
		}
		updateNoteUI();
		lazyUpdateGrid(Std.int(Conductor.getBeatRounded(curSelectedNote[0])), curSelectedNote[1]);
	}

	function recalculateSteps(add:Float = 0):Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime + add) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSec = 0;
		}

		if (splitVocals)
		{
			if (vocalsLeft != null && vocalsRight != null)
			{
				vocalsLeft.pause();
				vocalsRight.pause();
				vocalsLeft.time = FlxG.sound.music.time;
				vocalsRight.time = FlxG.sound.music.time;
			}
		}
		else
		{
			if (vocals != null) //NOOOOOOOOOOOOOOOO
			{
				vocals.pause();
				vocals.time = FlxG.sound.music.time;
			}
		}
		if (songExtra != null)
		{
			songExtra.pause();
			songExtra.time = FlxG.sound.music.time;
		}
		updateCurStep();

		updateGrid();
		updateSectionUI();
		updateWaveform();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		if (_song.notes[sec] != null)
		{
			curSec = sec;
			if (updateMusic)
			{
				FlxG.sound.music.pause();

				FlxG.sound.music.time = sectionStartTime();
				if (splitVocals)
				{
					if (vocalsLeft != null && vocalsRight != null)
					{
						vocalsLeft.pause();
						vocalsRight.pause();
						vocalsLeft.time = FlxG.sound.music.time;
						vocalsRight.time = FlxG.sound.music.time;
					}
				}
				else
				{
					if (vocals != null) //if i see one more of these someone's gonna go missing (ok good that was the last one)
					{
						vocals.pause();
						vocals.time = FlxG.sound.music.time;
					}
				}
				if (songExtra != null)
				{
					songExtra.pause();
					songExtra.time = FlxG.sound.music.time;
				}
				updateCurStep();
			}

			var blah1:Float = getSectionBeats();
			var blah2:Float = getSectionBeats(curSec + 1);
			if (sectionStartTime(1) > FlxG.sound.music.length)
				blah2 = 0;

			if (blah1 != lastSecBeats || blah2 != lastSecBeatsNext)
			{
				reloadGridLayer();
			}
			else
			{
				updateGrid();
			}
			updateSectionUI();
		}
		else
		{
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
		updateWaveform();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSec];

		stepperBeats.value = getSectionBeats();
		check_mustHitSection.checked = sec.mustHitSection;
		check_gfSection.checked = sec.gfSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		var healthIconP1:String = loadHealthIconFromCharacter(_song.player1);
		var healthIconP2:String = loadHealthIconFromCharacter(_song.player2);

		if (_song.notes[curSec].mustHitSection)
		{
			leftIcon.changeIcon(healthIconP1);
			rightIcon.changeIcon(healthIconP2);
			if (_song.notes[curSec].gfSection)
				leftIcon.changeIcon('gf');
		}
		else
		{
			leftIcon.changeIcon(healthIconP2);
			rightIcon.changeIcon(healthIconP1);
			if (_song.notes[curSec].gfSection)
				leftIcon.changeIcon('gf');
		}
	}

	function loadHealthIconFromCharacter(char:String)
	{
		var characterPath:String = 'characters/' + char + '.json';
		var path:String = Paths.modFolders(characterPath);
		if (!FileSystem.exists(path))
		{
			path = Paths.getPreloadPath(characterPath);
		}

		if (!FileSystem.exists(path))
		{
			path = Paths.getPreloadPath('characters/' + Character.DEFAULT_CHARACTER +
				'.json'); // If a character couldn't be found, change him to BF just to prevent a crash
		}

		var json:Character.CharacterFile = cast Json.parse(File.getContent(path));
		return json.healthicon;
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				stepperSusLength.value = curSelectedNote[2];
				if (curSelectedNote[3] != null)
				{
					currentType = noteTypeMap.get(curSelectedNote[3]);
					if (currentType <= 0)
					{
						noteTypeDropDown.selectedLabel = '';
					}
					else
					{
						noteTypeDropDown.selectedLabel = currentType + '. ' + curSelectedNote[3];
					}
				}
			}
			else
			{
				eventDropDown.selectedLabel = curSelectedNote[1][curEventSelected][0];
				var selected:Int = Std.parseInt(eventDropDown.selectedId);
				if (selected > 0 && selected < eventStuff.length)
				{
					descText.text = eventStuff[selected][1];
				}
				value1InputText.text = curSelectedNote[1][curEventSelected][1];
				value2InputText.text = curSelectedNote[1][curEventSelected][2];
			}
			strumTimeInputText.text = '' + curSelectedNote[0];
		}
	}

	// setting beat to anything positive will only update notes in that specific beat
	// setting the hPlace to anything but negative one only updates notes of that notedata
	// will not reload next renders, use updateGrid() to fully reset instead
	function lazyUpdateGrid(?beatt:Int = -1, ?hPlace:Int = -2)
	{
		beatt = -1;
		hPlace = -2;
		if (beatt == -1 && hPlace == -2)
		{
			updateGrid(false);
			return;
		}

		var beat:Int = beatt;

		//trace("lazily update beat " + beat + " on data " + hPlace);

		var beatLength:Float = 1000 * 60 / getSectionBPM();
		var start:Float = sectionStartTime() - 1;
		var end:Float = sectionStartTime();
		var secBeats:Int = Std.int(getSectionBeats());
		var keysss:Int =  getKeyCount();

		// bounding it just incase
		if (beat > secBeats)
			beat = -1;

		// get the time range
		if (beat != -1)
		{
			start += beatLength * beat;
			end += beatLength * (beat + 1);
		}
		else
			end += secBeats * beatLength;

		var deadNotes:Array<Note> = [];
		var deadSus:Array<SusSprite> = [];
		var deadTexts:Array<AttachedFlxText> = [];

		for (note in curRenderedNotes) {
			var estimatedData:Int = note.noteData;
			if (estimatedData > -1 && note.mustPress != _song.notes[curSec].mustHitSection)
				estimatedData += keysss;
			if (note.eventName != "" || ((hPlace == -2 || estimatedData == hPlace) && (beat == -1 || Conductor.getBeatRounded(note.strumTime) == beat))) {
				deadTexts.push(note.topTenEditorText);
				deadNotes.push(note);
			}
		}
		for (sus in curRenderedSustains)
			if (deadNotes.contains(sus.parentNote))
				deadSus.push(sus);
		for (txt in curRenderedNoteType)
			if (txt.parentNote == null)
				deadTexts.push(txt);

		for (i in _song.notes[curSec].sectionNotes)
		{
			if ((beat != -1 && Conductor.getBeatRounded(i[0]) != beat) || (hPlace != -2 && i[1] != hPlace))
				continue;

			//trace("adding note at beat " + Conductor.getBeatRounded(i[0]) + " on pos " + i[1]);

			var note:Note = setupNoteData(i, false);
			curRenderedNotes.add(note);
			if (note.sustainLength > 0)
				curRenderedSustains.add(setupSusNote(note, secBeats));

			if (i[3] != null && note.noteType != null && note.noteType.length > 0)
			{
				var typeInt:Null<Int> = noteTypeMap.get(i[3]);
				var theType:String = '' + typeInt;
				if (typeInt == null)
					theType = '?';

				var daText:AttachedFlxText = new AttachedFlxText(0, 0, 100, theType, 24);
				daText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				daText.xAdd = -32;
				daText.yAdd = 6;
				daText.borderSize = 1;
				daText.parentNote = note;
				note.topTenEditorText = daText;
				curRenderedNoteType.add(daText);
				daText.sprTracker = note;
			}
			note.mustPress = _song.notes[curSec].mustHitSection;
			if (i[1] > getKeyCount() - 1)
				note.mustPress = !note.mustPress;
		}

		// events
		if (hPlace < 0) {
			for (i in _song.events)
			{
				//if (beat != -1 ? (Conductor.getBeatRounded(i[0]) != beat) : (end < i[0] || i[0] < start))
				//	continue;

				if (end < i[0] || i[0] < start)
					continue;

				var note:Note = setupNoteData(i, false);
				curRenderedNotes.add(note);

				var text:String = 'Event: ' + note.eventName + ' (' + Math.floor(note.strumTime) + ' ms)' + '\nValue 1: ' + note.eventVal1
					+ '\nValue 2: ' + note.eventVal2;
				if (note.eventLength > 1)
					text = note.eventLength + ' Events:\n' + note.eventName;

				var daText:AttachedFlxText = new AttachedFlxText(0, 0, 400, text, 12);
				daText.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
				daText.xAdd = -410;
				daText.borderSize = 1;
				if (note.eventLength > 1)
					daText.yAdd += 8;
				daText.parentNote = note;
				note.topTenEditorText = daText;
				curRenderedNoteType.add(daText);
				daText.sprTracker = note;
			}
		}

		for (i in deadNotes)
			curRenderedNotes.remove(i);
		for (i in deadSus)
			curRenderedSustains.remove(i);
		for (i in deadTexts)
			curRenderedNoteType.remove(i);

		destroyArray(deadNotes);
		destroyArray(deadSus);
		destroyArray(deadTexts); 
	}

	function destroyGroup(group:FlxTypedGroup<Dynamic>)
	{
		if (group == null || group.members == null)
			return;

		for (i in 0...group.length)
		{
			if (group.members[i] == null || group.members[i].destroy == null)
				return;
			group.members[i].destroy();
		}
		group.clear();
	}

	function destroyArray(array:Array<Dynamic>)
	{
		if (array == null)
			return;

		for (i in 0...array.length)
		{
			var objthing:Dynamic = array[i];

			if (objthing == null)
				continue;
			
			array.remove(objthing);

			if (objthing.destroy == null)
				continue;

			objthing.destroy();
		}
	}

	function updateGrid(?renderNext:Bool = true):Void
	{
		destroyGroup(curRenderedNotes);
		destroyGroup(curRenderedSustains);
		destroyGroup(curRenderedNoteType);

		if (renderNext)
		{
			destroyGroup(nextRenderedNotes);
			destroyGroup(nextRenderedSustains);
		}

		if (_song.notes[curSec].changeBPM && _song.notes[curSec].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSec].bpm);
			// trace('BPM of this section:');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSec)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		// CURRENT SECTION
		var beats:Float = getSectionBeats();
		for (i in _song.notes[curSec].sectionNotes)
		{
			var note:Note = setupNoteData(i, false);
			curRenderedNotes.add(note);
			if (note.sustainLength > 0)
			{
				curRenderedSustains.add(setupSusNote(note, beats));
			}

			if (i[3] != null && note.noteType != null && note.noteType.length > 0)
			{
				var typeInt:Null<Int> = noteTypeMap.get(i[3]);
				var theType:String = '' + typeInt;
				if (typeInt == null)
					theType = '?';

				var daText:AttachedFlxText = new AttachedFlxText(0, 0, 100, theType, 24);
				daText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				daText.xAdd = -32;
				daText.yAdd = 6;
				daText.borderSize = 1;
				curRenderedNoteType.add(daText);
				daText.sprTracker = note;
			}
			note.mustPress = _song.notes[curSec].mustHitSection;
			if (i[1] > getKeyCount() - 1)
				note.mustPress = !note.mustPress;
		}

		// CURRENT EVENTS
		var startThing:Float = sectionStartTime();
		var endThing:Float = sectionStartTime(1);
		for (i in _song.events)
		{
			if (endThing > i[0] && i[0] >= startThing)
			{
				var note:Note = setupNoteData(i, false);
				curRenderedNotes.add(note);

				var text:String = 'Event: ' + note.eventName + ' (' + Math.floor(note.strumTime) + ' ms)' + '\nValue 1: ' + note.eventVal1 + '\nValue 2: '
					+ note.eventVal2;
				if (note.eventLength > 1)
					text = note.eventLength + ' Events:\n' + note.eventName;

				var daText:AttachedFlxText = new AttachedFlxText(0, 0, 400, text, 12);
				daText.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
				daText.xAdd = -410;
				daText.borderSize = 1;
				if (note.eventLength > 1)
					daText.yAdd += 8;
				daText.parentNote = note;
				note.topTenEditorText = daText;
				curRenderedNoteType.add(daText);
				daText.sprTracker = note;
				// trace('test: ' + i[0], 'startThing: ' + startThing, 'endThing: ' + endThing);
			}
		}

		if (!renderNext)
			return;

		// NEXT SECTION
		var beats:Float = getSectionBeats(1);
		if (curSec < _song.notes.length - 1)
		{
			for (i in _song.notes[curSec + 1].sectionNotes)
			{
				var note:Note = setupNoteData(i, true);
				note.alpha = 0.6;
				nextRenderedNotes.add(note);
				if (note.sustainLength > 0)
				{
					nextRenderedSustains.add(setupSusNote(note, beats));
				}
			}
		}

		// NEXT EVENTS
		var startThing:Float = sectionStartTime(1);
		var endThing:Float = sectionStartTime(2);
		for (i in _song.events)
		{
			if (endThing > i[0] && i[0] >= startThing)
			{
				var note:Note = setupNoteData(i, true);
				note.alpha = 0.6;
				nextRenderedNotes.add(note);
			}
		}
	}

	function getKeyCount()
	{
		return Note.maniaToKeyCount(_song.mania);
	}

	function setupNoteData(i:Array<Dynamic>, isNextSection:Bool):Note
	{
		var daNoteInfo = i[1];
		var daStrumTime = i[0];
		var daSus:Dynamic = i[2];

		var note:Note = new Note(daStrumTime, daNoteInfo % getKeyCount(), null, null, true);
		if (daSus != null)
		{ // Common note
			if (!Std.isOfType(i[3], String)) // Convert old note type to new note type format
			{
				i[3] = noteTypeIntMap.get(i[3]);
			}
			if (i.length > 3 && (i[3] == null || i[3].length < 1))
			{
				i.remove(i[3]);
			}
			note.sustainLength = daSus;
			note.noteType = i[3];
		}
		else
		{ // Event note
			note.loadGraphic(Paths.image('eventArrow'));
			note.eventName = getEventName(i[1]);
			note.eventLength = i[1].length;
			if (i[1].length < 2)
			{
				note.eventVal1 = i[1][0][1];
				note.eventVal2 = i[1][0][2];
			}
			note.noteData = -1;
			daNoteInfo = -1;
		}

		note.setGraphicSize(GRID_SIZE, GRID_SIZE);
		note.updateHitbox();
		note.x = Math.floor(daNoteInfo * GRID_SIZE) + GRID_SIZE;
		if (isNextSection && _song.notes[curSec].mustHitSection != _song.notes[curSec + 1].mustHitSection)
		{
			if (daNoteInfo > getKeyCount() - 1)
			{
				note.x -= GRID_SIZE * getKeyCount();
			}
			else if (daSus != null)
			{
				note.x += GRID_SIZE * getKeyCount();
			}
		}

		var beats:Float = getSectionBeats(isNextSection ? 1 : 0);
		note.y = getYfromStrumNotes(daStrumTime - sectionStartTime(), beats);
		// if(isNextSection) note.y += gridBG.height;
		if (note.y < -150)
			note.y = -150;
		return note;
	}

	function getEventName(names:Array<Dynamic>):String
	{
		var retStr:String = '';
		var addedOne:Bool = false;
		for (i in 0...names.length)
		{
			if (addedOne)
				retStr += ', ';
			retStr += names[i][0];
			addedOne = true;
		}
		return retStr;
	}

	function setupSusNote(note:Note, beats:Float):SusSprite
	{
		var height:Int = Math.floor(FlxMath.remapToRange(note.sustainLength, 0, Conductor.stepCrochet * 16, 0, GRID_SIZE * 16 * zoomList[curZoom])
			+ (GRID_SIZE * zoomList[curZoom])
			- GRID_SIZE / 2);
		var minHeight:Int = Std.int((GRID_SIZE * zoomList[curZoom] / 2) + GRID_SIZE / 2);
		if (height < minHeight)
			height = minHeight;
		if (height < 1)
			height = 1; // Prevents error of invalid height

		var spr:SusSprite = cast(new SusSprite(note, note.x + (GRID_SIZE * 0.5) - 4, note.y + GRID_SIZE / 2).makeGraphic(8, height));
		spr.parentNote = note;
		return spr;
	}

	private function addSection(sectionBeats:Float = 4):Void
	{
		var sec:SwagSection = {
			sectionBeats: sectionBeats,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			gfSection: false,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var noteDataToCheck:Int = note.noteData;

		if (noteDataToCheck > -1)
		{
			if (note.mustPress != _song.notes[curSec].mustHitSection)
				noteDataToCheck += getKeyCount();
			for (i in _song.notes[curSec].sectionNotes)
			{
				if (i != curSelectedNote && i.length > 2 && i[0] == note.strumTime && i[1] == noteDataToCheck)
				{
					curSelectedNote = i;
					break;
				}
			}
		}
		else
		{
			for (i in _song.events)
			{
				if (i != curSelectedNote && i[0] == note.strumTime)
				{
					curSelectedNote = i;
					curEventSelected = Std.int(curSelectedNote[1].length) - 1;
					changeEventSelected();
					break;
				}
			}
		}

		if (note != null)
			lazyUpdateGrid(Std.int(Conductor.getBeatRounded(note.strumTime)), note.noteData);
		else
			lazyUpdateGrid(-1, -2);

		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		var noteDataToCheck:Int = note.noteData;
		var noteStrum:Float = note.strumTime;
		if (noteDataToCheck > -1 && note.mustPress != _song.notes[curSec].mustHitSection)
			noteDataToCheck += getKeyCount();

		if (note.noteData > -1) // Normal Notes
		{
			for (i in _song.notes[curSec].sectionNotes)
			{
				if (i[0] == note.strumTime && i[1] == noteDataToCheck)
				{
					if (i == curSelectedNote)
						curSelectedNote = null;
					// FlxG.log.add('FOUND EVIL NOTE');
					_song.notes[curSec].sectionNotes.remove(i);
					break;
				}
			}
		}
		else // Events
		{
			for (i in _song.events)
			{
				if (i[0] == note.strumTime)
				{
					if (i == curSelectedNote)
					{
						curSelectedNote = null;
						changeEventSelected();
					}
					// FlxG.log.add('FOUND EVIL EVENT');
					_song.events.remove(i);
					break;
				}
			}
		}

		//trace(noteDataToCheck);
		lazyUpdateGrid(Std.int(Conductor.getBeatRounded(noteStrum)), noteDataToCheck);
	}

	public function doANoteThing(cs, d, style)
	{
		var delnote = false;
		if (strumLineNotes.members[d] != null && strumLineNotes.members[d].overlaps(curRenderedNotes))
		{
			curRenderedNotes.forEachAlive(function(note:Note)
			{
				if (note.overlapsPoint(new FlxPoint(strumLineNotes.members[d].x + 1, strumLine.y + 1))
					&& note.noteData == d % getKeyCount())
				{
					// trace('tryin to delete note...');
					if (!delnote)
						deleteNote(note);
					delnote = true;
				}
			});
		}

		if (!delnote)
		{
			addNote(cs, d, style);
		}
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
			_song.notes[daSection].sectionNotes = [];
		updateGrid();
	}

	private function addNote(strum:Null<Float> = null, data:Null<Int> = null, type:Null<Int> = null):Void
	{
		// curUndoIndex++;
		// var newsong = _song.notes;
		//	undos.push(newsong);
		var noteStrum = getStrumTime(dummyArrow.y, false) + sectionStartTime();
		var noteData = Math.floor((FlxG.mouse.x - GRID_SIZE - gridBG.x) / GRID_SIZE);
		var noteSus = 0;
		var daAlt = false;
		var daType = currentType;

		if (strum != null)
			noteStrum = strum;
		if (data != null)
			noteData = data;
		if (type != null)
			daType = type;

		if (noteData > -1)
		{
			_song.notes[curSec].sectionNotes.push([noteStrum, noteData, noteSus, noteTypeIntMap.get(daType)]);
			curSelectedNote = _song.notes[curSec].sectionNotes[_song.notes[curSec].sectionNotes.length - 1];
		}
		else
		{
			var event = eventStuff[Std.parseInt(eventDropDown.selectedId)][0];
			var text1 = value1InputText.text;
			var text2 = value2InputText.text;
			_song.events.push([noteStrum, [[event, text1, text2]]]);
			curSelectedNote = _song.events[_song.events.length - 1];
			curEventSelected = 0;
			changeEventSelected();
		}

		if (FlxG.keys.pressed.CONTROL && noteData > -1)
		{
			_song.notes[curSec].sectionNotes.push([
				noteStrum,
				(noteData + getKeyCount()) % getKeyCount() * 2,
				noteSus,
				noteTypeIntMap.get(daType)
			]);
		}

		// trace(noteData + ', ' + noteStrum + ', ' + curSec);
		strumTimeInputText.text = '' + curSelectedNote[0];

		lazyUpdateGrid(Std.int(Conductor.getBeatRounded(noteStrum)), noteData);
		updateNoteUI();
	}

	// will figure this out l8r
	function redo()
	{
		// _song = redos[curRedoIndex];
	}

	function undo()
	{
		// redos.push(_song);
		undos.pop();
		// _song.notes = undos[undos.length - 1];
		///trace(_song.notes);
		// updateGrid();
	}

	function getStrumTime(yPos:Float, doZoomCalc:Bool = true):Float
	{
		var leZoom:Float = zoomList[curZoom];
		if (!doZoomCalc)
			leZoom = 1;
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height * leZoom, 0, getSectionBeats(curSec) * 4 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float, doZoomCalc:Bool = true):Float
	{
		var leZoom:Float = zoomList[curZoom];
		if (!doZoomCalc)
			leZoom = 1;
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height * leZoom);
	}

	function getYfromStrumNotes(strumTime:Float, beats:Float):Float
	{
		var value:Float = strumTime / (beats * 4 * Conductor.stepCrochet);
		return GRID_SIZE * beats * 4 * zoomList[curZoom] * value + gridBG.y;
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		PlayState.storyDifficulty = CoolUtil.loadSongDiffs(song.toLowerCase());
		PlayState.SONG = Song.loadFromJson(song.toLowerCase() + "-" + CoolUtil.difficulties[PlayState.storyDifficulty], song.toLowerCase());
		MusicBeatState.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	function clearEvents()
	{
		_song.events = [];
		updateGrid();
	}

	private function saveLevel()
	{
		_song.events.sort(sortByTime);
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), Paths.formatToSongPath(_song.song) + ".json");
		}
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	private function saveEvents()
	{
		_song.events.sort(sortByTime);
		var eventsSong:Dynamic = {
			events: _song.events
		};
		var json = {
			"song": eventsSong
		}

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "events.json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	function getSectionBeats(?section:Null<Int> = null)
	{
		if (section == null)
			section = curSec;
		var val:Null<Float> = null;

		if (_song.notes[section] != null)
			val = _song.notes[section].sectionBeats;
		return val != null ? val : 4;
	}
}

class AttachedFlxText extends FlxText
{
	public var parentNote:Note;
	public var sprTracker:FlxSprite;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
	{
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
		{
			setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
			angle = sprTracker.angle;
			alpha = sprTracker.alpha;
		}
	}
}

class SusSprite extends FlxSprite
{
	public var parentNote:Note;

	public function new(parentNote:Note, ?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
		this.parentNote = parentNote;
	}
}