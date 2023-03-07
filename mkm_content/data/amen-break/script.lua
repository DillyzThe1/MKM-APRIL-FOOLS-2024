function onCreatePost()
	setProperty('camGame.alpha',0)
end

function onStartCountdown()
	if not allowCountdown then --Block the first countdown
		startVideo('Amen')
		allowCountdown = true
		return Function_Stop
	end
	endSong()
	return Function_Stop;
end