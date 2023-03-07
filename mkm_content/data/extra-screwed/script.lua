local section = 0

function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if getPropertyFromGroup('unspawnNotes',i,'mustPress') and getPropertyFromGroup('unspawnNotes',i,'noteData') == 4 and (getPropertyFromGroup('unspawnNotes',i,'noteType') == '' or getPropertyFromGroup('unspawnNotes',i,'noteType') == nil) then 
			setPropertyFromGroup('unspawnNotes',i,'noteType','Hey!')
		end
	end
end

function onChartAccessed() 
	loadSong('Welcom Toad')
	return Function_Stop
end

function onUpdatePost(elapsed)
	section = math.floor(curBeat/4)
	if section > 79 then
		local currentBeat = (getSongPosition() / 1000)*(bpm/60)
		for i=0, getProperty('strumLineNotes.length') - 1 do
			setPropertyFromGroup('strumLineNotes', i, 'y', getProperty('strumLine.y') + 10 * math.cos((currentBeat + i*0.25) * math.pi)) 
		end
	end
end