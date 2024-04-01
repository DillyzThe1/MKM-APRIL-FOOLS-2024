function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Frye Joke Note' then 
			setPropertyFromGroup('unspawnNotes',i,'characterController','frye')
			setPropertyFromGroup('unspawnNotes', i, 'missPenalty', false)
		end
	end
end