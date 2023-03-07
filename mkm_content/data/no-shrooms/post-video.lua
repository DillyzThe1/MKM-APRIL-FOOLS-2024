local allowCountdown = false
	
function goingToDoCutscene()
	if isInANormalMode() and not allowCountdown and isStoryMode then --and not seenCutscene then
		return true 
	end
		
	return false
end
function onEndSong()
	if goingToDoCutscene() then --Block the first countdown
		setProperty('camGame.alpha',0)
		setProperty('camHUD.alpha',0)
		startVideo('post-' .. string.lower(songName));
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end

function isInANormalMode()
	local diffff = string.lower(difficultyName)
	if diffff == "hard" or diffff == "old" or diffff == "skill issue" then
		return true
	end
	return false
end