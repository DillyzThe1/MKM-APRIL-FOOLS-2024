package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class MusicBeatState extends FlxUIState
{
	public static var instance:MusicBeatState;
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	#if CHAT_LU_E_G__ALLOWED
	public static var terror:Float = FlxG.random.float(900, 7200);
	#end
	private var curStep:Int = 0;

	public var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		instance = this;
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		super.create();

		if (!skip)
		{
			openSubState(new CustomFadeTransition(0.7, true));
		}
		FlxTransitionableState.skipNextTransOut = false;

		
		if (FlxG.camera != null)
			FlxG.camera.bgColor = FlxColor.BLACK;
		Paths.image("mainmenu/a");
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if (curStep > 0)
				stepHit();

			if (PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if (FlxG.save.data != null)
			FlxG.save.data.fullscreen = FlxG.fullscreen;

		super.update(elapsed);

		if (Main.fpsVar != null)
			Main.fpsVar.showFps = Main.fpsVar.showMemory = true;

		#if debug
			if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.B)
			{
				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.fadeOut(0.13, 0, function(t:FlxTween) {
						FlxG.sound.music.pause();
					});
				}
				openSubState(new TheUseOfPlayStateDotHxOnThisMKMIsCurrentlyRestrictedByNintendo());
			}
		#end

		#if CHAT_LU_E_G__ALLOWED
		terror -= elapsed;
		//Application.current.window.title = "terror: " + terror;
		if ((terror <= 0 && terror >= -100000) #if debug || (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.NINE) #end)
			theHorrors();
		#end
	}

	private function updateSection():Void
	{
		if (stepsToDo < 1)
			stepsToDo = Math.round(getBeatsOnSection() * 4);
		while (curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if (curStep < 0)
			return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if (stepsToDo > curStep)
					break;

				curSection++;
			}
		}

		if (curSection > lastSection)
			sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep / 4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(nextState:FlxState)
	{
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if (!FlxTransitionableState.skipNextTransIn)
		{
			leState.openSubState(new CustomFadeTransition(0.6, false));
			if (nextState == FlxG.state)
			{
				CustomFadeTransition.finishCallback = function()
				{
					FlxG.resetState();
				};
				// trace('resetted');
			}
			else
			{
				CustomFadeTransition.finishCallback = function()
				{
					FlxG.switchState(nextState);
				};
				// trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState()
	{
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState
	{
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// trace('Beat: ' + curBeat);
	}

	public function sectionHit():Void
	{
		// trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null)
			val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}

	public function checkBan(delay:Float = 0):Bool
	{
		if (ClientPrefs.ls_enabled("killmario"))
		{
			trace("mario has been killed");
			new FlxTimer().start(delay, function(t:FlxTimer)
			{
				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.fadeOut(0.13, 0, function(t:FlxTween) {
						FlxG.sound.music.pause();
					});
				}
			
				openSubState(new TheUseOfPlayStateDotHxOnThisMKMIsCurrentlyRestrictedByNintendo());
			});
			return true;
		}
		return false;
	}

	#if CHAT_LU_E_G__ALLOWED
	public static function theHorrors() {
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		LoadingState.loadAndSwitchState(new PlayState.PeeYourPantsState());
	}
	#end
}
