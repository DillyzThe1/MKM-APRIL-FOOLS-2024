local allowCountdown = false
	
function goingToDoCutscene()
	if isInANormalMode() and not allowCountdown and isStoryMode and not seenCutscene then --and not seenCutscene then
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
		if string.lower(difficultyName) == "alpha" then
			startVideo('pre-house-alpha');
		else
			startVideo('pre-' .. string.lower(songName));
		end
		allowCountdown = true;
		return Function_Stop;
	end
	--setProperty('camGame.alpha',1)
	return Function_Continue;
end

function isInANormalMode()
	local diffff = string.lower(difficultyName)
	if diffff == "hard" or diffff == "old" or diffff == "alpha" then
		return true
	end
	return false
end