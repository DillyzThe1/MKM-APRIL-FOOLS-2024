function onChartAccessed() 
	if songCompletedOnDiff('Hell Shrooms', 'Hard') then
		loadSong('Hell Shrooms', 'Impostor Top 10')
		return Function_Stop
	else
		loadSong('why')
		sreturn Function_Stop
	end
	return Function_Continue
end