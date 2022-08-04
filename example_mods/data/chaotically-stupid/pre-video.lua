local allowCountdown = false
	
function goingToDoCutscene()
	if not allowCountdown and isStoryMode and not seenCutscene then --and not seenCutscene then
		return true 
	end
		
	return false
end

function onCreatePost()
	if goingToDoCutscene() then 
		setProperty('camGame.alpha',0)
	end
end

function onStartCountdown()
	if goingToDoCutscene() then --Block the first countdown
		startVideo('pre-' .. string.lower(songName));
		allowCountdown = true;
		return Function_Stop;
	end
	setProperty('camGame.alpha',1)
	return Function_Continue;
end