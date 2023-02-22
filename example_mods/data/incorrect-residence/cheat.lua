function onChartAccessed() 
	if songCompletedOnDiff('Hell Shrooms', 'Hard') then
		loadSong('Hell Shrooms', 'Impostor Top 10')
		return Function_Stop
	end
	return Function_Continue
end