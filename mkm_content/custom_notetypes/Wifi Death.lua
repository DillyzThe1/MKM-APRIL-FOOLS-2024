local deathDivision = 1

--function onCreate()
--	debugPrint('wifi')
--end

function goodNoteHit(id, data, typee, sus)
	if typee == 'Wifi Death' then 
		runTimer('frameFix', 4)
		deathDivision = deathDivision + 1
		updateFramerate()
		--debugPrint('die')
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'frameFix' then 
		deathDivision = deathDivision - 1
		updateFramerate()
	end
end

function updateFramerate()
	if deathDivision < 0 or deathDivision > 20 then 
		deathDivision = 1
	end
	setPropertyFromClass('flixel.FlxG','drawFramerate',getPropertyFromClass('ClientPrefs','framerate')/deathDivision)
end

function onDestroy()
	setPropertyFromClass('flixel.FlxG','drawFramerate',getPropertyFromClass('ClientPrefs','framerate'))
end