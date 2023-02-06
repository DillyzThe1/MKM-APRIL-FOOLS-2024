function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Joke Note Alt' then 
			setPropertyFromGroup('unspawnNotes',i,'ignoreNote',true)
			setPropertyFromGroup('unspawnNotes',i,'animSuffix','-alt')
		end
	end
end