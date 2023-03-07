function onCreatePost()
	addCharacterToList('bf-dead-sping-bing','bf')
end

function opponentNoteHit()
	setProperty('dad.offset.x',getRandomInt(-250,250))
	setProperty('dad.offset.y',getRandomInt(-350,350))
end

function goodNoteHit()
	setProperty('boyfriend.offset.x',getRandomInt(-250,250))
	setProperty('boyfriend.offset.y',getRandomInt(-350,350))
end

function missNote()
	setProperty('boyfriend.offset.x',getRandomInt(-250,250))
	setProperty('boyfriend.offset.y',getRandomInt(-350,350))
end

function onGameOver() 
	setPropertyFromClass('GameOverSubstate','characterName','bf-dead-sping-bing')
	setPropertyFromClass('GameOverSubstate','loopSoundName','gameOverWelcomeToad')
	setPropertyFromClass('GameOverSubstate','endSoundName','gameOverWelcomeToadEnd')
	return FunkinLua.Function_Continue
end

function onChartAccessed() 
	loadSong('Sad Sping Bing')
	return Function_Stop
end