local restTimer = 0
local notesRequired = 1

function opponentNoteHit(index,b,c,sus)
	if not sus then
		if restTimer >= notesRequired then
			resettime()
			--return Function_Stop
		end
		restTimer = restTimer + 1
	end
end

function goodNoteHit(index,b,c,sus)
	if not sus then
		if restTimer >= notesRequired then
			resettime()
			--return Function_Stop
		end
		restTimer = restTimer + 1
	end
end

function resettime()
	--runHaxeCode('FlxG.sound.music.pause();')
	--runHaxeCode('voices.pause();')
	--setPropertyFromClass('Conductor','songPosition',0)
	--setPropertyFromClass('flixel.FlxG','sound.music.time',0)
	--setProperty('voices.time',0)
	runHaxeCode('FlxG.sound.music.play(true,0);')
	runHaxeCode('voices.play(true,0);')
	restTimer = 0
end