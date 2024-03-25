function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Luigi Note' then 
			setPropertyFromGroup('unspawnNotes',i,'characterController','normal luigi')
		end
	end
end