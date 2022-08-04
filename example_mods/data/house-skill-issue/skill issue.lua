function onEndSong()
	if isStoryMode then 
		setPropertyFromClass('PlayState','storyPlaylist',{'skill'})
		setPropertyFromClass('PlayState','isStoryMode',false)
		loadSong('skill')
		return Function_Stop
	end
	debugPrint('aids')
	return Function_Continue
end