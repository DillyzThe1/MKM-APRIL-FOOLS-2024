local allowCountdown = false

function goingToDoCutscene()
	if not allowCountdown then --and not seenCutscene then
		return true 
	end
		
	return false
end

function onCreatePost()
	if goingToDoCutscene() then 
		setProperty('camGame.alpha',0)
	end
	debugPrint(allowFullscreen)
end

function onStartCountdown()
	if goingToDoCutscene() then --Block the first countdown
		startVideo('Sad Spongebob');
		--setPropertyFromClass('flixel.FlxG','fullscreen',true)
		allowCountdown = true;
		return Function_Stop;
	end
	--setPropertyFromClass('flixel.FlxG','fullscreen',false)
	endSong()
	return Function_Stop;
end