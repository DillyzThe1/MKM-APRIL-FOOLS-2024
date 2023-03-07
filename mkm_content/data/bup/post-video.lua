local allowCountdown = false
	
function goingToDoCutscene()
	if string.lower(difficultyName) == "hard" then
		if not allowCountdown and isStoryMode then --and not seenCutscene then
			return true 
		end
			
		return false
	end
end
function onEndSong()
	if string.lower(difficultyName) == "hard" then
		if goingToDoCutscene() then --Block the first countdown
			setProperty('camGame.alpha',0)
			setProperty('camHUD.alpha',0)
			startVideo('post-' .. string.lower(songName));
			allowCountdown = true;
			return Function_Stop;
		end
		return Function_Continue;
	end
end