function onChartAccessed()
	if songCompletedOnDiff('Hell Shrooms', 'Hard') and not songCompletedOnDiff('Hell Shrooms', 'Impostor Top 10') then
		loadSong('Hell Shrooms', 'Impostor Top 10')
		debugPrint("hell shrooms")
		return Function_Stop
	end
	loadSong('why', 'Hard')
	return Function_Stop
end