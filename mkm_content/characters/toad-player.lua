function onGameOver()
	if string.lower(getProperty("boyfriend.curCharacter")) == string.lower(scriptName) then
		setPropertyFromClass("GameOverSubstate", "characterName", scriptName)
		setPropertyFromClass("GameOverSubstate", "deathSoundName", "death-toad")
	end
	return Function_Continue
end