function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Joke Note' then 
			setPropertyFromGroup('unspawnNotes', i, 'missPenalty', false)
		end
	end
end