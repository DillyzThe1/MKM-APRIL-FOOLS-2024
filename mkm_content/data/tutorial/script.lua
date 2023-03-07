function onChartAccessed() 
	loadSong('Academic Failure')
	return Function_Stop
end

function noteMiss()
	loadSong('Academic Failure')
end

function noteMissPress()
	loadSong('Academic Failure')
end

function onCreatePost()
	if string.lower(difficultyName) == "hard" then
		setProperty("dad.visible",false)
		setProperty("dad.active",false)
		addLuaScript("custom_events/Change IconP2")
		triggerEvent("Change IconP2", "gf", "A5004D")
	end
end

local northerntexas = false
function onBeatHit()
	if string.lower(difficultyName) == "hard" and curBeat >= 6 and not northerntexas then 
		northerntexas = true
		startCutscene()
	end
end

function startCutscene()
	triggerEvent("Alt Idle Animation", "gf", "-")
	triggerEvent("Camera Follow Pos", "800", "200")
	runTimer("gftrans", 10/24)
end

function onTimerCompleted(tag)
	if tag == "gftrans" then
		playAnim("gf", "transition", true)
		runTimer("toadicon", 12/24)
		runTimer("toadidle", 55/24)
	elseif tag == "toadicon" then
		triggerEvent("Change IconP2", "toad", "FF0033")
	elseif tag == "toadidle" then
		triggerEvent("Camera Follow Pos", "", "")
		triggerEvent("Alt Idle Animation", "gf", "-alt")
	end
end